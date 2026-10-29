// lib/utils.ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const getInitials = (name?: string): string => {
  if (!name) return "U";
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
};

export const getTimeAgo = (dateString: string): string => {
  const diff = Math.floor(
    (new Date().getTime() - new Date(dateString).getTime()) / 1000,
  );
  if (diff < 60) return "Just now";
  if (diff < 3600) return `${Math.floor(diff / 60)} min ago`;
  if (diff < 86400) return `${Math.floor(diff / 3600)} hours ago`;
  if (diff < 172800) return "Yesterday";
  return `${Math.floor(diff / 86400)} days ago`;
};

/**
 * Constructs an ISO timestamptz string from a 24h time string (e.g. "14:30")
 */
export function constructDueAtTimestamp(timeStr: string): string | null {
  if (!timeStr) return null;
  const [hours, minutes] = timeStr.split(":").map(Number);
  if (isNaN(hours) || isNaN(minutes)) return null;

  const due = new Date();
  due.setHours(hours, minutes, 0, 0);

  // If the time entered has already passed today, set due date for tomorrow
  if (due.getTime() <= Date.now()) {
    due.setDate(due.getDate() + 1);
  }

  return due.toISOString();
}
