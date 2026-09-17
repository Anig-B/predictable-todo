"use server";

import { createClient } from "@/lib/supabase/server";

export type Timeframe = "daily" | "weekly" | "monthly" | "all";

export interface UserOption {
  id: string;
  name: string;
  avatarUrl?: string;
  isPending: boolean;
}

export interface UserActivity {
  id: string;
  task: string;
  project: string;
  points: number | null;
  timestamp: string;
  missionId?: string;
}

export interface CompanyOverviewStats {
  totalMissions: number;
  completedMissions: number;
  remainingMissions: number;
  totalTasks: number;
  completedTasks: number;
  remainingTasks: number;
  companyCompletionRate: number;
  totalCompanyXp: number;
}

export interface MissionOption {
  id: string;
  name: string;
  isActive: boolean;
  tasksTotal: number;
  tasksDone: number;
  xpEarned: number;
  completionRate: number;
}

export interface MissionMemberBreakdown {
  userId: string;
  name: string;
  assigned: number;
  done: number;
  xp: number;
}

export interface ReportsPayload {
  company: CompanyOverviewStats;
  users: UserOption[];
  missions: MissionOption[];
  userXpTotal: Record<string, number>;
  activities: Record<string, UserActivity[]>;
  missionActivities: Record<string, UserActivity[]>;
  completionStats: Record<
    string,
    { done: number; total: number; pending: number; rate: number }
  >;
  userMissions: Record<
    string,
    {
      id: string;
      name: string;
      progress: number;
      tasksTotal: number;
      tasksDone: number;
      xpEarned: number;
    }[]
  >;
  missionMembers: Record<string, MissionMemberBreakdown[]>;
  userAssignedMissionIds: Record<string, string[]>;
}

export interface GetManagerReportsResponse {
  isManager: boolean;
  data: ReportsPayload | null;
}

function getTimeframeStartDate(timeframe: Timeframe): Date | null {
  const now = new Date();
  if (timeframe === "daily") {
    const d = new Date(now);
    d.setHours(d.getHours() - 24);
    return d;
  }
  if (timeframe === "weekly") {
    const d = new Date(now);
    d.setDate(d.getDate() - 7);
    return d;
  }
  if (timeframe === "monthly") {
    const d = new Date(now);
    d.setDate(d.getDate() - 30);
    return d;
  }
  return null;
}

