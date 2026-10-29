"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { constructDueAtTimestamp } from "@/lib/utils";

// --- Types ---

export interface MissionWithStats {
  id: string;
  name: string;
  description: string | null;
  active: boolean;
  questsTotal: number;
  questsDone: number;
  memberCount: number;
}

export interface ArchivedMission {
  id: string;
  name: string;
}

export interface Mission {
  id: string;
  name: string;
  description: string | null;
  created_by: string;
  is_active: boolean;
  created_at: string;
}

export interface Task {
  id: string;
  mission_id_fk: string | null;
  user_id: string | null;
  title: string;
  desc: string | null;
  time?: string | null;
  due_at?: string | null;
  points: number;
  priority?: number;
  recurring?: number;
  weeklyDay?: number | null;
  monthlyDay?: number | null;
  status?: "active" | "pending_review" | "completed" | "expired";
  is_active?: boolean;
  done: boolean;
  proof_notes?: string | null;
  proof_image?: string | null;
  lastCompletedAt?: string | null;
  assigned_user?: {
    username: string;
  } | null;
  created_at?: string;
}

export interface MissionMember {
  user_id: string;
  username: string;
  role: string;
  joined_at: string | null;
}

// --- List View Actions (/missions) ---

export async function getMissionsData() {
  const supabase = await createClient();

  const [activeRes, archivedRes] = await Promise.all([
    supabase
      .from("missions")
      .select(
        `
        id,
        name,
        description,
        is_active,
        created_at,
        tasks:tasks!tasks_mission_id_fk_fkey ( id, done, is_active ),
        mission_members!left ( user_id )
      `,
      )
      .eq("is_active", true)
      .eq("is_default", false) // Excludes default starter pack
      .order("created_at", { ascending: false }),
    supabase
      .from("missions")
      .select("id, name")
      .eq("is_active", false)
      .eq("is_default", false) // Excludes default starter pack
      .order("created_at", { ascending: false }),
  ]);

  if (activeRes.error) throw activeRes.error;
  if (archivedRes.error) throw archivedRes.error;

  const formattedMissions: MissionWithStats[] = (activeRes.data || []).map(
    (m: any) => {
      const taskList = Array.isArray(m.tasks)
        ? m.tasks.filter((t: any) => t.is_active !== false)
        : [];
      const memberList = Array.isArray(m.mission_members)
        ? m.mission_members
        : [];

      return {
        id: m.id,
        name: m.name,
        description: m.description || "",
        active: Boolean(m.is_active),
        questsTotal: taskList.length,
        questsDone: taskList.filter((t: any) => Boolean(t.done)).length,
        memberCount: memberList.length,
      };
    },
  );

  return {
    activeMissions: formattedMissions,
    archivedMissions: (archivedRes.data as ArchivedMission[]) || [],
  };
}

export async function toggleMissionArchiveStatus(
  id: string,
  isActive: boolean,
) {
  const supabase = await createClient();

  const { data: mission } = await supabase
    .from("missions")
    .select("is_default")
    .eq("id", id)
    .single();

  if (mission?.is_default) {
    throw new Error("Default Starter Packs cannot be archived.");
  }

  const { error } = await supabase
    .from("missions")
    .update({ is_active: isActive })
    .eq("id", id);

  if (error) throw new Error(error.message);
  revalidatePath("/missions");
}

export async function deleteMissionPermanently(id: string) {
  const supabase = await createClient();

  const { data: mission } = await supabase
    .from("missions")
    .select("is_default")
    .eq("id", id)
    .single();

  if (mission?.is_default) {
    throw new Error("Default Starter Packs cannot be deleted.");
  }

  await supabase.from("tasks").delete().eq("mission_id_fk", id);
  await supabase.from("mission_members").delete().eq("mission_id", id);

  const { data, error } = await supabase
    .from("missions")
    .delete()
    .eq("id", id)
    .select();

  if (error) throw new Error(error.message);
  if (!data || data.length === 0) {
    throw new Error("Delete blocked by Row Level Security policies.");
  }

  revalidatePath("/missions");
}

