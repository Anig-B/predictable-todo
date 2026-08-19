"use client";

import { use, useEffect, useState, useCallback } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import {
  ArrowLeft,
  Loader2,
  Target,
  Users,
  ShieldCheck,
  Plus,
  Trash2,
  X,
  CheckCircle2,
  Clock,
  FileCheck,
} from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import {
  TaskCard,
  TaskRow,
  AssignableUser,
  PRIORITY_XP,
} from "@/components/create-task";
import { MissionProofsTab } from "@/components/mission-proofs-tab";

// --- Database Interfaces ---
interface Mission {
  id: string;
  name: string;
  description: string | null;
  created_by: string;
  is_active: boolean;
  created_at: string;
}

interface Task {
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

interface MissionMember {
  user_id: string;
  username: string;
  role: string;
  joined_at: string | null;
}

export default function MissionDetailPage({
  params: paramsPromise,
}: {
  params: Promise<{ id: string }>;
}) {
  const params = use(paramsPromise);
  const router = useRouter();
  const supabase = createClient();

  const [mission, setMission] = useState<Mission | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<"members" | "tasks" | "proofs">(
    "tasks",
  );

  useEffect(() => {
    async function fetchMissionDetail() {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from("missions")
          .select("*")
          .eq("id", params.id)
          .single();

        if (error) throw error;
        setMission(data);
      } catch (err: any) {
        toast.error(err?.message || "Could not load mission details");
      } finally {
        setLoading(false);
      }
    }

    if (params.id) {
      fetchMissionDetail();
    }
  }, [params.id, supabase]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-3">
        <Loader2 className="w-8 h-8 animate-spin text-gray-500" />
        <p className="text-sm text-gray-400">Loading mission details...</p>
      </div>
    );
  }

  if (!mission) {
    return (
      <div className="p-8 max-w-xl mx-auto text-center space-y-4">
        <h2 className="text-xl font-semibold text-gray-800">
          Mission Not Found
        </h2>
        <p className="text-sm text-gray-500">
          The requested mission pack does not exist or you do not have
          permission to view it.
        </p>
        <Button
          onClick={() => router.push("/missions")}
          variant="outline"
          className="border-[#e8e3db]"
        >
          Return to Missions
        </Button>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <button
            onClick={() => router.back()}
            className="p-2 hover:bg-[#f0ebe4] rounded-md transition-colors cursor-pointer"
            title="Go back"
          >
            <ArrowLeft className="w-5 h-5 text-[#6b6b6b]" />
          </button>
          <div>
            <div className="flex items-center gap-3">
              <h1 className="text-3xl font-semibold text-[#1a1a1a]">
                {mission.name}
              </h1>
              <span
                className={`text-xs px-2.5 py-0.5 rounded-full font-medium ${
                  mission.is_active
                    ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                    : "bg-gray-100 text-gray-600 border border-gray-200"
                }`}
              >
                {mission.is_active ? "Active" : "Archived"}
              </span>
            </div>
            {mission.description && (
              <p className="text-sm text-gray-500 mt-1 max-w-2xl">
                {mission.description}
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-8 border-b border-[#e8e3db]">
        <button
          onClick={() => setActiveTab("tasks")}
          className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors cursor-pointer ${
            activeTab === "tasks"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          <Target className="w-4 h-4" />
          Tasks
        </button>
        <button
          onClick={() => setActiveTab("members")}
          className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors cursor-pointer ${
            activeTab === "members"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          <Users className="w-4 h-4" />
          Members
        </button>
        <button
          onClick={() => setActiveTab("proofs")}
          className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors cursor-pointer ${
            activeTab === "proofs"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          <ShieldCheck className="w-4 h-4" />
          Proof Verification
        </button>
      </div>

      {/* Dynamic Tab Rendering */}
      <div className="bg-white border border-[#e8e3db] rounded-xl p-6 shadow-xs">
        {activeTab === "tasks" && (
          <MissionTasksSection missionId={mission.id} />
        )}
        {activeTab === "members" && (
          <MissionMembersSection missionId={mission.id} />
        )}
        {activeTab === "proofs" && <MissionProofsTab missionId={mission.id} />}
      </div>
    </div>
  );
}

// --- Tasks Tab Section ---
function MissionTasksSection({ missionId }: { missionId: string }) {
  const supabase = createClient();

  const [tasks, setTasks] = useState<Task[]>([]);
  const [members, setMembers] = useState<MissionMember[]>([]);
  const [loading, setLoading] = useState(true);

  // Modal State
  const [showModal, setShowModal] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const [taskRow, setTaskRow] = useState<TaskRow>({
    key: crypto.randomUUID(),
    title: "",
    desc: "",
    time: "09:00",
    priority: 1,
    points: PRIORITY_XP[1],
    recurring: 0,
    assignMode: "all",
    assigneeIds: [],
  });

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);

      // Run both queries simultaneously instead of awaiting sequentially
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

      setTasks(tasksRes.data || []);
      setMembers(
        (membersRes.data || []).map((m: any) => ({
          user_id: m.user_id,
          username: m.profiles?.username || "Unknown User",
          role: m.role || "member",
          joined_at: m.joined_at,
        })),
      );
    } catch (err: any) {
      toast.error(err?.message || "Failed to load tasks");
    } finally {
      setLoading(false);
    }
  }, [missionId, supabase]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleSaveTask = async () => {
    if (!taskRow.title.trim()) {
      toast.error("Task title is required");
      return;
    }

    try {
      setSubmitting(true);
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error("Authenticated user required");

      const assignees =
        taskRow.assignMode === "all"
          ? members.map((m) => m.user_id)
          : taskRow.assigneeIds.length > 0
            ? taskRow.assigneeIds
            : [user.id];

      const newTasks = assignees.map((targetUserId) => ({
        id: crypto.randomUUID(),
        mission_id: missionId,
        mission_id_fk: missionId,
        user_id: targetUserId,
        title: taskRow.title.trim(),
        desc: taskRow.desc.trim() || null,
        time: taskRow.time || null,
        priority: taskRow.priority,
        recurring: taskRow.recurring,
        points: taskRow.points,
        done: false,
      }));

      const { error } = await supabase.from("tasks").insert(newTasks);
      if (error) throw error;

      toast.success("Task created");
      setShowModal(false);
      fetchData();
    } catch (err: any) {
      toast.error(err?.message || "Could not save task");
    } finally {
      setSubmitting(false);
    }
  };

  const handleDeleteGroup = async (taskIds: string[]) => {
    try {
      const { error } = await supabase.from("tasks").delete().in("id", taskIds);
      if (error) throw error;
      toast.success("Task deleted");
      fetchData();
    } catch (err: any) {
      toast.error(err?.message || "Could not delete task");
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center p-8">
        <Loader2 className="w-6 h-6 animate-spin text-gray-400" />
      </div>
    );
  }

  const assignableMembers: AssignableUser[] = members.map((m) => ({
    id: m.user_id,
    username: m.username,
  }));

  type GroupedTask = {
    groupKey: string;
    ids: string[];
    title: string;
    desc: string | null;
    time?: string | null;
    points: number;
    assignees: string[];
    allDone: boolean;
    hasPendingProof: boolean;
    created_at?: string;
  };

  const groupedTasksMap = new Map<string, GroupedTask>();

  tasks.forEach((task) => {
    const key = `${task.title}-${task.desc ?? ""}-${task.time ?? ""}-${task.points}`;
    const username = task.assigned_user?.username || "Unassigned";
    const isProofSubmitted = Boolean(
      !task.done && (task.proof_image || task.proof_notes),
    );

    if (!groupedTasksMap.has(key)) {
      groupedTasksMap.set(key, {
        groupKey: key,
        ids: [task.id],
        title: task.title,
        desc: task.desc,
        time: task.time,
        points: task.points,
        assignees: [username],
        allDone: task.done,
        hasPendingProof: isProofSubmitted,
        created_at: task.created_at,
      });
    } else {
      const current = groupedTasksMap.get(key)!;
      current.ids.push(task.id);
      if (!current.assignees.includes(username)) {
        current.assignees.push(username);
      }
      if (!task.done) {
        current.allDone = false;
      }
      if (isProofSubmitted) {
        current.hasPendingProof = true;
      }
    }
  });

  const groupedTasks = Array.from(groupedTasksMap.values());

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-gray-800">Mission Tasks</h3>
        <Button
          onClick={() => {
            setTaskRow({
              key: crypto.randomUUID(),
              title: "",
              desc: "",
              time: "09:00",
              priority: 1,
              points: PRIORITY_XP[1],
              recurring: 0,
              assignMode: "all",
              assigneeIds: [],
            });
            setShowModal(true);
          }}
          className="bg-[#1a1a1a] text-white hover:bg-[#333333] flex items-center gap-2 text-xs cursor-pointer"
        >
          <Plus className="w-4 h-4" /> Add Task
        </Button>
      </div>

      {groupedTasks.length === 0 ? (
        <div className="text-center py-8 border border-dashed rounded-lg border-gray-200">
          <p className="text-sm text-gray-400">
            No tasks created yet for this mission pack.
          </p>
        </div>
      ) : (
        <div className="grid gap-3">
          {groupedTasks.map((group) => {
            // Determine badge configuration according to task state
            let badgeStyle = "bg-amber-50 text-amber-700 border-amber-200";
            let badgeIcon = <Clock className="w-3 h-3" />;
            let badgeText = "Pending";

            if (group.allDone) {
              badgeStyle = "bg-emerald-50 text-emerald-700 border-emerald-200";
              badgeIcon = <CheckCircle2 className="w-3 h-3" />;
              badgeText = "Done";
            } else if (group.hasPendingProof) {
              badgeStyle = "bg-blue-50 text-blue-700 border-blue-200";
              badgeIcon = <FileCheck className="w-3 h-3" />;
              badgeText = "Proof Pending";
            }

            return (
              <div
                key={group.groupKey}
                className="flex items-center justify-between p-4 border border-[#e8e3db] rounded-lg bg-[#fafaf9]"
              >
                <div className="space-y-1">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="font-medium text-[#1a1a1a]">
                      {group.title}
                    </span>

                    <span
                      className={`inline-flex items-center gap-1 text-[10px] px-2 py-0.5 rounded-full font-medium border ${badgeStyle}`}
                    >
                      {badgeIcon} {badgeText}
                    </span>

                    <span className="text-[10px] bg-black text-[#ffffff] px-1.5 py-0.5 rounded font-bold">
                      {group.points} XP
                    </span>
                    {group.time && (
                      <span className="text-[10px] bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded border border-gray-200">
                        {group.time}
                      </span>
                    )}
                  </div>
                  {group.desc && (
                    <p className="text-xs text-gray-500">{group.desc}</p>
                  )}
                  <div className="flex items-center gap-3 text-[11px] text-gray-400 flex-wrap">
                    <span>Assigned to: {group.assignees.join(", ")}</span>

                    {group.created_at && (
                      <span>
                        • Created:{" "}
                        {new Date(group.created_at).toLocaleString([], {
                          dateStyle: "short",
                          timeStyle: "short",
                        })}
                      </span>
                    )}
                  </div>
                </div>
                <button
                  onClick={() => handleDeleteGroup(group.ids)}
                  className="p-1.5 text-gray-400 hover:text-rose-600 rounded cursor-pointer"
                  title="Delete task group"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            );
          })}
        </div>
      )}

      {/* Task Creation Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/30 z-50 flex items-center justify-center p-4 backdrop-blur-xs">
          <div className="bg-white border border-[#e8e3db] rounded-xl max-w-lg w-full p-6 space-y-4 shadow-xl">
            <div className="flex items-center justify-between border-b pb-3">
              <h3 className="font-semibold text-gray-800">Add New Task</h3>
              <button
                onClick={() => setShowModal(false)}
                className="cursor-pointer"
              >
                <X className="w-5 h-5 text-gray-400" />
              </button>
            </div>

            <TaskCard
              task={taskRow}
              index={0}
              memberList={assignableMembers}
              canRemove={false}
              saving={submitting}
              onUpdate={(_, patch) =>
                setTaskRow((prev) => ({ ...prev, ...patch }))
              }
              onRemove={() => {}}
              onToggleAssignee={(_, userId) => {
                setTaskRow((prev) => {
                  const exists = prev.assigneeIds.includes(userId);
                  return {
                    ...prev,
                    assigneeIds: exists
                      ? prev.assigneeIds.filter((id) => id !== userId)
                      : [...prev.assigneeIds, userId],
                  };
                });
              }}
            />

            <div className="flex gap-2 pt-2">
              <Button
                variant="outline"
                onClick={() => setShowModal(false)}
                className="flex-1 cursor-pointer"
                disabled={submitting}
              >
                Cancel
              </Button>
              <Button
                onClick={handleSaveTask}
                className="flex-1 bg-[#1a1a1a] text-white cursor-pointer"
                disabled={submitting}
              >
                {submitting && (
                  <Loader2 className="w-4 h-4 animate-spin mr-2" />
                )}
                Save Task
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// --- Members Section ---
function MissionMembersSection({ missionId }: { missionId: string }) {
  const supabase = createClient();
  const [members, setMembers] = useState<MissionMember[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchMembers() {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from("mission_members")
          .select(`user_id, role, joined_at, profiles!user_id(username)`)
          .eq("mission_id", missionId);

        if (error) throw error;

        const formatted = (data || []).map((m: any) => ({
          user_id: m.user_id,
          username: m.profiles?.username || "Unknown",
          role: m.role || "member",
          joined_at: m.joined_at,
        }));
        setMembers(formatted);
      } catch (err: any) {
        toast.error("Failed to load members");
      } finally {
        setLoading(false);
      }
    }
    fetchMembers();
  }, [missionId, supabase]);

  if (loading) {
    return (
      <Loader2 className="w-6 h-6 animate-spin text-gray-400 mx-auto my-4" />
    );
  }

  return (
    <div className="space-y-4">
      <h3 className="text-lg font-semibold text-gray-800">Team Members</h3>
      <div className="divide-y divide-gray-100">
        {members.map((m) => (
          <div
            key={m.user_id}
            className="py-3 flex items-center justify-between"
          >
            <div>
              <p className="text-sm font-medium text-gray-800">{m.username}</p>
              <p className="text-xs text-gray-400 capitalize">{m.role}</p>
            </div>
            <span className="text-xs text-gray-400">
              {m.joined_at
                ? `Joined ${new Date(m.joined_at).toLocaleDateString()}`
                : "Pending invite"}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
