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
      .order("created_at", { ascending: false }),
    supabase
      .from("missions")
      .select("id, name")
      .eq("is_active", false)
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
  const { error } = await supabase
    .from("missions")
    .update({ is_active: isActive })
    .eq("id", id);

  if (error) throw new Error(error.message);
  revalidatePath("/missions");
}

export async function deleteMissionPermanently(id: string) {
  const supabase = await createClient();

  await supabase.from("tasks").delete().eq("mission_id", id);
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
  const { error } = await supabase.from("tasks").insert(tasks);
  if (error) throw new Error(error.message);
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