// --- Detail View Actions (/missions/[id]) ---

export async function getMissionById(id: string): Promise<Mission | null> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("missions")
    .select("*")
    .eq("id", id)
    .single();

  if (error) return null;
  return data;
}

export async function getMissionTasksAndMembers(missionId: string) {
  const supabase = await createClient();

  const [tasksRes, membersRes] = await Promise.all([
    supabase
      .from("tasks")
      .select(`*, assigned_user:profiles!user_id(username)`)
      .eq("mission_id_fk", missionId)
      .eq("is_active", true), // Only pull active tasks
    supabase
      .from("mission_members")
      .select(`user_id, role, joined_at, profiles!user_id(username)`)
      .eq("mission_id", missionId),
  ]);

  if (tasksRes.error) throw tasksRes.error;
  if (membersRes.error) throw membersRes.error;

  const formattedMembers: MissionMember[] = (membersRes.data || []).map(
    (m: any) => ({
      user_id: m.user_id,
      username: m.profiles?.username || "Unknown User",
      role: m.role || "member",
      joined_at: m.joined_at,
    }),
  );

  return {
    tasks: (tasksRes.data as Task[]) || [],
    members: formattedMembers,
  };
}

export async function createMissionTasks(rawTasks: any[], missionId: string) {
  const supabase = await createClient();

  // Map incoming UI task representations to include due_at, status, is_active, weeklyDay, and monthlyDay flags
  const formattedTasks = rawTasks.map((t) => ({
    ...t,
    due_at: t.due_at || constructDueAtTimestamp(t.time),
    status: t.status || "active",
    is_active: t.is_active ?? true,
    weeklyDay: t.recurring === 2 ? (t.weeklyDay ?? null) : null, // 2 = Weekly
    monthlyDay: t.recurring === 3 ? (t.monthlyDay ?? null) : null, // 3 = Monthly
  }));

  const assignedUserIds = Array.from(
    new Set(formattedTasks.map((t) => t.user_id).filter(Boolean)),
  );

  if (assignedUserIds.length > 0) {
    const { data: acceptedMembers, error: checkErr } = await supabase
      .from("mission_members")
      .select("user_id")
      .eq("mission_id", missionId)
      .in("user_id", assignedUserIds)
      .not("joined_at", "is", null);

    if (checkErr) throw new Error(checkErr.message);

    const acceptedUserIds = new Set(
      (acceptedMembers || []).map((m: any) => m.user_id),
    );

    const invalidAssignment = assignedUserIds.find(
      (uid) => !acceptedUserIds.has(uid),
    );

    if (invalidAssignment) {
      throw new Error(
        "Cannot assign task: One or more selected users have not accepted their team invitation yet.",
      );
    }
  }

  const { error } = await supabase.from("tasks").insert(formattedTasks);
  if (error) throw new Error(error.message);

  // --- TRIGGER NOTIFICATIONS FOR ASSIGNED TASKS ---
  try {
    const { data: missionData } = await supabase
      .from("missions")
      .select("name")
      .eq("id", missionId)
      .single();

    const missionName = missionData?.name || "a mission";

    const notificationsData = formattedTasks.map((task) => ({
      user_id: task.user_id,
      title: "New Task Assigned 🎯",
      message: `You were assigned a new task "${task.title}" in mission "${missionName}"`,
      type: "system",
      metadata: { task_id: task.id, mission_id: missionId },
      is_read: false,
    }));

    if (notificationsData.length > 0) {
      const { error: notifError } = await supabase
        .from("notifications")
        .insert(notificationsData);

      if (notifError) {
        console.error("Failed to insert notifications:", notifError.message);
      }
    }
  } catch (notifErr) {
    console.error("Error creating notifications:", notifErr);
  }

  revalidatePath(`/missions/${missionId}`);
}

