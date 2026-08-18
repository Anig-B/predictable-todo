"use client";

import { Input } from "@/components/ui/input";

export interface AssignableUser {
  id: string;
  username: string;
  avatar_url?: string | null;
}

export type TaskPriority = 0 | 1 | 2; // 0: low, 1: medium, 2: high
export type TaskRecurring = 0 | 1 | 2 | 3; // 0: none, 1: daily, 2: weekly, 3: monthly

export interface TaskRow {
  key: string;
  title: string;
  desc: string;
  time: string;
  priority: TaskPriority;
  points: number;
  recurring: TaskRecurring;
  assignMode: "all" | "specific";
  assigneeIds: string[];
}

export const PRIORITY_XP: Record<TaskPriority, number> = {
  0: 20, // Low
  1: 40, // Medium
  2: 80, // High
};

interface TaskCardProps {
  task: TaskRow;
  index: number;
  memberList: AssignableUser[];
  canRemove: boolean;
  saving?: boolean;
  onUpdate: (key: string, patch: Partial<TaskRow>) => void;
  onRemove: (key: string) => void;
  onToggleAssignee: (key: string, userId: string) => void;
}

export function TaskCard({
  task: t,
  index,
  memberList,
  canRemove,
  saving = false,
  onUpdate,
  onRemove,
  onToggleAssignee,
}: TaskCardProps) {
  return (
    <div className="space-y-3 rounded-md border border-[#e8e3db] bg-[#faf9f6] p-4">
      {/* Title & Remove */}
      <div className="flex items-start gap-2">
        <div className="flex-1 space-y-2">
          <div>
            <label className="mb-1 block text-xs font-medium text-[#6b6b6b]">
              Task title *
            </label>
            <Input
              value={t.title}
              onChange={(e) => onUpdate(t.key, { title: e.target.value })}
              placeholder={`e.g. Task ${index + 1}`}
              disabled={saving}
              required
            />
          </div>

          <div>
            <label className="mb-1 block text-xs font-medium text-[#6b6b6b]">
              Description
            </label>
            <textarea
              value={t.desc}
              onChange={(e) => onUpdate(t.key, { desc: e.target.value })}
              placeholder="Task details and expectations"
              disabled={saving}
              className="min-h-12 w-full rounded-md border border-[#e8e3db] bg-white px-3 py-2 text-sm text-[#1a1a1a] outline-none ring-0 focus:border-[#1a1a1a]"
            />
          </div>
        </div>

        {canRemove && (
          <button
            type="button"
            onClick={() => onRemove(t.key)}
            disabled={saving}
            className="rounded-md px-2 py-1 text-sm text-[#6b6b6b] hover:bg-[#f5f2ec] hover:text-[#1a1a1a]"
            aria-label="Remove task"
          >
            ✕
          </button>
        )}
      </div>

      {/* Config Row */}
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
        {/* 24-Hour Time Picker */}
        <div>
          <label className="mb-1 block text-xs font-medium text-[#6b6b6b]">
            Time (24h)
          </label>
          <Input
            type="time"
            value={t.time}
            onChange={(e) => onUpdate(t.key, { time: e.target.value })}
            disabled={saving}
            className="h-8 bg-white text-xs"
          />
        </div>

        {/* Priority & XP */}
        <div>
          <div className="mb-1 flex items-center justify-between">
            <label className="text-xs font-medium text-[#6b6b6b]">
              Priority
            </label>
          </div>
          <select
            value={t.priority}
            onChange={(e) => {
              const priority = Number(e.target.value) as TaskPriority;
              onUpdate(t.key, { priority, points: PRIORITY_XP[priority] });
            }}
            disabled={saving}
            className="h-8 w-full rounded-md border border-[#e8e3db] bg-white px-2 text-xs text-[#1a1a1a]"
          >
            <option value={0}>Low</option>
            <option value={1}>Medium</option>
            <option value={2}>High</option>
          </select>
        </div>

        {/* Recurring */}
        <div>
          <label className="mb-1 block text-xs font-medium text-[#6b6b6b]">
            Recurring
          </label>
          <select
            value={t.recurring}
            onChange={(e) =>
              onUpdate(t.key, {
                recurring: Number(e.target.value) as TaskRecurring,
              })
            }
            disabled={saving}
            className="h-8 w-full rounded-md border border-[#e8e3db] bg-white px-2 text-xs text-[#1a1a1a]"
          >
            <option value={0}>One-off</option>
            <option value={1}>Daily</option>
            <option value={2}>Weekly</option>
            <option value={3}>Monthly</option>
          </select>
        </div>
      </div>

      {/* Assignment Controls */}
      <div className="border-t border-[#e8e3db] pt-2">
        <div className="mb-2 flex items-center gap-4 text-xs">
          <span className="font-medium text-[#6b6b6b]">Assign to:</span>
          <label className="flex items-center gap-1 text-[#1a1a1a] cursor-pointer">
            <input
              type="radio"
              name={`assign-${t.key}`}
              checked={t.assignMode === "all"}
              onChange={() => onUpdate(t.key, { assignMode: "all" })}
              disabled={saving}
            />
            All members
          </label>
          <label className="flex items-center gap-1 text-[#1a1a1a] cursor-pointer">
            <input
              type="radio"
              name={`assign-${t.key}`}
              checked={t.assignMode === "specific"}
              onChange={() => onUpdate(t.key, { assignMode: "specific" })}
              disabled={saving}
            />
            Specific people
          </label>
        </div>

        {t.assignMode === "specific" && (
          <div className="flex flex-wrap gap-2 pt-1">
            {memberList.length === 0 && (
              <p className="text-xs text-[#6b6b6b] italic">
                Select or invite members above to assign them individually.
              </p>
            )}
            {memberList.map((u) => {
              const selected = t.assigneeIds.includes(u.id);
              return (
                <button
                  key={u.id}
                  type="button"
                  disabled={saving}
                  onClick={() => onToggleAssignee(t.key, u.id)}
                  className={`rounded-full border px-3 py-1 text-xs transition ${
                    selected
                      ? "border-[#1a1a1a] bg-[#1a1a1a] text-white"
                      : "border-[#e8e3db] bg-white text-[#1a1a1a] hover:bg-[#f5f2ec]"
                  }`}
                >
                  {u.username}
                </button>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