export async function getManagerReportsData(
  timeframe: Timeframe = "weekly",
): Promise<GetManagerReportsResponse> {
  const supabase = await createClient();

  // 1. Authenticate Current Manager
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser();

  if (authError || !user) {
    return { isManager: false, data: null };
  }

  const managerId = user.id;

  // 2. Fetch Manager's Missions (Active and Completed)
  const { data: managerMissionsData } = await supabase
    .from("missions")
    .select("id, name, created_at, is_active")
    .eq("created_by", managerId);

  const managerMissions = managerMissionsData || [];
  const managerMissionIds = managerMissions.map((m) => m.id);

  if (managerMissionIds.length === 0) {
    return {
      isManager: true,
      data: {
        company: {
          totalMissions: 0,
          completedMissions: 0,
          remainingMissions: 0,
          totalTasks: 0,
          completedTasks: 0,
          remainingTasks: 0,
          companyCompletionRate: 0,
          totalCompanyXp: 0,
        },
        users: [],
        missions: [],
        userXpTotal: {},
        activities: {},
        missionActivities: {},
        completionStats: {},
        userMissions: {},
        missionMembers: {},
        userAssignedMissionIds: {},
      },
    };
  }

  // 3. Fetch Mission Members
  const { data: missionMembersRes } = await supabase
    .from("mission_members")
    .select(
      `
      mission_id,
      user_id,
      role,
      joined_at,
      user:profiles!user_id(id, username, avatar_url, role)
    `,
    )
    .eq("invited_by", managerId)
    .not("joined_at", "is", null);

  const rawMembers = missionMembersRes || [];
  const validMembers = rawMembers.filter((m: any) => {
    const profile = Array.isArray(m.user) ? m.user[0] : m.user;
    return m.user_id && (!profile || profile.role !== "admin");
  });

  const activeUserMap = new Map<string, UserOption>();
  const userAssignedMissionIds: Record<string, string[]> = {};

  validMembers.forEach((item: any) => {
    const profile = Array.isArray(item.user) ? item.user[0] : item.user;

    if (item.user_id) {
      activeUserMap.set(item.user_id, {
        id: item.user_id,
        name: profile?.username || "Active Member",
        avatarUrl: profile?.avatar_url || undefined,
        isPending: false,
      });

      if (!userAssignedMissionIds[item.user_id]) {
        userAssignedMissionIds[item.user_id] = [];
      }
      if (!userAssignedMissionIds[item.user_id].includes(item.mission_id)) {
        userAssignedMissionIds[item.user_id].push(item.mission_id);
      }
    }
  });

  const activeUsersList = Array.from(activeUserMap.values());
  const activeUserIds = activeUsersList.map((u) => u.id);

  // 4. Fetch All Tasks for Manager Missions
  const { data: rawTasks } = await supabase
    .from("tasks")
    .select(
      "id, user_id, title, desc, points, done, proof_notes, proof_image, proof_rating, mission_id_fk, created_at, time",
    )
    .in("mission_id_fk", managerMissionIds);

  const tasks = rawTasks || [];
  const managerTaskIds = tasks.map((t) => t.id);

  // 5. Fetch Activity Logs
  const startDate = getTimeframeStartDate(timeframe);
  let rawLogs: any[] = [];

  if (managerTaskIds.length > 0) {
    let logsQuery = supabase
      .from("activity_logs")
      .select("id, user_id, task_id, task, project, points, time, created_at")
      .in("task_id", managerTaskIds);

    if (startDate) {
      logsQuery = logsQuery.gte("created_at", startDate.toISOString());
    }

    const { data: logsData } = await logsQuery;
    rawLogs = logsData || [];
  }

  // Create Task ID to Mission ID mapping
  const taskToMissionMap = new Map<string, string>();
  tasks.forEach((t) => taskToMissionMap.set(t.id, t.mission_id_fk));

  // Group Logs by User & Mission
  const logsByUser = new Map<string, UserActivity[]>();
  const logsByMission = new Map<string, UserActivity[]>();

  rawLogs.forEach((l) => {
    const missionId = taskToMissionMap.get(l.task_id);
    const formattedLog: UserActivity = {
      id: l.id,
      task: l.task || "Completed Task",
      project: l.project || "General",
      points: l.points,
      timestamp: new Date(l.created_at).toLocaleDateString(),
      missionId,
    };

    if (!logsByUser.has(l.user_id)) logsByUser.set(l.user_id, []);
    logsByUser.get(l.user_id)!.push(formattedLog);

    if (missionId) {
      if (!logsByMission.has(missionId)) logsByMission.set(missionId, []);
      logsByMission.get(missionId)!.push(formattedLog);
    }
  });

  const tasksByUser = new Map<string, any[]>();
  tasks.forEach((t) => {
    if (!tasksByUser.has(t.user_id)) tasksByUser.set(t.user_id, []);
    tasksByUser.get(t.user_id)!.push(t);
  });

  // 6. Aggregate User & Mission Metrics
  const activities: Record<string, UserActivity[]> = {};
  const completionStats: Record<
    string,
    { done: number; total: number; pending: number; rate: number }
  > = {};
  const userMissions: Record<string, any[]> = {};
  const userXpTotal: Record<string, number> = {};

  activeUserIds.forEach((uid) => {
    const userLogs = logsByUser.get(uid) || [];
    activities[uid] = userLogs;

    const userTasks = tasksByUser.get(uid) || [];
    const total = userTasks.length;
    const doneTasks = userTasks.filter((t) => t.done);
    const done = doneTasks.length;

    const pendingTasks = userTasks.filter(
      (t) =>
        !t.done &&
        (t.proof_rating === null || t.proof_rating === undefined) &&
        (Boolean(t.proof_notes) || Boolean(t.proof_image) || t.desc !== ""),
    );

    completionStats[uid] = {
      done,
      total,
      pending: pendingTasks.length,
      rate: total > 0 ? Math.round((done / total) * 100) : 0,
    };

    userXpTotal[uid] = doneTasks.reduce(
      (acc, curr) => acc + (curr.points || 0),
      0,
    );

    const assignedIds = userAssignedMissionIds[uid] || [];
    userMissions[uid] = assignedIds.map((mId) => {
      const missionObj = managerMissions.find((m) => m.id === mId);
      const mTasks = userTasks.filter((t) => t.mission_id_fk === mId);
      const mDoneTasks = mTasks.filter((t) => t.done);

      return {
        id: mId,
        name: missionObj?.name || "Unknown Mission",
        progress:
          mTasks.length > 0
            ? Math.round((mDoneTasks.length / mTasks.length) * 100)
            : 0,
        tasksTotal: mTasks.length,
        tasksDone: mDoneTasks.length,
        xpEarned: mDoneTasks.reduce((acc, curr) => acc + (curr.points || 0), 0),
      };
    });
  });

  // 7. Overall Missions & Company Stats
  const missionOptions: MissionOption[] = [];
  const missionMembers: Record<string, MissionMemberBreakdown[]> = {};
  const missionActivities: Record<string, UserActivity[]> = {};

  let companyTasksTotal = tasks.length;
  let companyTasksDone = tasks.filter((t) => t.done).length;
  let companyXpTotal = tasks
    .filter((t) => t.done)
    .reduce((acc, curr) => acc + (curr.points || 0), 0);
  let completedMissionsCount = 0;

  managerMissions.forEach((m) => {
    const mTasks = tasks.filter((t) => t.mission_id_fk === m.id);
    const mDoneTasks = mTasks.filter((t) => t.done);
    const mRate =
      mTasks.length > 0
        ? Math.round((mDoneTasks.length / mTasks.length) * 100)
        : 0;

    const isMissionCompleted =
      !m.is_active ||
      (mTasks.length > 0 && mDoneTasks.length === mTasks.length);
    if (isMissionCompleted) completedMissionsCount++;

    missionOptions.push({
      id: m.id,
      name: m.name,
      isActive: m.is_active,
      tasksTotal: mTasks.length,
      tasksDone: mDoneTasks.length,
      xpEarned: mDoneTasks.reduce((acc, curr) => acc + (curr.points || 0), 0),
      completionRate: mRate,
    });

    missionActivities[m.id] = logsByMission.get(m.id) || [];

    const mMemberships = validMembers.filter(
      (mem: any) => mem.mission_id === m.id,
    );

    missionMembers[m.id] = mMemberships.map((mem: any) => {
      const profile = Array.isArray(mem.user) ? mem.user[0] : mem.user;
      const mUserTasks = mTasks.filter((t) => t.user_id === mem.user_id);
      const mUserDone = mUserTasks.filter((t) => t.done);

      return {
        userId: mem.user_id,
        name: profile?.username || "Active Member",
        assigned: mUserTasks.length,
        done: mUserDone.length,
        xp: mUserDone.reduce((acc, curr) => acc + (curr.points || 0), 0),
      };
    });
  });

  const companyStats: CompanyOverviewStats = {
    totalMissions: managerMissions.length,
    completedMissions: completedMissionsCount,
    remainingMissions: managerMissions.length - completedMissionsCount,
    totalTasks: companyTasksTotal,
    completedTasks: companyTasksDone,
    remainingTasks: companyTasksTotal - companyTasksDone,
    companyCompletionRate:
      companyTasksTotal > 0
        ? Math.round((companyTasksDone / companyTasksTotal) * 100)
        : 0,
    totalCompanyXp: companyXpTotal,
  };

  return {
    isManager: true,
    data: {
      company: companyStats,
      users: activeUsersList,
      missions: missionOptions,
      userXpTotal,
      activities,
      missionActivities,
      completionStats,
      userMissions,
      missionMembers,
      userAssignedMissionIds,
    },
  };
}
