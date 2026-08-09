"use client";

import { use, useEffect, useState, useCallback } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  ArrowLeft,
  Loader2,
  Target,
  Users,
  ShieldCheck,
  Plus,
  CheckCircle2,
  User,
  Award,
  Pencil,
  Trash2,
  X,
  Check,
} from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

// --- Database-Aligned Interfaces ---
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
  description: string | null;
  points: number;
  status: string;
  priority?: string;
  category?: string;
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

// --- Main Page Component ---
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
    "tasks"
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
            className="p-2 hover:bg-[#f0ebe4] rounded-md transition-colors"
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
          className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
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
          className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
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
          className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
            activeTab === "proofs"
              ? "border-[#1a1a1a] text-[#1a1a1a]"
              : "border-transparent text-[#8b8b8b] hover:text-[#6b6b6b]"
          }`}
        >
          <ShieldCheck className="w-4 h-4" />
          Proof Verification
        </button>
      </div>

      {/* Tab Panels */}
      <div className="bg-white border border-[#e8e3db] rounded-xl p-6 shadow-xs">
        {activeTab === "tasks" && (
          <MissionTasksSection missionId={mission.id} />
        )}
        {activeTab === "members" && (
          <MissionMembersSection missionId={mission.id} />
        )}
        {activeTab === "proofs" && (
          <MissionProofsSection missionId={mission.id} />
        )}
      </div>
    </div>
  );
}

// --- Tasks Section ---

function MissionTasksSection({ missionId }: { missionId: string }) {
  const supabase = createClient();

  const [tasks, setTasks] = useState<Task[]>([]);
  const [members, setMembers] = useState<MissionMember[]>([]);
  const [loading, setLoading] = useState(true);

  // Modal & Form State
  const [showModal, setShowModal] = useState(false);
  const [editingTask, setEditingTask] = useState<Task | null>(null);
  const [submitting, setSubmitting] = useState(false);

  // Form Input Fields
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [points, setPoints] = useState(100);
  const [assignedUserId, setAssignedUserId] = useState<string>("");

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);

      // Query tasks table filtering on mission_id_fk
      const { data: tasksData, error: tasksError } = await supabase
        .from("tasks")
        .select(
          `
          *,
          assigned_user:profiles!user_id(username)
        `
        )
        .eq("mission_id_fk", missionId);

      if (tasksError) throw tasksError;

      const { data: membersData, error: membersError } = await supabase
        .from("mission_members")
        .select(
          `
          user_id,
          role,
          joined_at,
          profiles!user_id(username)
        `
        )
        .eq("mission_id", missionId);

      if (membersError) throw membersError;

      const formattedMembers: MissionMember[] = (membersData || [])
        .filter((m: any) => m.user_id)
        .map((m: any) => ({
          user_id: m.user_id,
          username: m.profiles?.username || "Unknown User",
          role: m.role || "member",
          joined_at: m.joined_at,
        }));

      setTasks(tasksData || []);
      setMembers(formattedMembers);
    } catch (err: any) {
      console.error("Error loading task data:", {
        message: err?.message,
        details: err?.details,
        hint: err?.hint,
        code: err?.code,
      });
      toast.error(err?.message || "Failed to load tasks");
    } finally {
      setLoading(false);
    }
  }, [missionId, supabase]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleOpenCreate = () => {
    setEditingTask(null);
    setTitle("");
    setDescription("");
    setPoints(100);
    setAssignedUserId("");
    setShowModal(true);
  };

  const handleOpenEdit = (task: Task) => {
    setEditingTask(task);
    setTitle(task.title);
    setDescription(task.description || "");
    setPoints(task.points);
    setAssignedUserId(task.user_id || "");
    setShowModal(true);
  };

  const handleSubmitTask = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      toast.error("Task title is required");
      return;
    }

    try {
      setSubmitting(true);

      const payload = {
        mission_id_fk: missionId,
        title: title.trim(),
        description: description.trim() || null,
        points: Number(points) || 50,
        user_id: assignedUserId || null,
      };

      if (editingTask) {
        const { error } = await supabase
          .from("tasks")
          .update(payload)
          .eq("id", editingTask.id);

        if (error) throw error;
        toast.success("Task updated successfully!");
      } else {
        const { error } = await supabase
          .from("tasks")
          .insert([{ ...payload, status: "pending" }]);

        if (error) throw error;
        toast.success("Task added to mission pack!");
      }

      setShowModal(false);
      fetchData();
    } catch (err: any) {
      console.error("Error saving task:", err);
      toast.error(err?.message || "Failed to save task");
    } finally {
      setSubmitting(false);
    }
  };

  const handleDeleteTask = async (taskId: string, taskTitle: string) => {
    if (!window.confirm(`Are you sure you want to delete "${taskTitle}"?`)) {
      return;
    }

    try {
      const { error } = await supabase.from("tasks").delete().eq("id", taskId);

      if (error) throw error;

      toast.success("Task deleted");
      setTasks((prev) => prev.filter((t) => t.id !== taskId));
    } catch (err: any) {
      console.error("Error deleting task:", err);
      toast.error("Failed to delete task");
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12 gap-2 text-gray-500">
        <Loader2 className="w-5 h-5 animate-spin" />
        <span className="text-sm">Loading tasks...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-[#1a1a1a]">
            Mission Tasks ({tasks.length})
          </h2>
          <p className="text-sm text-gray-500">
            Manage, assign, or edit tasks assigned to this mission pack.
          </p>
        </div>
        <Button
          onClick={handleOpenCreate}
          className="bg-[#1a1a1a] text-white hover:bg-[#333333] flex items-center gap-2"
        >
          <Plus className="w-4 h-4" />
          Add Task
        </Button>
      </div>

      {tasks.length === 0 ? (
        <div className="text-center py-12 border border-dashed border-[#e8e3db] rounded-lg">
          <p className="text-gray-500 text-sm">
            No tasks configured for this mission pack yet.
          </p>
          <Button
            onClick={handleOpenCreate}
            variant="outline"
            className="mt-3 border-[#e8e3db] text-xs"
          >
            Create First Task
          </Button>
        </div>
      ) : (
        <div className="grid gap-3">
          {tasks.map((task) => (
            <div
              key={task.id}
              className="p-4 border border-[#e8e3db] rounded-lg bg-[#fafaf8] flex items-center justify-between hover:border-gray-300 transition-colors"
            >
              <div className="space-y-1 max-w-xl">
                <div className="flex items-center gap-2">
                  <CheckCircle2
                    className={`w-4 h-4 flex-shrink-0 ${
                      task.status === "completed"
                        ? "text-emerald-600"
                        : "text-gray-400"
                    }`}
                  />
                  <h3 className="font-medium text-[#1a1a1a] text-sm">
                    {task.title}
                  </h3>
                </div>
                {task.description && (
                  <p className="text-xs text-gray-500 pl-6 line-clamp-2">
                    {task.description}
                  </p>
                )}
              </div>

              <div className="flex items-center gap-3">
                <div className="flex items-center gap-1.5 text-xs text-gray-600 bg-white px-2.5 py-1 rounded border border-[#e8e3db]">
                  <User className="w-3.5 h-3.5 text-gray-400" />
                  <span>{task.assigned_user?.username || "Unassigned"}</span>
                </div>

                <div className="flex items-center gap-1 text-xs font-bold text-amber-700 bg-amber-50 px-2.5 py-1 rounded border border-amber-200">
                  <Award className="w-3.5 h-3.5" />
                  <span>+{task.points} Points</span>
                </div>

                <div className="flex items-center gap-1 ml-2 border-l border-[#e8e3db] pl-3">
                  <button
                    onClick={() => handleOpenEdit(task)}
                    className="p-1.5 text-gray-500 hover:text-black rounded hover:bg-gray-200 transition-colors"
                    title="Edit Task"
                  >
                    <Pencil className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDeleteTask(task.id, task.title)}
                    className="p-1.5 text-gray-400 hover:text-red-600 rounded hover:bg-red-50 transition-colors"
                    title="Delete Task"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {showModal && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md border border-[#e8e3db] shadow-xl relative">
            <button
              onClick={() => setShowModal(false)}
              className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
            >
              <X className="w-5 h-5" />
            </button>

            <h2 className="text-xl font-semibold text-[#1a1a1a] mb-4">
              {editingTask ? "Edit Task" : "Add Task to Mission"}
            </h2>

            <form onSubmit={handleSubmitTask} className="space-y-4">
              <div>
                <label className="block text-xs font-medium text-[#1a1a1a] mb-1">
                  Task Title *
                </label>
                <Input
                  type="text"
                  placeholder="e.g. Complete Code Review"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="bg-[#fafaf8] border-[#e8e3db]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-[#1a1a1a] mb-1">
                  Description
                </label>
                <textarea
                  rows={3}
                  placeholder="Details or specific completion requirements..."
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full text-sm p-2.5 rounded-md bg-[#fafaf8] border border-[#e8e3db] focus:outline-none focus:ring-1 focus:ring-black"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-medium text-[#1a1a1a] mb-1">
                    Points Reward
                  </label>
                  <Input
                    type="number"
                    min={10}
                    step={10}
                    value={points}
                    onChange={(e) => setPoints(Number(e.target.value))}
                    className="bg-[#fafaf8] border-[#e8e3db]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-medium text-[#1a1a1a] mb-1">
                    Assign To
                  </label>
                  <select
                    value={assignedUserId}
                    onChange={(e) => setAssignedUserId(e.target.value)}
                    className="w-full text-sm p-2 bg-[#fafaf8] border border-[#e8e3db] rounded-md focus:outline-none"
                  >
                    <option value="">Unassigned</option>
                    {members.map((member) => (
                      <option key={member.user_id} value={member.user_id}>
                        {member.username}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="flex gap-3 pt-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setShowModal(false)}
                  disabled={submitting}
                  className="flex-1 border-[#e8e3db]"
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  disabled={submitting || !title.trim()}
                  className="flex-1 bg-[#1a1a1a] text-white hover:bg-[#333333]"
                >
                  {submitting
                    ? "Saving..."
                    : editingTask
                    ? "Save Changes"
                    : "Add Task"}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

// --- Members Tab ---

function MissionMembersSection({ missionId }: { missionId: string }) {
  const supabase = createClient();
  const [members, setMembers] = useState<MissionMember[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchMembers = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from("mission_members")
        .select(
          `
          user_id,
          role,
          joined_at,
          profiles!user_id(username)
        `
        )
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
  }, [missionId, supabase]);

  useEffect(() => {
    fetchMembers();
  }, [fetchMembers]);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-8 gap-2 text-gray-500">
        <Loader2 className="w-5 h-5 animate-spin" />
        <span className="text-sm">Loading team members...</span>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold text-[#1a1a1a]">
        Assigned Team Members ({members.length})
      </h2>
      <div className="divide-y divide-[#e8e3db] border border-[#e8e3db] rounded-lg">
        {members.length === 0 ? (
          <div className="p-4 text-center text-sm text-gray-500">
            No members assigned to this mission pack yet.
          </div>
        ) : (
          members.map((member) => (
            <div
              key={member.user_id}
              className="p-3.5 flex items-center justify-between"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-indigo-50 text-indigo-600 font-bold text-xs flex items-center justify-center">
                  {member.username.slice(0, 2).toUpperCase()}
                </div>
                <span className="text-sm font-medium text-[#1a1a1a]">
                  {member.username}
                </span>
              </div>
              <span className="text-xs px-2.5 py-1 rounded bg-gray-100 text-gray-700 capitalize font-medium">
                {member.role}
              </span>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

// --- Proofs Tab ---

// --- Proofs Tab ---

function MissionProofsSection({ missionId }: { missionId: string }) {
  const supabase = createClient();
  const [pendingTasks, setPendingTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchProofs = useCallback(async () => {
    try {
      setLoading(true);

      // Querying pending verification using the `done` boolean column
      const { data, error } = await supabase
        .from("tasks")
        .select(
          `
          *,
          assigned_user:profiles(username)
        `
        )
        .eq("mission_id_fk", missionId)
        .eq("done", false)
        .not("proof_notes", "is", null); // Tasks with proof submitted but not yet marked done

      if (error) throw error;

      setPendingTasks(data || []);
    } catch (err: any) {
      console.error("Error fetching tasks for proof review:", {
        message: err?.message,
        details: err?.details,
        hint: err?.hint,
        code: err?.code,
        raw: err,
      });
      toast.error(err?.message || "Failed to load proof verification queue");
    } finally {
      setLoading(false);
    }
  }, [missionId, supabase]);

  useEffect(() => {
    fetchProofs();
  }, [fetchProofs]);

  const handleReviewTask = async (taskId: string, approve: boolean) => {
    try {
      // If approved, set done = true. If rejected, clear proof notes to return it to active state.
      const payload = approve
        ? { done: true }
        : { done: false, proof_notes: null, proof_image: null };

      const { error } = await supabase
        .from("tasks")
        .update(payload)
        .eq("id", taskId);

      if (error) throw error;

      toast.success(
        approve
          ? "Task approved and completed!"
          : "Proof rejected; task returned to pending."
      );
      setPendingTasks((prev) => prev.filter((t) => t.id !== taskId));
    } catch (err: any) {
      console.error("Error updating proof status:", err);
      toast.error(err?.message || "Action failed");
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-8 gap-2 text-gray-500">
        <Loader2 className="w-5 h-5 animate-spin" />
        <span className="text-sm">Loading verification queue...</span>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold text-[#1a1a1a]">
          Proof Verification Queue ({pendingTasks.length})
        </h2>
      </div>

      {pendingTasks.length === 0 ? (
        <div className="text-center py-12 border border-dashed border-[#e8e3db] rounded-lg">
          <ShieldCheck className="w-8 h-8 mx-auto text-gray-400 mb-2" />
          <h3 className="text-sm font-semibold text-gray-700">
            Queue is Empty
          </h3>
          <p className="text-xs text-gray-500 max-w-sm mx-auto mt-1">
            No pending task submissions require review at this time.
          </p>
        </div>
      ) : (
        <div className="grid gap-3">
          {pendingTasks.map((task) => (
            <div
              key={task.id}
              className="p-4 border border-[#e8e3db] rounded-lg bg-[#fafaf8] flex items-center justify-between"
            >
              <div className="space-y-1">
                <span className="text-xs font-semibold text-amber-700 bg-amber-50 px-2 py-0.5 rounded border border-amber-200 inline-block mb-1">
                  +{task.points} Points
                </span>
                <h4 className="text-sm font-medium text-[#1a1a1a]">
                  {task.title}
                </h4>
                <p className="text-xs text-gray-500">
                  Submitted by{" "}
                  <span className="font-medium">
                    {task.assigned_user?.username || "Unknown"}
                  </span>
                </p>
                {task.proof_notes && (
                  <p className="text-xs text-gray-700 mt-2 bg-white p-2 rounded border border-[#e8e3db]">
                    "{task.proof_notes}"
                  </p>
                )}
              </div>

              <div className="flex items-center gap-2">
                <Button
                  onClick={() => handleReviewTask(task.id, false)}
                  variant="outline"
                  size="sm"
                  className="text-red-600 hover:text-red-700 border-red-200 hover:bg-red-50 text-xs h-8"
                >
                  <X className="w-3.5 h-3.5 mr-1" />
                  Reject
                </Button>
                <Button
                  onClick={() => handleReviewTask(task.id, true)}
                  size="sm"
                  className="bg-emerald-600 hover:bg-emerald-700 text-white text-xs h-8"
                >
                  <Check className="w-3.5 h-3.5 mr-1" />
                  Approve
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}