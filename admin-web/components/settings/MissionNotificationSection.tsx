"use client";

import { Bell, Send, Loader2 } from "lucide-react";

interface Mission {
  id: string;
  name: string;
}

interface MissionNotificationSectionProps {
  missions: Mission[];
  selectedMissionId: string;
  notifTitle: string;
  notifBody: string;
  sendingNotif: boolean;
  setSelectedMissionId: (value: string) => void;
  setNotifTitle: (value: string) => void;
  setNotifBody: (value: string) => void;
  onSend: (e: React.FormEvent) => void;
}

export default function MissionNotificationSection({
  missions,
  selectedMissionId,
  notifTitle,
  notifBody,
  sendingNotif,
  setSelectedMissionId,
  setNotifTitle,
  setNotifBody,
  onSend,
}: MissionNotificationSectionProps) {
  return (
    <form
      onSubmit={onSend}
      className="bg-white border border-[#e8e3db] rounded-lg p-6 space-y-4 shadow-sm"
    >
      <div className="flex items-center justify-between pb-2 border-b border-[#e8e3db]">
        <h2 className="text-sm font-bold text-[#1a1a1a] uppercase tracking-wider flex items-center gap-2">
          <Bell className="w-4 h-4 text-[#1a1a1a]" />
          Notify Mission Members
        </h2>
        <span className="text-xs text-[#8b8b8b]">Target Mission Squad</span>
      </div>

      <div>
        <label className="block text-xs font-semibold text-[#8b8b8b] uppercase tracking-wider mb-1.5">
          Select Mission
        </label>
        <select
          value={selectedMissionId}
          onChange={(e) => setSelectedMissionId(e.target.value)}
          className="w-full px-3 py-2 bg-white border border-[#e8e3db] rounded-md text-sm text-[#1a1a1a] focus:outline-none focus:border-[#1a1a1a]"
          required
        >
          <option value="">-- Choose a mission --</option>
          {missions.map((m) => (
            <option key={m.id} value={m.id}>
              {m.name}
            </option>
          ))}
        </select>
      </div>

      <div>
        <label className="block text-xs font-semibold text-[#8b8b8b] uppercase tracking-wider mb-1.5">
          Alert Title
        </label>
        <input
          type="text"
          placeholder="e.g., Milestone Update / Deliverable Review"
          value={notifTitle}
          onChange={(e) => setNotifTitle(e.target.value)}
          className="w-full px-3 py-2 bg-white border border-[#e8e3db] rounded-md text-sm text-[#1a1a1a] focus:outline-none focus:border-[#1a1a1a]"
          required
        />
      </div>

      <div>
        <label className="block text-xs font-semibold text-[#8b8b8b] uppercase tracking-wider mb-1.5">
          Alert Message
        </label>
        <textarea
          rows={3}
          placeholder="Write a message to everyone working on this mission..."
          value={notifBody}
          onChange={(e) => setNotifBody(e.target.value)}
          className="w-full px-3 py-2 bg-white border border-[#e8e3db] rounded-md text-sm text-[#1a1a1a] focus:outline-none focus:border-[#1a1a1a] resize-none"
          required
        />
      </div>

      <div className="flex justify-end pt-2">
        <button
          type="submit"
          disabled={sendingNotif}
          className="flex items-center gap-2 px-4 py-2 bg-[#1a1a1a] hover:bg-black text-white text-xs font-semibold uppercase tracking-wider rounded-md transition-colors disabled:opacity-50 shadow-sm cursor-pointer"
        >
          {sendingNotif ? (
            <Loader2 className="w-3.5 h-3.5 animate-spin" />
          ) : (
            <Send className="w-3.5 h-3.5" />
          )}
          {sendingNotif ? "Sending..." : "Notify Members"}
        </button>
      </div>
    </form>
  );
}
