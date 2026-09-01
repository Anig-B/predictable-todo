"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export interface TeamMember {
  id: string;
  userId: string;
  username: string;
  role: "member" | "manager";
  joinedAt: string;
  level: number;
  streak: number;
  weeklyXp: number;
  tasksAssigned: number;
  status: "active" | "pending";
}

export interface AvailableUser {
  id: string;
  username: string;
}

async function getOrCreateDefaultMission(supabase: any, managerId: string) {
  const { data: defaultMission } = await supabase
    .from("missions")
    .select("id")
    .eq("created_by", managerId)
    .eq("is_default", true)
    .maybeSingle();

  if (defaultMission?.id) return defaultMission.id;

  const { data: newMission, error: createErr } = await supabase
    .from("missions")
    .insert({
      name: "Starter Mission Pack",
      description: "Default onboarding mission pack",
      created_by: managerId,
      is_default: true,
      is_active: true,
    })
    .select("id")
    .single();

  if (createErr || !newMission?.id) {
    throw new Error(
      `Failed to create mission pack: ${createErr?.message || "Unknown error"}`,
    );
  }

  return newMission.id;
}

export async function getUsersPageData() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return {
      currentUserId: null,
      primaryMissionId: null,
      members: [],
      availableUsers: [],
    };
  }

  const userId = user.id;
  const primaryMissionId = await getOrCreateDefaultMission(supabase, userId);

  // Get all mission IDs created by this manager
  const { data: managerMissions } = await supabase
    .from("missions")
    .select("id")
    .eq("created_by", userId);

  const managerMissionIds = (managerMissions || []).map((m: any) => m.id);

  const [missionMembersRes, availableUsersRes] = await Promise.all([
    supabase
      .from("mission_members")
      .select(
        `
        mission_id,
        user_id,
        role,
        joined_at,
        user:profiles!user_id(username, role)
      `,
      )
      .eq("invited_by", userId),
    supabase
      .from("profiles")
      .select("id, username")
      .neq("role", "admin")
      .order("username", { ascending: true }),
  ]);

  if (missionMembersRes.error) throw missionMembersRes.error;
  if (availableUsersRes.error) throw availableUsersRes.error;

  const rawMembers = missionMembersRes.data || [];

  const memberUserIds = Array.from(
    new Set(
      rawMembers
        .filter((m: any) => {
          const profile = Array.isArray(m.user) ? m.user[0] : m.user;
          return m.user_id && (!profile || profile.role !== "admin");
        })
        .map((m: any) => m.user_id as string),
    ),
  );

  // Maps for calculations
  const weeklyXpMap = new Map<string, number>();
  const totalMissionXpMap = new Map<string, number>();
  const tasksCountMap = new Map<string, number>();
  const streakMap = new Map<string, number>();

  if (memberUserIds.length > 0 && managerMissionIds.length > 0) {
    const sevenDaysAgo = new Date(
      Date.now() - 7 * 24 * 60 * 60 * 1000,
    ).toISOString();

    // Query tasks matching member IDs AND manager mission IDs
    const { data: missionTasks, error: tasksErr } = await supabase
      .from("tasks")
      .select("id, user_id, points, done, streak, created_at")
      .in("user_id", memberUserIds)
      .in("mission_id_fk", managerMissionIds);

    if (tasksErr) throw tasksErr;

    (missionTasks || []).forEach((task: any) => {
      const uid = task.user_id;

      // 1. Task count assigned to user under these missions
      const count = tasksCountMap.get(uid) || 0;
      tasksCountMap.set(uid, count + 1);

      // 2. Max streak reached on mission tasks
      if (typeof task.streak === "number") {
        const currentStreak = streakMap.get(uid) || 0;
        if (task.streak > currentStreak) {
          streakMap.set(uid, task.streak);
        }
      }

      // 3. Calculated XP from completed tasks
      if (task.done) {
        const points = task.points || 0;

        // Total mission XP
        const totalXp = totalMissionXpMap.get(uid) || 0;
        totalMissionXpMap.set(uid, totalXp + points);

        // Weekly mission XP
        if (task.created_at && task.created_at >= sevenDaysAgo) {
          const weeklyXp = weeklyXpMap.get(uid) || 0;
          weeklyXpMap.set(uid, weeklyXp + points);
        }
      }
    });
  }

  const memberMap = new Map<string, TeamMember>();

  for (const member of rawMembers as any[]) {
    const profile = Array.isArray(member.user) ? member.user[0] : member.user;

    if (profile?.role === "admin") continue;

    const isActive = Boolean(member.joined_at);
    const weeklyXp = weeklyXpMap.get(member.user_id) || 0;
    const totalXp = totalMissionXpMap.get(member.user_id) || 0;
    const tasksAssigned = tasksCountMap.get(member.user_id) || 0;
    const streak = streakMap.get(member.user_id) || 0;

    // Mission Level: 100 XP per level (min level 1)
    const missionLevel = Math.max(1, Math.floor(totalXp / 100) + 1);

    const existing = memberMap.get(member.user_id);

    const formattedMember: TeamMember = {
      id: member.user_id,
      userId: member.user_id,
      username: profile?.username || "Pending Invite",
      role: member.role as "member" | "manager",
      joinedAt: isActive
        ? new Date(member.joined_at!).toLocaleDateString()
        : "Awaiting App Sync",
      level: missionLevel,
      streak,
      weeklyXp,
      tasksAssigned,
      status: isActive ? "active" : "pending",
    };

    if (!existing) {
      memberMap.set(member.user_id, formattedMember);
    } else {
      memberMap.set(member.user_id, {
        ...existing,
        role:
          existing.role === "manager" || member.role === "manager"
            ? "manager"
            : "member",
        status: existing.status === "active" || isActive ? "active" : "pending",
      });
    }
  }

  return {
    currentUserId: userId,
    primaryMissionId,
    members: Array.from(memberMap.values()),
    availableUsers: (availableUsersRes.data as AvailableUser[]) || [],
  };
}

export async function inviteTeamMember(arg1: string, arg2?: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Unauthorized");

  let targetMissionId: string;
  let targetUserId: string;

  if (arg2) {
    targetMissionId = arg1;
    targetUserId = arg2;
  } else {
    targetMissionId = await getOrCreateDefaultMission(supabase, user.id);
    targetUserId = arg1;
  }

  const { error } = await supabase.from("mission_members").insert({
    mission_id: targetMissionId,
    user_id: targetUserId,
    role: "member",
    invited_by: user.id,
    joined_at: null,
  });

  if (error) {
    if (error.code === "23505") {
      throw new Error("User is already assigned to this team mission.");
    }
    throw new Error(error.message);
  }

  revalidatePath("/users");
}

export async function removeTeamMember(
  targetUserId: string,
  missionId?: string,
) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Unauthorized");

  let targetMissionId = missionId;
  if (!targetMissionId) {
    targetMissionId = await getOrCreateDefaultMission(supabase, user.id);
  }

  const { error } = await supabase
    .from("mission_members")
    .delete()
    .eq("user_id", targetUserId)
    .eq("mission_id", targetMissionId);

  if (error) throw new Error(error.message);

  revalidatePath("/users");
}
