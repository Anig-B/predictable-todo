"use client";

import { useEffect, useState, useCallback } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import {
  Loader2,
  Plus,
  Trash2,
  X,
  CheckCircle2,
  Clock,
  FileCheck,
} from "lucide-react";
import { toast } from "sonner";
import {
  TaskCard,
  TaskRow,
  AssignableUser,
  PRIORITY_XP,
} from "@/components/create-task";
import {
  getMissionTasksAndMembers,
  createMissionTasks,
  deleteMissionTaskGroup,
  Task,
  MissionMember,
} from "@/actions/missions";

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

export function MissionTasksSection({ missionId }: { missionId: string }) {
  const supabase = createClient();

  const [tasks, setTasks] = useState<Task[]>([]);
  const [members, setMembers] = useState<MissionMember[]>([]);
  const [loading, setLoading] = useState(true);
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
      const data = await getMissionTasksAndMembers(missionId);
      setTasks(data.tasks);
      setMembers(data.members);
    } catch (err: any) {
      toast.error(err?.message || "Failed to load tasks");
    } finally {
      setLoading(false);
    }
  }, [missionId]);

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

      await createMissionTasks(newTasks, missionId);
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
      await deleteMissionTaskGroup(taskIds, missionId);
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
      if (!task.done) current.allDone = false;
      if (isProofSubmitted) current.hasPendingProof = true;
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
