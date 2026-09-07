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
}

export interface PendingReview {
  id: string;
  taskId: string;
  task: string;
  mission: string;
  missionId: string;
  note: string;
  proofUrl?: string;
}

export interface ActiveMissionTask {
  id: string;
  title: string;
  status: "completed" | "pending_approval" | "due";
  dateText: string;
}

export interface ActiveMission {
  id: string;
  name: string;
  progress: number;
  tasks: ActiveMissionTask[];
}

export interface MissionOption {
  id: string;
  name: string;
  tasksTotal: number;
  tasksDone: number;
  xpEarned: number;
}

export interface MissionMemberBreakdown {
  name: string;
  assigned: number;
  done: number;
  xp: number;
  isPending: boolean;
}

export interface ReportsPayload {
  users: UserOption[];
  missions: MissionOption[];
  activities: Record<string, UserActivity[]>;
  completionStats: Record<
    string,
    { done: number; total: number; pending: number; rate: number }
  >;
  pendingReviews: Record<string, PendingReview[]>;
  userMissions: Record<string, ActiveMission[]>;
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
    d.setHours(d.getHours() - 24); // UPDATED: Rolling 24-hour window
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

  // 2. Fetch manager's active missions
  const { data: managerMissionsData } = await supabase
    .from("missions")
    .select("id, name, created_at, is_active")
    .eq("created_by", managerId)
    .eq("is_active", true);

  const managerMissions = managerMissionsData || [];
  const managerMissionIds = managerMissions.map((m) => m.id);

  if (managerMissionIds.length === 0) {
    return {
      isManager: true,
      data: {
        users: [],
        missions: [],
        activities: {},
        completionStats: {},
        pendingReviews: {},
        userMissions: {},
        missionMembers: {},
        userAssignedMissionIds: {},
      },
    };
  }

  // 3. Fetch joined mission members
  const { data: missionMembersRes, error: membersErr } = await supabase
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

  if (membersErr) {
    console.error("Error fetching mission members:", membersErr);
  }

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

  if (activeUserIds.length === 0) {
    return {
      isManager: true,
      data: {
        users: [],
        missions: managerMissions.map((m) => ({
          id: m.id,
          name: m.name,
          tasksTotal: 0,
          tasksDone: 0,
          xpEarned: 0,
        })),
        activities: {},
        completionStats: {},
        pendingReviews: {},
        userMissions: {},
        missionMembers: {},
        userAssignedMissionIds: {},
      },
    };
  }

  const startDate = getTimeframeStartDate(timeframe);

  // 4. Fetch All Tasks (UPDATED: Unfiltered by creation timeframe to retain task IDs)
  const { data: rawTasks, error: tasksErr } = await supabase
    .from("tasks")
    .select(
      "id, user_id, title, desc, points, done, proof_notes, proof_image, proof_rating, mission_id_fk, created_at, time",
    )
    .in("user_id", activeUserIds)
    .in("mission_id_fk", managerMissionIds);

  if (tasksErr) console.error("Error fetching tasks:", tasksErr);
  const tasks = rawTasks || [];
  const taskIds = tasks.map((t) => t.id);

  // 5. Fetch Activity Logs (UPDATED: Strictly apply timeframe filtering here)
  let rawLogs: any[] = [];
  if (taskIds.length > 0) {
    let logsQuery = supabase
      .from("activity_logs")
      .select("id, user_id, task_id, task, project, points, time, created_at")
      .in("user_id", activeUserIds)
      .in("task_id", taskIds);

    if (startDate) {
      logsQuery = logsQuery.gte("created_at", startDate.toISOString());
    }

    const { data: logsData, error: logsErr } = await logsQuery;
    if (logsErr) {
      console.error("Error fetching activity logs:", logsErr);
    } else {
      rawLogs = logsData || [];
    }
  }

  // Group logs by user_id
  const logsByUser = new Map<string, any[]>();
  rawLogs.forEach((l) => {
    if (!logsByUser.has(l.user_id)) logsByUser.set(l.user_id, []);
    logsByUser.get(l.user_id)!.push(l);
  });

