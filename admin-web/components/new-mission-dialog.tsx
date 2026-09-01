"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { X, Plus, UserPlus, Check, Loader2 } from "lucide-react";
import { toast } from "sonner";
import { TaskCard, TaskRow, AssignableUser, PRIORITY_XP } from "./create-task";

interface NewMissionDialogProps {
  onClose: () => void;
  onSuccess: () => void;
}

const createDefaultTask = (): TaskRow => ({
  key: crypto.randomUUID(),
  title: "",
  desc: "",
  time: "",
  priority: 1, // Medium
  points: PRIORITY_XP[1],
  recurring: 0, // One-off
  assignMode: "all",
  assigneeIds: [],
});

export function NewMissionDialog({
  onClose,
  onSuccess,
}: NewMissionDialogProps) {
  const supabase = createClient();

  const [loading, setLoading] = useState(false);
  const [fetchingUsers, setFetchingUsers] = useState(true);

  // All active team users available to the manager
  const [availableUsers, setAvailableUsers] = useState<AssignableUser[]>([]);

  // Form State
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");

  // Members explicitly added to THIS mission scope
  const [missionMemberIds, setMissionMemberIds] = useState<string[]>([]);

  const [tasks, setTasks] = useState<TaskRow[]>([createDefaultTask()]);

  useEffect(() => {
    async function loadInvitedUsers() {
      try {
        setFetchingUsers(true);
        const {
          data: { user },
          error: authError,
        } = await supabase.auth.getUser();
        if (authError || !user) throw new Error("Authentication failed");

        // Fetch team members invited by manager who accepted their invite
        const { data: invitedMembers, error: membersError } = await supabase
          .from("mission_members")
          .select("user_id")
          .eq("invited_by", user.id)
          .not("joined_at", "is", null);

        if (membersError) throw membersError;

        const invitedUserIds = Array.from(
          new Set(
            (invitedMembers || [])
              .map((m) => m.user_id)
              .filter((id) => id !== user.id),
          ),
        );

        if (invitedUserIds.length === 0) {
          setAvailableUsers([]);
          return;
        }

        const { data: profiles, error: profilesError } = await supabase
          .from("profiles")
          .select("id, username, avatar_url")
          .in("id", invitedUserIds)
          .order("username", { ascending: true });

        if (profilesError) throw profilesError;

        const mapped: AssignableUser[] = (profiles || []).map((p) => ({
          id: p.id,
          username: p.username || p.id.slice(0, 8),
          avatar_url: p.avatar_url,
        }));

        setAvailableUsers(mapped);
      } catch (err: any) {
        toast.error("Could not load team members");
      } finally {
        setFetchingUsers(false);
      }
    }

    loadInvitedUsers();
  }, [supabase]);

  const handleAddTask = () => {
    setTasks((prev) => [...prev, createDefaultTask()]);
  };

  const handleRemoveTask = (key: string) => {
    if (tasks.length === 1) return;
    setTasks((prev) => prev.filter((t) => t.key !== key));
  };

  const handleUpdateTask = (key: string, patch: Partial<TaskRow>) => {
    setTasks((prev) =>
      prev.map((t) => (t.key === key ? { ...t, ...patch } : t)),
    );
  };

  const handleToggleAssignee = (key: string, userId: string) => {
    setTasks((prev) =>
      prev.map((t) => {
        if (t.key !== key) return t;
        const exists = t.assigneeIds.includes(userId);
        const assigneeIds = exists
          ? t.assigneeIds.filter((id) => id !== userId)
          : [...t.assigneeIds, userId];
        return { ...t, assigneeIds };
      }),
    );
  };

  const toggleMissionMember = (userId: string) => {
    setMissionMemberIds((prev) => {
      const isRemoving = prev.includes(userId);
      const nextMembers = isRemoving
        ? prev.filter((id) => id !== userId)
        : [...prev, userId];

      // Clean up specific assignee selections in tasks if member is removed from mission scope
      if (isRemoving) {
        setTasks((prevTasks) =>
          prevTasks.map((t) => ({
            ...t,
            assigneeIds: t.assigneeIds.filter((id) => id !== userId),
          })),
        );
      }

      return nextMembers;
    });
  };

  // Filter available users to pass ONLY mission-scoped members to tasks
  const currentMissionMembers = availableUsers.filter((u) =>
    missionMemberIds.includes(u.id),
  );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      toast.error("Mission title is required");
      return;
    }

    // Validate that tasks set to 'specific' have at least one assignee selected
    const invalidSpecificTask = tasks.find(
      (t) => t.assignMode === "specific" && t.assigneeIds.length === 0,
    );
    if (invalidSpecificTask) {
      toast.error(
        `Please select at least one team member for "${
          invalidSpecificTask.title || "Untitled Task"
        }" or change mode to "All mission members".`,
      );
      return;
    }

    try {
      setLoading(true);

      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser();
      if (authError || !user) throw new Error("Authentication error");

      const { data: newMission, error: missionError } = await supabase
        .from("missions")
        .insert({
          name: name.trim(),
          description: description.trim() || null,
          created_by: user.id,
          is_active: true,
        })
        .select("id")
        .single();

      if (missionError) throw missionError;
      const missionId = newMission.id;

      // Register Members in mission scope (Manager + Selected Team Members)
      const memberInserts: {
        mission_id: string;
        user_id: string;
        role: string;
        invited_by: string;
        joined_at: string | null;
      }[] = [
        {
          mission_id: missionId,
          user_id: user.id,
          role: "manager",
          invited_by: user.id,
          joined_at: new Date().toISOString(),
        },
      ];

      missionMemberIds.forEach((memberUserId) => {
        if (memberUserId !== user.id) {
          memberInserts.push({
            mission_id: missionId,
            user_id: memberUserId,
            role: "member",
            invited_by: user.id,
            joined_at: new Date().toISOString(),
          });
        }
      });

      const { error: membersError } = await supabase
        .from("mission_members")
        .insert(memberInserts);

      if (membersError) throw membersError;

      // Bulk Insert Tasks based on individual task assignment settings
      const validTasks = tasks.filter((t) => t.title.trim() !== "");
      if (validTasks.length > 0) {
        const taskInserts: any[] = [];

        validTasks.forEach((t) => {
          // Resolve target users for this specific task
          const targetUsers =
            t.assignMode === "all"
              ? [user.id, ...missionMemberIds] // Manager + All Mission Members
              : t.assigneeIds; // Strictly selected members for this specific task

          targetUsers.forEach((assignedUserId) => {
            taskInserts.push({
              id: crypto.randomUUID(),
              mission_id: missionId,
              mission_id_fk: missionId,
              user_id: assignedUserId,
              title: t.title.trim(),
              desc: t.desc.trim() || "",
              time: t.time.trim() || "",
              priority: t.priority,
              points: t.points,
              recurring: t.recurring,
              done: false,
            });
          });
        });

        if (taskInserts.length > 0) {
          const { error: tasksError } = await supabase
            .from("tasks")
            .insert(taskInserts);

          if (tasksError) throw tasksError;
        }
      }

      toast.success("Mission Pack created successfully!");
      onSuccess();
    } catch (err: any) {
      toast.error(err.message || "Failed to create mission pack");
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <div
        className="fixed inset-0 bg-black/30 z-40 backdrop-blur-xs"
        onClick={onClose}
      />
      <div className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-2xl max-h-[85vh] bg-white border border-[#e8e3db] rounded-xl shadow-2xl z-50 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#e8e3db] bg-white shrink-0">
          <div>
            <h2 className="text-xl font-bold text-[#1a1a1a]">
              Configure Mission Pack
            </h2>
            <p className="text-xs text-gray-400 mt-0.5">
              Bundle tasks and assign team members under this mission scope.
            </p>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 hover:bg-[#f0ebe4] rounded-md transition-colors"
          >
            <X className="w-5 h-5 text-[#6b6b6b]" />
          </button>
        </div>

        {/* Form Body */}
        <form
          onSubmit={handleSubmit}
          className="p-6 space-y-6 overflow-y-auto flex-1 bg-[#fafaf9]"
        >
          {/* Section 1: Meta */}
          <div className="bg-white p-5 border border-[#e8e3db] rounded-lg space-y-4 shadow-xs">
            <h3 className="text-sm font-semibold text-gray-800 uppercase tracking-wider">
              1. Pack Parameters
            </h3>
            <div>
              <label className="text-xs font-medium text-[#6b6b6b] block mb-1.5">
                Pack Title *
              </label>
              <Input
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g., Q3 Onboarding Track"
                className="bg-white border-[#e8e3db]"
                required
              />
            </div>
            <div>
              <label className="text-xs font-medium text-[#6b6b6b] block mb-1.5">
                Objective Description
              </label>
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Describe overarching goals..."
                rows={2}
                className="w-full px-3 py-2 border border-[#e8e3db] rounded-lg bg-white text-sm text-[#1a1a1a] outline-none ring-0 focus:border-[#1a1a1a]"
              />
            </div>
          </div>

          {/* Section 2: Mission Scope Members */}
          <div className="bg-white p-5 border border-[#e8e3db] rounded-lg space-y-3 shadow-xs">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-semibold text-gray-800 uppercase tracking-wider">
                2. Add Team Members to Mission Scope
              </h3>
              <span className="text-xs text-[#6b6b6b] font-medium">
                {missionMemberIds.length} member(s) included
              </span>
            </div>
            <p className="text-xs text-gray-500">
              Select members who belong to this mission. Tasks set to "All
              mission members" will automatically be assigned to everyone
              selected here.
            </p>

            {fetchingUsers ? (
              <div className="flex items-center gap-2 text-xs text-gray-400 py-2">
                <Loader2 className="w-3.5 h-3.5 animate-spin" /> Loading team
                profiles...
              </div>
            ) : availableUsers.length === 0 ? (
              <p className="text-xs text-gray-400 italic">
                No active team members available. (Users must accept their team
                invite first).
              </p>
            ) : (
              <div className="flex flex-wrap gap-2 pt-1">
                {availableUsers.map((u) => {
                  const isScoped = missionMemberIds.includes(u.id);
                  return (
                    <button
                      key={u.id}
                      type="button"
                      onClick={() => toggleMissionMember(u.id)}
                      className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-all border ${
                        isScoped
                          ? "bg-[#1a1a1a] text-white border-[#1a1a1a]"
                          : "bg-[#fafaf8] text-gray-600 border-[#e8e3db] hover:bg-gray-100"
                      }`}
                    >
                      {isScoped ? (
                        <Check className="w-3 h-3" />
                      ) : (
                        <UserPlus className="w-3 h-3" />
                      )}
                      {u.username}
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* Section 3: Tasks List */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-semibold text-gray-800 uppercase tracking-wider pl-1">
                3. Tasks in Pack
              </h3>
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={handleAddTask}
                className="border-[#e8e3db] text-xs h-8 flex items-center gap-1 bg-white hover:bg-gray-50"
              >
                <Plus className="w-3.5 h-3.5" /> Add Task
              </Button>
            </div>

            {tasks.map((task, index) => (
              <TaskCard
                key={task.key}
                task={task}
                index={index}
                memberList={currentMissionMembers}
                canRemove={tasks.length > 1}
                saving={loading}
                onUpdate={handleUpdateTask}
                onRemove={handleRemoveTask}
                onToggleAssignee={handleToggleAssignee}
              />
            ))}
          </div>
        </form>

        {/* Footer */}
        <div className="flex gap-3 px-6 py-4 border-t border-[#e8e3db] bg-white shrink-0">
          <Button
            type="button"
            onClick={onClose}
            disabled={loading}
            variant="outline"
            className="flex-1 border-[#e8e3db] text-[#6b6b6b]"
          >
            Cancel
          </Button>
          <Button
            type="button"
            onClick={handleSubmit}
            disabled={loading}
            className="flex-1 bg-[#1a1a1a] text-white hover:bg-[#333333] flex items-center justify-center gap-2"
          >
            {loading && <Loader2 className="w-4 h-4 animate-spin" />}
            Create Mission Pack
          </Button>
        </div>
      </div>
    </>
  );
}