export async function deleteMissionTaskGroup(
  taskIds: string[],
  missionId: string,
) {
  const supabase = await createClient();
  const { error } = await supabase.from("tasks").delete().in("id", taskIds);
  if (error) throw new Error(error.message);
  revalidatePath(`/missions/${missionId}`);
}

// --- Proof Review Actions ---

export async function approveProof(task: Task, feedback?: string) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Unauthorized");

  // 1. Record approved review entry (Fires database trigger `trg_handle_proof_approval`)
  const { error: reviewErr } = await supabase.from("proof_reviews").insert({
    task_id: task.id,
    reviewed_by: user.id,
    approved: true,
    feedback: feedback?.trim() || null,
  });
  if (reviewErr) throw new Error(reviewErr.message);

  // 2. Mark task completed (Database trigger awards XP & creates activity_logs)
  const { error: taskErr } = await supabase
    .from("tasks")
    .update({
      done: true,
      status: "completed",
      lastCompletedAt: new Date().toISOString(),
    })
    .eq("id", task.id);

  if (taskErr) throw new Error(taskErr.message);

  if (task.mission_id_fk) {
    revalidatePath(`/missions/${task.mission_id_fk}`);
  }
  revalidatePath("/dashboard");
}

export async function rejectProof(task: Task, feedback?: string) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Unauthorized");

  // 1. Record rejection review entry
  const { error: reviewErr } = await supabase.from("proof_reviews").insert({
    task_id: task.id,
    reviewed_by: user.id,
    approved: false,
    feedback: feedback?.trim() || null,
  });
  if (reviewErr) throw new Error(reviewErr.message);

  // 2. Reset proof details so user can resubmit
  const { error: resetErr } = await supabase
    .from("tasks")
    .update({
      proof_image: null,
      proof_notes: null,
      status: "active",
      done: false,
    })
    .eq("id", task.id);

  if (resetErr) throw new Error(resetErr.message);

  if (task.mission_id_fk) {
    revalidatePath(`/missions/${task.mission_id_fk}`);
  }
  revalidatePath("/dashboard");
}

// --- Mission Member Management Actions ---

export async function addMemberToMission(missionId: string, userId: string) {
  const supabase = await createClient();

  const {
    data: { user: manager },
  } = await supabase.auth.getUser();

  if (!manager) throw new Error("Unauthorized");

  const { error } = await supabase.from("mission_members").insert({
    mission_id: missionId,
    user_id: userId,
    invited_by: manager.id,
    joined_at: new Date().toISOString(),
  });

  if (error) throw new Error(error.message);

  const { data: missionData } = await supabase
    .from("missions")
    .select("name")
    .eq("id", missionId)
    .single();

  await supabase.from("notifications").insert({
    user_id: userId,
    title: "New Mission Briefing 🚀",
    message: `You have been added to the mission: "${missionData?.name || "Unknown Mission"}"`,
    type: "system",
    metadata: { mission_id: missionId },
    is_read: false,
  });

  revalidatePath(`/missions/${missionId}`);
}

export async function removeMemberFromMission(
  missionId: string,
  userId: string,
) {
  const supabase = await createClient();

  const {
    data: { user: manager },
  } = await supabase.auth.getUser();

  if (!manager) throw new Error("Unauthorized");

  const { error: taskDeleteError } = await supabase
    .from("tasks")
    .delete()
    .eq("mission_id_fk", missionId)
    .eq("user_id", userId);

  if (taskDeleteError) {
    throw new Error(`Failed to delete user tasks: ${taskDeleteError.message}`);
  }

  const { error: memberDeleteError } = await supabase
    .from("mission_members")
    .delete()
    .eq("mission_id", missionId)
    .eq("user_id", userId);

  if (memberDeleteError) {
    throw new Error(`Failed to remove member: ${memberDeleteError.message}`);
  }

  revalidatePath(`/missions/${missionId}`);
  return { success: true };
}