  const tasksByUser = new Map<string, any[]>();
  tasks.forEach((t) => {
    if (!tasksByUser.has(t.user_id)) tasksByUser.set(t.user_id, []);
    tasksByUser.get(t.user_id)!.push(t);
  });

  // 6. Aggregate User Metrics
  const activities: Record<string, UserActivity[]> = {};
  const completionStats: Record<
    string,
    { done: number; total: number; pending: number; rate: number }
  > = {};
  const pendingReviews: Record<string, PendingReview[]> = {};
  const userMissions: Record<string, ActiveMission[]> = {};

  activeUserIds.forEach((uid) => {
    const userLogs = logsByUser.get(uid) || [];
    activities[uid] = userLogs.map((l) => ({
      id: l.id,
      task: l.task || "Completed Task",
      project: l.project || "General",
      points: l.points,
      timestamp: new Date(l.created_at).toLocaleDateString(),
    }));

    const userTasks = tasksByUser.get(uid) || [];
    const total = userTasks.length;
    const done = userTasks.filter((t) => t.done).length;

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

    pendingReviews[uid] = pendingTasks.map((pt) => ({
      id: pt.id,
      taskId: pt.id,
      task: pt.title,
      mission:
        managerMissions.find((m) => m.id === pt.mission_id_fk)?.name ||
        "General Mission",
      missionId: pt.mission_id_fk,
      note: pt.proof_notes || "",
      proofUrl: pt.proof_image || undefined,
    }));

    const assignedIds = userAssignedMissionIds[uid] || [];

    userMissions[uid] = assignedIds.map((mId) => {
      const missionObj = managerMissions.find((m) => m.id === mId);
      const mTasks = userTasks.filter((t) => t.mission_id_fk === mId);
      const mDone = mTasks.filter((t) => t.done).length;

      return {
        id: mId,
        name: missionObj?.name || "Unknown Mission",
        progress:
          mTasks.length > 0 ? Math.round((mDone / mTasks.length) * 100) : 0,
        tasks: mTasks.map((t) => {
          let status: "completed" | "pending_approval" | "due" = "due";
          if (t.done) status = "completed";
          else if (
            (t.proof_notes || t.proof_image) &&
            (t.proof_rating === null || t.proof_rating === undefined)
          ) {
            status = "pending_approval";
          }

          return {
            id: t.id,
            title: t.title,
            status,
            dateText: new Date(t.created_at).toLocaleDateString(),
          };
        }),
      };
    });
  });

  // 7. Aggregate Overall Mission Stats
  const missionOptions: MissionOption[] = [];
  const missionMembers: Record<string, MissionMemberBreakdown[]> = {};

  managerMissions.forEach((m) => {
    const mTasks = tasks.filter((t) => t.mission_id_fk === m.id);
    const mDoneTasks = mTasks.filter((t) => t.done);

    missionOptions.push({
      id: m.id,
      name: m.name,
      tasksTotal: mTasks.length,
      tasksDone: mDoneTasks.length,
      xpEarned: mDoneTasks.reduce((acc, curr) => acc + (curr.points || 0), 0),
    });

    const mMemberships = validMembers.filter(
      (mem: any) => mem.mission_id === m.id,
    );

    missionMembers[m.id] = mMemberships.map((mem: any) => {
      const profile = Array.isArray(mem.user) ? mem.user[0] : mem.user;
      const mUserTasks = mTasks.filter((t) => t.user_id === mem.user_id);
      const mUserDone = mUserTasks.filter((t) => t.done);

      return {
        name: profile?.username || "Active Member",
        assigned: mUserTasks.length,
        done: mUserDone.length,
        xp: mUserDone.reduce((acc, curr) => acc + (curr.points || 0), 0),
        isPending: !Boolean(mem.joined_at),
      };
    });
  });

  return {
    isManager: true,
    data: {
      users: activeUsersList,
      missions: missionOptions,
      activities,
      completionStats,
      pendingReviews,
      userMissions,
      missionMembers,
      userAssignedMissionIds,
    },
  };
}
