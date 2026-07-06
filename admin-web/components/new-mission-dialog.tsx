"use client";

import { useState } from "react";
import { users } from "@/lib/data";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { X, Plus, Trash2, UserPlus, Check } from "lucide-react";

interface TaskInput {
  title: string;
  description: string;
  assignedUserIds: string[];
}

interface NewMissionDialogProps {
  onClose: () => void;
  onSubmit: (data: {
    name: string;
    description: string;
    globalAssignedUserIds: string[];
    tasks: TaskInput[];
  }) => void;
}

export function NewMissionDialog({ onClose, onSubmit }: NewMissionDialogProps) {
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");

  // Pack-level assignments
  const [globalAssignedUserIds, setGlobalAssignedUserIds] = useState<string[]>(
    [],
  );

  // Dynamic task lists
  const [tasks, setTasks] = useState<TaskInput[]>([
    { title: "", description: "", assignedUserIds: [] },
  ]);

  const handleAddCustomTask = () => {
    setTasks([...tasks, { title: "", description: "", assignedUserIds: [] }]);
  };

  const handleRemoveTask = (index: number) => {
    if (tasks.length === 1) return; // Keep at least one task field open
    setTasks(tasks.filter((_, i) => i !== index));
  };

  const handleTaskChange = (
    index: number,
    key: keyof TaskInput,
    value: any,
  ) => {
    const updatedTasks = [...tasks];
    updatedTasks[index] = { ...updatedTasks[index], [key]: value };
    setTasks(updatedTasks);
  };

  const toggleGlobalUser = (userId: string) => {
    setGlobalAssignedUserIds((prev) =>
      prev.includes(userId)
        ? prev.filter((id) => id !== userId)
        : [...prev, userId],
    );
  };

  const toggleTaskUser = (taskIndex: number, userId: string) => {
    const updatedTasks = [...tasks];
    const currentAssignments = updatedTasks[taskIndex].assignedUserIds;

    updatedTasks[taskIndex].assignedUserIds = currentAssignments.includes(
      userId,
    )
      ? currentAssignments.filter((id) => id !== userId)
      : [...currentAssignments, userId];

    setTasks(updatedTasks);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;

    // Filter out un-named empty tasks before submit
    const validTasks = tasks.filter((t) => t.title.trim() !== "");

    onSubmit({
      name,
      description,
      globalAssignedUserIds,
      tasks: validTasks,
    });
  };

  return (
    <>
      {/* Overlay */}
      <div
        className="fixed inset-0 bg-black/30 z-40 backdrop-blur-xs"
        onClick={onClose}
      />

      {/* Dialog */}
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

        {/* Scrollable Container Form */}
        <form
          onSubmit={handleSubmit}
          className="p-6 space-y-6 overflow-y-auto flex-1 bg-[#fafaf9]"
        >
          {/* Section: Pack Meta */}
          <div className="bg-white p-5 border border-[#e8e3db] rounded-lg space-y-4 shadow-xs">
            <h3 className="text-sm font-semibold text-gray-800 uppercase tracking-wider">
              1. Pack Parameters
            </h3>
            <div>
              <label className="text-xs font-medium text-[#6b6b6b] block mb-1.5">
                Pack Title
              </label>
              <Input
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g., Core Flutter Setup"
                className="bg-white border-[#e8e3db]"
                required
              />
            </div>
            <div>
              <label className="text-xs font-medium text-[#6b6b6b] block mb-1.5">
                Global Objective Description
              </label>
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Describe the overarching goals of this structural group..."
                rows={2}
                className="w-full px-3 py-2 border border-[#e8e3db] rounded-lg bg-white text-sm text-[#1a1a1a] placeholder-[#8b8b8b] focus:outline-none focus:ring-1 focus:ring-[#1a1a1a]"
              />
            </div>
          </div>

          {/* Section: Global Team Assignment */}
          <div className="bg-white p-5 border border-[#e8e3db] rounded-lg space-y-3 shadow-xs">
            <div>
              <h3 className="text-sm font-semibold text-gray-800 uppercase tracking-wider">
                2. Global Pack Allocation
              </h3>
              <p className="text-xs text-gray-400 mt-0.5">
                Assign users to all default vectors inside this pack
              </p>
            </div>
            <div className="flex flex-wrap gap-2 pt-1">
              {users.map((user) => {
                const isAssigned = globalAssignedUserIds.includes(user.id);
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
                    {user.name}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Section: Nested Structural Tasks */}
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
                Add New Task
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

                {/* Task Inputs */}
                <div className="grid grid-cols-1 gap-3 max-w-[85%]">
                  <div>
                    <label className="text-xs font-medium text-[#6b6b6b] block mb-1">
                      Task Title
                    </label>
                    <Input
                      value={task.title}
                      onChange={(e) =>
                        handleTaskChange(index, "title", e.target.value)
                      }
                      placeholder="e.g., Install SDK Helpers"
                      className="bg-white border-[#e8e3db] h-9"
                      required
                    />
                  </div>
                  <div>
                    <label className="text-xs font-medium text-[#6b6b6b] block mb-1">
                      Task Description
                    </label>
                    <textarea
                      value={task.description}
                      onChange={(e) =>
                        handleTaskChange(index, "description", e.target.value)
                      }
                      placeholder="Specific requirements/milestone deliverables..."
                      rows={2}
                      className="w-full px-3 py-1.5 border border-[#e8e3db] rounded-lg bg-white text-xs text-[#1a1a1a] focus:outline-none focus:ring-1 focus:ring-[#1a1a1a]"
                    />
                  </div>
                </div>

                {/* Individual Task Allocation */}
                <div className="pt-2 border-t border-dashed border-[#e8e3db]">
                  <p className="text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-2">
                    Isolate Task Assignment (Optional Override)
                  </p>
                  <div className="flex flex-wrap gap-1.5">
                    {users.map((user) => {
                      const isTaskAssigned = task.assignedUserIds.includes(
                        user.id,
                      );
                      const hasGlobalAccess = globalAssignedUserIds.includes(
                        user.id,
                      );

                      return (
                        <button
                          key={user.id}
                          type="button"
                          disabled={hasGlobalAccess}
                          onClick={() => toggleTaskUser(index, user.id)}
                          className={`px-2 py-1 rounded text-[11px] font-medium transition-all border ${
                            hasGlobalAccess
                              ? "bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed opacity-60"
                              : isTaskAssigned
                                ? "bg-indigo-50 text-indigo-700 border-indigo-300 font-semibold"
                                : "bg-white text-gray-500 border-gray-200 hover:bg-gray-50"
                          }`}
                          title={
                            hasGlobalAccess
                              ? "Assigned automatically via Global Pack Allocation"
                              : ""
                          }
                        >
                          {user.name} {hasGlobalAccess && "🔒"}
                        </button>
                      );
                    })}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </form>

        {/* Footer Actions */}
        <div className="flex gap-3 px-6 py-4 border-t border-[#e8e3db] bg-white shrink-0">
          <Button
            type="button"
            onClick={onClose}
            variant="outline"
            className="flex-1 border-[#e8e3db] text-[#6b6b6b] hover:bg-[#f0ebe4]"
          >
            Cancel
          </Button>
          <Button
            type="button"
            onClick={handleSubmit}
            className="flex-1 bg-[#1a1a1a] text-white hover:bg-[#333333]"
          >
            Create Mission Pack
          </Button>
        </div>
      </div>
    </>
  );
}
