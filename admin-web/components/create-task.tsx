"use client";

import { Input } from "@/components/ui/input";

export interface AssignableUser {
  id: string;
  username: string;
  avatar_url?: string | null;
}

export type TaskMemberOption =
  | AssignableUser
  | { user_id: string; username: string };

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
  weeklyDay?: number | null; // 1-7
  monthlyDay?: number | null; // 1-28 or 0
  assignMode: "all" | "specific";
  assigneeIds: string[];
}

export const PRIORITY_XP: Record<TaskPriority, number> = {
  0: 20, // Low
  1: 40, // Medium
  2: 80, // High
};

const WEEKDAYS = [
  { value: 1, label: "Monday" },
  { value: 2, label: "Tuesday" },
  { value: 3, label: "Wednesday" },
  { value: 4, label: "Thursday" },
  { value: 5, label: "Friday" },
  { value: 6, label: "Saturday" },
  { value: 7, label: "Sunday" },
];

/**
 * Helper to construct an ISO timestamptz from a 24h time string (e.g., "14:30")
 */
export function constructDueAtTimestamp(timeStr: string): string | null {
  if (!timeStr) return null;
  const [hours, minutes] = timeStr.split(":").map(Number);
  if (isNaN(hours) || isNaN(minutes)) return null;

  const due = new Date();
  due.setHours(hours, minutes, 0, 0);

  // If the time entered has already passed today, set the due date for tomorrow
  if (due.getTime() <= Date.now()) {
    due.setDate(due.getDate() + 1);
  }

  return due.toISOString();
}

interface TaskCardProps {
  task: TaskRow;
  index: number;
  memberList: TaskMemberOption[];
  canRemove: boolean;
  saving?: boolean;
  onUpdate: (key: string, patch: Partial<TaskRow>) => void;
  onRemove: (key: string) => void;
  onToggleAssignee: (key: string, userId: string) => void;
}

