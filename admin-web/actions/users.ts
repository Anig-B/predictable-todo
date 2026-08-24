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
  status: "active" | "pending";
}

export interface AvailableUser {
  id: string;
  username: string;
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

  // Run initial lookup queries in parallel
  const [managedMissionRes, missionMembersRes, availableUsersRes] =
    await Promise.all([
      supabase
        .from("mission_members")
        .select("mission_id")
        .eq("user_id", userId)
        .eq("role", "manager")
        .limit(1)
        .maybeSingle(),
      supabase
        .from("mission_members")
        .select(
          `
          mission_id,
          user_id,
          role,
          joined_at,
          user:profiles!user_id(username, level, streak, role)
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

  // Extract non-null, non-admin user IDs for single batch fetch
  const memberUserIds = Array.from(
    new Set(
      rawMembers
        .filter((m: any) => {
          const profile = Array.isArray(m.user) ? m.user[0] : m.user;
          return m.user_id && profile?.role !== "admin";
        })
        .map((m: any) => m.user_id as string),
    ),
  );

  // Batch fetch all weekly_xp in ONE query instead of an N+1 loop
  let statsMap = new Map<string, number>();
  if (memberUserIds.length > 0) {
    const { data: statsData } = await supabase
      .from("user_stats")
      .select("user_id, weekly_xp")
      .in("user_id", memberUserIds);

    (statsData || []).forEach((s: any) => {
      statsMap.set(s.user_id, s.weekly_xp || 0);
    });
  }

  // Aggregate and format team members map
  const memberMap = new Map<string, TeamMember>();

  for (const member of rawMembers as any[]) {
    const profile = Array.isArray(member.user) ? member.user[0] : member.user;

    if (!member.user_id || profile?.role === "admin") continue;

    const isActive = Boolean(member.joined_at);
    const weeklyXp = statsMap.get(member.user_id) || 0;
    const existing = memberMap.get(member.user_id);

    const formattedMember: TeamMember = {
      id: member.user_id,
      userId: member.user_id,
      username: profile?.username || "Pending Registration",
      role: member.role as "member" | "manager",
      joinedAt: isActive
        ? new Date(member.joined_at!).toLocaleDateString()
        : "Awaiting App Sync",
      level: profile?.level || 1,
      streak: profile?.streak || 0,
      weeklyXp,
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
    primaryMissionId: managedMissionRes.data?.mission_id || null,
    members: Array.from(memberMap.values()),
    availableUsers: (availableUsersRes.data as AvailableUser[]) || [],
  };
}

export async function inviteTeamMember(
  missionId: string,
  invitedUserId: string,
) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Unauthorized");

  const { error } = await supabase.from("mission_members").insert({
    mission_id: missionId,
    user_id: invitedUserId,
    role: "member",
    invited_by: user.id,
    joined_at: null,
  });

  if (error) throw new Error(error.message);
  revalidatePath("/users");
}

export async function updateTeamMemberRole(
  targetUserId: string,
  newRole: "member" | "manager",
) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Unauthorized");

  const { error } = await supabase
    .from("mission_members")
    .update({ role: newRole })
    .eq("user_id", targetUserId)
    .eq("invited_by", user.id);

  if (error) throw new Error(error.message);
  revalidatePath("/users");
}

export async function removeTeamMember(targetUserId: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Unauthorized");

  const { error } = await supabase
    .from("mission_members")
    .delete()
    .eq("user_id", targetUserId)
    .eq("invited_by", user.id);

  if (error) throw new Error(error.message);
  revalidatePath("/users");
}
