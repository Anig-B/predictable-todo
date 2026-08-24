"use server";

import { createClient } from "@/lib/supabase/server";

export interface ReportsPayload {
  missions: Array<{
    id: string;
    name: string;
    tasksTotal: number;
    tasksDone: number;
    xpEarned: number;
  }>;
  users: Array<{
    id: string;
    name: string;
    xp: number;
    level: number;
    streak: number;
    weeklyXp: number;
  }>;
  activities: Record<
    string,
    Array<{
      id: string;
      task: string;
      project: string;
      points: number | null;
      timestamp: string;
    }>
  >;
  completionStats: Record<
    string,
    { done: number; total: number; rate: number }
  >;
  missionMembers: Record<
    string,
    Array<{
      name: string;
      assigned: number;
      done: number;
      xp: number;
    }>
  >;
}

export async function getManagerReportsData(
  timeframe: "daily" | "weekly" | "monthly",
): Promise<{
  isManager: boolean;
  data: ReportsPayload | null;
  error?: string;
}> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user?.id) return { isManager: false, data: null, error: "Unauthorized" };

  // 1. Auth check
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  const isManager = profile?.role === "manager" || profile?.role === "admin";
  if (!isManager) return { isManager: false, data: null };

  // Calculate cutoff timeframe
  const now = new Date();
  if (timeframe === "daily") now.setDate(now.getDate() - 1);
  else if (timeframe === "weekly") now.setDate(now.getDate() - 7);
  else if (timeframe === "monthly") now.setMonth(now.getMonth() - 1);
  const startDate = now.toISOString();

  // 2. Single DB fetch for missions & tasks
  const { data: missions } = await supabase
    .from("missions")
    .select("id, name, tasks(id, done, points, user_id)")
    .eq("created_by", user.id);

  if (!missions || missions.length === 0) {
    return {
      isManager: true,
      data: {
        missions: [],
        users: [],
        activities: {},
        completionStats: {},
        missionMembers: {},
      },
    };
  }

  const missionIds = missions.map((m) => m.id);

  // 3. Batch fetch joined members
  const { data: membersData } = await supabase
    .from("mission_members")
    .select("user_id, mission_id")
    .in("mission_id", missionIds)
    .not("joined_at", "is", null);

  const userIds = Array.from(
    new Set((membersData || []).map((m) => m.user_id).filter(Boolean)),
  );

  const formattedMissions = missions.map((m) => {
    const tasks = m.tasks || [];
    const completed = tasks.filter((t: any) => t.done);
    return {
      id: m.id,
      name: m.name || "Untitled Mission",
      tasksTotal: tasks.length,
      tasksDone: completed.length,
      xpEarned: completed.reduce(
        (sum: number, t: any) => sum + (t.points || 0),
        0,
      ),
    };
  });

  if (userIds.length === 0) {
    return {
      isManager: true,
      data: {
        missions: formattedMissions,
        users: [],
        activities: {},
        completionStats: {},
        missionMembers: {},
      },
    };
  }

  // 4. Batch fetch profiles, stats, and logs in parallel
  const [{ data: profilesData }, { data: statsData }, { data: logsData }] =
    await Promise.all([
      supabase
        .from("profiles")
        .select("id, username, level, streak, xp")
        .in("id", userIds),
      supabase
        .from("user_stats")
        .select("user_id, xp, level, current_streak, weekly_xp")
        .in("user_id", userIds),
      supabase
        .from("activity_logs")
        .select("id, user_id, task, points, project, created_at")
        .in("user_id", userIds)
        .gte("created_at", startDate)
        .order("created_at", { ascending: false }),
    ]);

  const statsMap = new Map((statsData || []).map((s) => [s.user_id, s]));

  const formattedUsers = (profilesData || []).map((p) => {
    const s: any = statsMap.get(p.id);
    return {
      id: p.id,
      name: p.username || "Unknown User",
      xp: s?.xp ?? p.xp ?? 0,
      level: s?.level ?? p.level ?? 1,
      streak: s?.current_streak ?? p.streak ?? 0,
      weeklyXp: s?.weekly_xp ?? 0,
    };
  });

  const userMap = new Map(formattedUsers.map((u) => [u.id, u]));

  // 5. Aggregate member breakdown per mission
  const missionMembersMap: Record<string, any[]> = {};
  missions.forEach((m) => {
    const tasks = m.tasks || [];
    const memberIdsInMission = (membersData || [])
      .filter((md) => md.mission_id === m.id)
      .map((md) => md.user_id);

    missionMembersMap[m.id] = memberIdsInMission.map((uId) => {
      const uTasks = tasks.filter((t: any) => t.user_id === uId);
      const uDone = uTasks.filter((t: any) => t.done);
      return {
        name: userMap.get(uId)?.name || "Unknown User",
        assigned: uTasks.length,
        done: uDone.length,
        xp: uDone.reduce((sum: number, t: any) => sum + (t.points || 0), 0),
      };
    });
  });

  // 6. Aggregate activities & completion stats per user
  const activitiesMap: Record<string, any[]> = {};
  const completionStatsMap: Record<string, any> = {};

  formattedUsers.forEach((u) => {
    const uLogs = (logsData || [])
      .filter((l) => l.user_id === u.id)
      .slice(0, 10);
    activitiesMap[u.id] = uLogs.map((l) => ({
      id: l.id,
      task: l.task || "Task Action",
      project: l.project || "General",
      points: l.points ?? null,
      timestamp: new Date(l.created_at).toLocaleDateString(),
    }));

    const allManagedTasks = missions
      .flatMap((m) => m.tasks || [])
      .filter((t: any) => t.user_id === u.id);
    const doneTasks = allManagedTasks.filter((t: any) => t.done);
    const total = allManagedTasks.length;
    const done = doneTasks.length;
    completionStatsMap[u.id] = {
      done,
      total,
      rate: total > 0 ? Math.round((done / total) * 100) : 0,
    };
  });

  return {
    isManager: true,
    data: {
      missions: formattedMissions,
      users: formattedUsers,
      activities: activitiesMap,
      completionStats: completionStatsMap,
      missionMembers: missionMembersMap,
    },
  };
}
