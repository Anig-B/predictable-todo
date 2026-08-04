"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { X, Plus, Trash2, UserPlus, Check, Loader2 } from "lucide-react";
import { toast } from "sonner";

interface UserProfile {
  id: string;
  username: string | null;
  avatar_url: string | null;
}

interface TaskInput {
  title: string;
  description: string;
  points: number;
  assignedUserId: string | null;
}

interface NewMissionDialogProps {
  onClose: () => void;
  onSuccess: () => void;
}

export function NewMissionDialog({ onClose, onSuccess }: NewMissionDialogProps) {
  const supabase = createClient();

  const [loading, setLoading] = useState(false);
  const [fetchingUsers, setFetchingUsers] = useState(true);
  const [availableUsers, setAvailableUsers] = useState<UserProfile[]>([]);

  // Form State
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [globalAssignedUserIds, setGlobalAssignedUserIds] = useState<string[]>([]);
  const [tasks, setTasks] = useState<TaskInput[]>([
    { title: "", description: "", points: 100, assignedUserId: null },
  ]);

  // Fetch ONLY users who were invited by the current manager
  useEffect(() => {
    async function loadInvitedUsers() {
      try {
        setFetchingUsers(true);

        // 1. Get current logged-in manager
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) throw new Error("Authentication failed");

        // 2. Fetch distinct user_ids from mission_members where invited_by = current user
        const { data: invitedMembers, error: membersError } = await supabase
          .from("mission_members")
          .select("user_id")
          .eq("invited_by", user.id);

        if (membersError) throw membersError;

        // Deduplicate user IDs (excluding manager's own ID)
        const invitedUserIds = Array.from(
          new Set(
            (invitedMembers || [])
              .map((m) => m.user_id)
              .filter((id) => id !== user.id)
          )
        );

        if (invitedUserIds.length === 0) {
          setAvailableUsers([]);
          return;
        }

        // 3. Fetch profiles only for those invited user IDs
        const { data: profiles, error: profilesError } = await supabase
          .from("profiles")
          .select("id, username, avatar_url")
          .in("id", invitedUserIds)
          .order("username", { ascending: true });

        if (profilesError) throw profilesError;
        setAvailableUsers(profiles || []);
      } catch (err: any) {
        toast.error("Could not load invited team members");
      } finally {
        setFetchingUsers(false);
      }
    }

    loadInvitedUsers();
  }, []);

  const handleAddCustomTask = () => {
    setTasks([...tasks, { title: "", description: "", points: 100, assignedUserId: null }]);
  };

  const handleRemoveTask = (index: number) => {
    if (tasks.length === 1) return;
    setTasks(tasks.filter((_, i) => i !== index));
  };

  const handleTaskChange = (index: number, key: keyof TaskInput, value: any) => {
    const updatedTasks = [...tasks];
    updatedTasks[index] = { ...updatedTasks[index], [key]: value };
    setTasks(updatedTasks);
  };

  const toggleGlobalUser = (userId: string) => {
    setGlobalAssignedUserIds((prev) =>
      prev.includes(userId) ? prev.filter((id) => id !== userId) : [...prev, userId]
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      toast.error("Mission title is required");
      return;
    }

    try {
      setLoading(true);

      // 1. Get Logged-In User
      const { data: { user }, error: authError } = await supabase.auth.getUser();
      if (authError || !user) throw new Error("Authentication failed. Please log in again.");

      // 2. Insert Mission Record
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

      // 3. Insert Mission Members (Creator as manager + Invited global users)
      const memberInserts = [];

      // Ensure creator is inserted as manager
      memberInserts.push({
        mission_id: missionId,
        user_id: user.id,
        role: "manager",
        invited_by: user.id,
        joined_at: new Date().toISOString(),
      });

      // Insert invited members
      globalAssignedUserIds.forEach((invitedUserId) => {
        if (invitedUserId !== user.id) {
          memberInserts.push({
            mission_id: missionId,
            user_id: invitedUserId,
            role: "member",
            invited_by: user.id,
            joined_at: null,
          });
        }
      });

      const { error: membersError } = await supabase
        .from("mission_members")
        .insert(memberInserts);

      if (membersError) throw membersError;

      // 4. Bulk Insert Nested Tasks
      const validTasks = tasks.filter((t) => t.title.trim() !== "");
      if (validTasks.length > 0) {
        const taskInserts = validTasks.map((t) => ({
          id: crypto.randomUUID(), // Generator for text primary key 'id'
          mission_id: missionId,
          mission_id_fk: missionId,
          user_id: t.assignedUserId || user.id,
          title: t.title.trim(),
          desc: t.description.trim() || "", // Fixed: Matches schema column 'desc'
          points: Number(t.points) || 100,
          time: "",
          done: false,
        }));

        const { error: tasksError } = await supabase
          .from("tasks")
          .insert(taskInserts);

        if (tasksError) throw tasksError;
      }

      toast.success("Mission Pack configured successfully!");
      onSuccess();
    } catch (err: any) {
      toast.error(err.message || "Failed to create mission pack");
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      {/* Background Backdrop */}
      <div
        className="fixed inset-0 bg-black/30 z-40 backdrop-blur-xs"
        onClick={onClose}
      />

      {/* Dialog Container */}
      <div className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-2xl max-h-[85vh] bg-white border border-[#e8e3db] rounded-xl shadow-2xl z-50 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#e8e3db] bg-white shrink-0">
          <div>
            <h2 className="text-xl font-bold text-[#1a1a1a]">
              Configure Mission Pack
            </h2>
            <p className="text-xs text-gray-400 mt-0.5">
              Bundle multiple tasks and orchestrate team assignments.
            </p>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 hover:bg-[#f0ebe4] rounded-md transition-colors"
          >
            <X className="w-5 h-5 text-[#6b6b6b]" />
          </button>
        </div>

        {/* Form Content */}
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
                placeholder="Describe the overarching goals of this mission pack..."
                rows={2}
                className="w-full px-3 py-2 border border-[#e8e3db] rounded-lg bg-white text-sm text-[#1a1a1a] placeholder-[#8b8b8b] focus:outline-none focus:ring-1 focus:ring-[#1a1a1a]"
              />
            </div>
          </div>

          {/* Section 2: Team Members Invites */}
          <div className="bg-white p-5 border border-[#e8e3db] rounded-lg space-y-3 shadow-xs">
            <div>
              <h3 className="text-sm font-semibold text-gray-800 uppercase tracking-wider">
                2. Invite Team Members
              </h3>
              <p className="text-xs text-gray-400 mt-0.5">
                Only users invited by you are eligible to be assigned to this mission.
              </p>
            </div>

            {fetchingUsers ? (
              <div className="flex items-center gap-2 text-xs text-gray-400 py-2">
                <Loader2 className="w-3.5 h-3.5 animate-spin" /> Loading team profiles...
              </div>
            ) : availableUsers.length === 0 ? (
              <p className="text-xs text-gray-400 italic">No user candidates found in your invited roster.</p>
            ) : (
              <div className="flex flex-wrap gap-2 pt-1">
                {availableUsers.map((user) => {
                  const isAssigned = globalAssignedUserIds.includes(user.id);
                  const displayName = user.username || user.id.slice(0, 8);

                  return (
                    <button
                      key={user.id}
                      type="button"
                      onClick={() => toggleGlobalUser(user.id)}
                      className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-all border ${
                        isAssigned
                          ? "bg-[#1a1a1a] text-white border-[#1a1a1a]"
                          : "bg-[#fafaf8] text-gray-600 border-[#e8e3db] hover:bg-gray-100"
                      }`}
                    >
                      {isAssigned ? (
                        <Check className="w-3 h-3" />
                      ) : (
                        <UserPlus className="w-3 h-3" />
                      )}
                      {displayName}
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
                onClick={handleAddCustomTask}
                className="border-[#e8e3db] text-xs h-8 flex items-center gap-1 bg-white hover:bg-gray-50"
              >
                <Plus className="w-3.5 h-3.5" />
                Add Task
              </Button>
            </div>

            {tasks.map((task, index) => (
              <div
                key={index}
                className="bg-white border border-[#e8e3db] rounded-lg p-5 shadow-xs relative space-y-4"
              >
                <div className="absolute right-4 top-4 flex items-center gap-2">
                  <span className="text-[10px] font-bold text-gray-400 uppercase tracking-wider bg-gray-100 px-1.5 py-0.5 rounded">
                    Task #{index + 1}
                  </span>
                  {tasks.length > 1 && (
                    <button
                      type="button"
                      onClick={() => handleRemoveTask(index)}
                      className="p-1 text-gray-400 hover:text-rose-600 rounded hover:bg-rose-50 transition-colors"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>

                <div className="grid grid-cols-1 gap-3 max-w-[85%]">
                  <div>
                    <label className="text-xs font-medium text-[#6b6b6b] block mb-1">
                      Task Title *
                    </label>
                    <Input
                      value={task.title}
                      onChange={(e) =>
                        handleTaskChange(index, "title", e.target.value)
                      }
                      placeholder="e.g., Watch Safety Onboarding Video"
                      className="bg-white border-[#e8e3db] h-9"
                      required
                    />
                  </div>
                  <div className="grid grid-cols-3 gap-2">
                    <div className="col-span-2">
                      <label className="text-xs font-medium text-[#6b6b6b] block mb-1">
                        Description
                      </label>
                      <textarea
                        value={task.description}
                        onChange={(e) =>
                          handleTaskChange(index, "description", e.target.value)
                        }
                        placeholder="Deliverable details..."
                        rows={2}
                        className="w-full px-3 py-1.5 border border-[#e8e3db] rounded-lg bg-white text-xs text-[#1a1a1a] focus:outline-none focus:ring-1 focus:ring-[#1a1a1a]"
                      />
                    </div>
                    <div>
                      <label className="text-xs font-medium text-[#6b6b6b] block mb-1">
                        XP Reward
                      </label>
                      <Input
                        type="number"
                        value={task.points}
                        onChange={(e) =>
                          handleTaskChange(index, "points", parseInt(e.target.value) || 0)
                        }
                        className="bg-white border-[#e8e3db] h-9"
                      />
                    </div>
                  </div>
                </div>
              </div>
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
            className="flex-1 border-[#e8e3db] text-[#6b6b6b] hover:bg-[#f0ebe4]"
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