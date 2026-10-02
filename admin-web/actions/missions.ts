"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

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
  points: number;
  priority?: number;
  recurring?: number;
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
        tasks:tasks!tasks_mission_id_fk_fkey ( id, done ),
        mission_members!left ( user_id )
      `,
      )
      .eq("is_active", true)
      .eq("is_default", false) // Excludes system default starter pack
      .order("created_at", { ascending: false }),
    supabase
      .from("missions")
      .select("id, name")
      .eq("is_active", false)
      .eq("is_default", false) // Excludes system default starter pack
      .order("created_at", { ascending: false }),
  ]);

  if (activeRes.error) throw activeRes.error;
  if (archivedRes.error) throw archivedRes.error;

  const formattedMissions: MissionWithStats[] = (activeRes.data || []).map(
    (m: any) => {
      const taskList = Array.isArray(m.tasks) ? m.tasks : [];
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

  // Guard against modifying default packs
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

  // Guard against deleting default packs
  const { data: mission } = await supabase
    .from("missions")
    .select("is_default")
    .eq("id", id)
    .single();

  if (mission?.is_default) {
    throw new Error("Default Starter Packs cannot be deleted.");
  }

  // Delete matching tasks via FK reference mission_id_fk
  await supabase.from("tasks").delete().eq("mission_id_fk", id);
  await supabase.from("mission_members").delete().eq("mission_id", id);

  const { data, error } = await supabase
    .from("missions")
    .delete()
    .eq("id", id)
    .select();

  if (error) throw new Error(error.message);
  if (!data || data.length === 0) {
    throw new Error("Delete blocked by database Row Level Security policies.");
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

  // --- AUTO-RESET STALE RECURRING TASKS ---
  const todayStr = new Date().toISOString().split("T")[0]; // YYYY-MM-DD

  const { data: completedRecurring } = await supabase
    .from("tasks")
    .select("id, lastCompletedAt, recurring, done")
    .eq("mission_id_fk", missionId)
    .eq("done", true)
    .gt("recurring", 0);

  if (completedRecurring && completedRecurring.length > 0) {
    const staleTaskIds: string[] = [];

    for (const t of completedRecurring) {
      if (!t.lastCompletedAt) {
        staleTaskIds.push(t.id);
        continue;
      }
      const lastDate = t.lastCompletedAt.split("T")[0];
      // If completed on a previous day, reset for the new cycle
      if (lastDate < todayStr) {
        staleTaskIds.push(t.id);
      }
    }

    if (staleTaskIds.length > 0) {
      await supabase
        .from("tasks")
        .update({
          done: false,
          proof_image: null,
          proof_notes: null,
          proof_rating: null,
        })
        .in("id", staleTaskIds);
    }
  }
  // ----------------------------------------

  const [tasksRes, membersRes] = await Promise.all([
    supabase
      .from("tasks")
      .select(`*, assigned_user:profiles!user_id(username)`)
      .eq("mission_id_fk", missionId),
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

export async function createMissionTasks(tasks: any[], missionId: string) {
  const supabase = await createClient();

  // Extract non-null unique user IDs assigned in this batch
  const assignedUserIds = Array.from(
    new Set(tasks.map((t) => t.user_id).filter(Boolean)),
  );

  if (assignedUserIds.length > 0) {
    // Verify that every assigned user has an accepted invitation (joined_at is not null)
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

  const { error } = await supabase.from("tasks").insert(tasks);
  if (error) throw new Error(error.message);

  // --- TRIGGER NOTIFICATIONS FOR ASSIGNED TASKS ---
  try {
    const { data: missionData } = await supabase
      .from("missions")
      .select("name")
      .eq("id", missionId)
      .single();

    const missionName = missionData?.name || "a mission";

    const notificationsData = tasks.map((task) => ({
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
  // ------------------------------------------------

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

  // 1. Record approved review in database
  const { error: reviewErr } = await supabase.from("proof_reviews").insert({
    task_id: task.id,
    reviewed_by: user.id,
    approved: true,
    feedback: feedback?.trim() || null,
  });
  if (reviewErr) throw new Error(reviewErr.message);

  // 2. Mark task as completed & record completion timestamp for recurring tracker
  const { error: taskErr } = await supabase
    .from("tasks")
    .update({
      done: true,
      lastCompletedAt: new Date().toISOString(),
    })
    .eq("id", task.id);
  if (taskErr) throw new Error(taskErr.message);

  if (task.user_id) {
    // 3. Increment profile XP
    const { data: profile } = await supabase
      .from("profiles")
      .select("xp")
      .eq("id", task.user_id)
      .single();

    if (profile) {
      await supabase
        .from("profiles")
        .update({ xp: (profile.xp || 0) + task.points })
        .eq("id", task.user_id);
    }

    // 4. Increment user_stats
    const { data: stats } = await supabase
      .from("user_stats")
      .select("xp, total_lifetime_tasks")
      .eq("user_id", task.user_id)
      .single();

    if (stats) {
      await supabase
        .from("user_stats")
        .update({
          xp: (stats.xp || 0) + task.points,
          total_lifetime_tasks: (stats.total_lifetime_tasks || 0) + 1,
        })
        .eq("user_id", task.user_id);
    }

    // 5. Insert activity log
    await supabase.from("activity_logs").insert({
      user_id: task.user_id,
      task: task.title,
      points: task.points,
      time: new Date().toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      }),
      icon: "ShieldCheck",
      task_id: task.id,
      image_url: task.proof_image,
    });
  }

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

  // 1. Record rejection review entry in database
  const { error: reviewErr } = await supabase.from("proof_reviews").insert({
    task_id: task.id,
    reviewed_by: user.id,
    approved: false,
    feedback: feedback?.trim() || null,
  });
  if (reviewErr) throw new Error(reviewErr.message);

  // 2. Soft Reset: Clear current proof so member can resubmit
  const { error: resetErr } = await supabase
    .from("tasks")
    .update({
      proof_image: null,
      proof_notes: null,
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

  // 1. Insert member into mission_members
  const { error } = await supabase.from("mission_members").insert({
    mission_id: missionId,
    user_id: userId,
    invited_by: manager.id,
    joined_at: new Date().toISOString(),
  });

  if (error) throw new Error(error.message);

  // 2. Fetch mission name for the message
  const { data: missionData } = await supabase
    .from("missions")
    .select("name")
    .eq("id", missionId)
    .single();

  // 3. Send notification to the user
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

  // 1. Delete tasks assigned to this user inside this mission
  const { error: taskDeleteError } = await supabase
    .from("tasks")
    .delete()
    .eq("mission_id_fk", missionId)
    .eq("user_id", userId);

  if (taskDeleteError) {
    throw new Error(`Failed to delete user tasks: ${taskDeleteError.message}`);
  }

  // 2. Remove the user from mission_members
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