export function TaskCard({
  task: t,
  index,
  memberList = [],
  canRemove,
  saving = false,
  onUpdate,
  onRemove,
  onToggleAssignee,
}: TaskCardProps) {
  const normalizedMembers: AssignableUser[] = memberList.map((m: any) => ({
    id: m.id || m.user_id,
    username: m.username || "Unknown Member",
    avatar_url: m.avatar_url || null,
  }));

  const isSpecificUnassigned =
    t.assignMode === "specific" && t.assigneeIds.length === 0;

  return (
    <div
      className={`space-y-3 rounded-lg border bg-[#faf9f6] p-4 transition-colors ${
        isSpecificUnassigned
          ? "border-amber-300 bg-amber-50/20"
          : "border-[#e8e3db]"
      }`}
    >
      {/* Title & Remove */}
      <div className="flex items-start gap-2">
        <div className="flex-1 space-y-2">
          <div>
            <label className="mb-1 block text-xs font-semibold text-[#1a1a1a]">
              Task Title <span className="text-red-500">*</span>
            </label>
            <Input
              value={t.title}
              onChange={(e) => onUpdate(t.key, { title: e.target.value })}
              placeholder={`e.g. Task ${index + 1}`}
              disabled={saving}
              required
              className="bg-white text-xs border-[#e8e3db]"
            />
          </div>

          <div>
            <label className="mb-1 block text-xs font-semibold text-[#1a1a1a]">
              Description <span className="text-red-500">*</span>
            </label>
            <textarea
              value={t.desc}
              onChange={(e) => onUpdate(t.key, { desc: e.target.value })}
              placeholder="Task details and expectations for the user"
              disabled={saving}
              rows={2}
              required
              className="w-full rounded-md border border-[#e8e3db] bg-white px-3 py-2 text-xs text-[#1a1a1a] outline-none transition focus:border-[#1a1a1a] disabled:opacity-50"
            />
          </div>
        </div>

        {canRemove && (
          <button
            type="button"
            onClick={() => onRemove(t.key)}
            disabled={saving}
            className="rounded-md p-1.5 text-xs text-[#6b6b6b] hover:bg-[#f5f2ec] hover:text-red-600 transition cursor-pointer"
            aria-label="Remove task"
          >
            ✕
          </button>
        )}
      </div>

      {/* Config Row */}
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
        {/* Time Picker */}
        <div>
          <label className="mb-1 block text-xs font-medium text-[#6b6b6b]">
            Due Time (24h)
          </label>
          <Input
            type="time"
            value={t.time}
            onChange={(e) => onUpdate(t.key, { time: e.target.value })}
            disabled={saving}
            className="h-8 bg-white text-xs border-[#e8e3db]"
          />
        </div>

        {/* Priority & XP Badge */}
        <div>
          <div className="mb-1 flex items-center justify-between">
            <label className="text-xs font-medium text-[#6b6b6b]">
              Priority
            </label>
            <span className="text-[10px] font-semibold text-amber-700 bg-amber-100 px-1.5 py-0.5 rounded">
              +{t.points} XP
            </span>
          </div>
          <select
            value={t.priority}
            onChange={(e) => {
              const priority = Number(e.target.value) as TaskPriority;
              onUpdate(t.key, { priority, points: PRIORITY_XP[priority] });
            }}
            disabled={saving}
            className="h-8 w-full rounded-md border border-[#e8e3db] bg-white px-2 text-xs text-[#1a1a1a] focus:border-[#1a1a1a] outline-none cursor-pointer"
          >
            <option value={0}>Low (+20 XP)</option>
            <option value={1}>Medium (+40 XP)</option>
            <option value={2}>High (+80 XP)</option>
          </select>
        </div>

        {/* Recurring Cadence */}
        <div>
          <label className="mb-1 block text-xs font-medium text-[#6b6b6b]">
            Recurring Cadence
          </label>
          <select
            value={t.recurring}
            onChange={(e) => {
              const recurring = Number(e.target.value) as TaskRecurring;
              onUpdate(t.key, {
                recurring,
                weeklyDay:
                  recurring === 2
                    ? (t.weeklyDay ?? (new Date().getDay() || 7))
                    : null,
                monthlyDay: recurring === 3 ? (t.monthlyDay ?? 1) : null,
              });
            }}
            disabled={saving}
            className="h-8 w-full rounded-md border border-[#e8e3db] bg-white px-2 text-xs text-[#1a1a1a] focus:border-[#1a1a1a] outline-none cursor-pointer"
          >
            <option value={0}>One-off</option>
            <option value={1}>Daily</option>
            <option value={2}>Weekly</option>
            <option value={3}>Monthly</option>
          </select>
        </div>
      </div>

      {/* Conditional Day Selectors */}
      {t.recurring === 2 && (
        <div className="rounded-md border border-purple-200 bg-purple-50/40 p-2.5 space-y-1">
          <label className="block text-xs font-semibold text-purple-900">
            Active Day of Week
          </label>
          <select
            value={t.weeklyDay ?? 1}
            onChange={(e) =>
              onUpdate(t.key, { weeklyDay: Number(e.target.value) })
            }
            disabled={saving}
            className="h-8 w-full rounded-md border border-purple-200 bg-white px-2 text-xs text-[#1a1a1a] outline-none focus:border-purple-500 cursor-pointer"
          >
            {WEEKDAYS.map((day) => (
              <option key={day.value} value={day.value}>
                Every {day.label}
              </option>
            ))}
          </select>
        </div>
      )}

      {t.recurring === 3 && (
        <div className="rounded-md border border-purple-200 bg-purple-50/40 p-3 space-y-2">
          <label className="block text-xs font-semibold text-purple-900">
            Active Day of Month
          </label>

          {/* Quick Preset Buttons */}
          <div className="flex gap-1.5">
            {[
              { label: "1st", val: 1 },
              { label: "15th", val: 15 },
              { label: "Last Day", val: 0 },
            ].map((preset) => {
              const active = t.monthlyDay === preset.val;
              return (
                <button
                  key={preset.val}
                  type="button"
                  disabled={saving}
                  onClick={() => onUpdate(t.key, { monthlyDay: preset.val })}
                  className={`flex-1 rounded-md py-1 text-xs font-semibold border transition cursor-pointer ${
                    active
                      ? "border-purple-600 bg-purple-600 text-white"
                      : "border-purple-200 bg-white text-purple-900 hover:bg-purple-100/50"
                  }`}
                >
                  {preset.label}
                </button>
              );
            })}
          </div>

          {/* Custom Date Selector */}
        </div>
      )}

      {/* Assignment Controls */}
      <div className="border-t border-[#e8e3db] pt-3">
        <div className="mb-2 flex items-center gap-4 text-xs">
          <span className="font-semibold text-[#1a1a1a]">Assign to:</span>
          <label className="flex items-center gap-1.5 text-[#1a1a1a] cursor-pointer font-medium">
            <input
              type="radio"
              name={`assign-${t.key}`}
              checked={t.assignMode === "all"}
              onChange={() => onUpdate(t.key, { assignMode: "all" })}
              disabled={saving}
              className="accent-[#1a1a1a]"
            />
            All mission members
          </label>
          <label className="flex items-center gap-1.5 text-[#1a1a1a] cursor-pointer font-medium">
            <input
              type="radio"
              name={`assign-${t.key}`}
              checked={t.assignMode === "specific"}
              onChange={() => onUpdate(t.key, { assignMode: "specific" })}
              disabled={saving}
              className="accent-[#1a1a1a]"
            />
            Specific mission members
          </label>
        </div>

        {t.assignMode === "specific" && (
          <div className="space-y-1.5 pt-1">
            {normalizedMembers.length === 0 ? (
              <p className="text-xs text-amber-700 italic">
                No team members added to this mission yet. Add members in
                Section 2 above to select specific assignees.
              </p>
            ) : (
              <div className="flex flex-wrap gap-1.5">
                {normalizedMembers.map((u) => {
                  const selected = t.assigneeIds.includes(u.id);
                  return (
                    <button
                      key={u.id}
                      type="button"
                      disabled={saving}
                      onClick={() => onToggleAssignee(t.key, u.id)}
                      className={`rounded-full border px-3 py-1 text-xs font-medium transition cursor-pointer ${
                        selected
                          ? "border-[#1a1a1a] bg-[#1a1a1a] text-white"
                          : "border-[#e8e3db] bg-white text-[#1a1a1a] hover:bg-[#f5f2ec]"
                      }`}
                    >
                      {selected ? "✓ " : ""}
                      {u.username}
                    </button>
                  );
                })}
              </div>
            )}

            {isSpecificUnassigned && normalizedMembers.length > 0 && (
              <p className="text-[11px] text-amber-700 font-medium pt-1">
                ⚠️ Please select at least one assignee from the mission scope
                above.
              </p>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
