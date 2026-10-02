"use client";

import { User, Shield, Mail, Save, Loader2 } from "lucide-react";

interface ProfileSectionProps {
  userId: string | null;
  email: string;
  username: string;
  role: string;
  tagline: string;
  saving: boolean;
  setUsername: (value: string) => void;
  setTagline: (value: string) => void;
  onSave: (e: React.FormEvent) => void;
}

export default function ProfileSection({
  userId,
  email,
  username,
  role,
  tagline,
  saving,
  setUsername,
  setTagline,
  onSave,
}: ProfileSectionProps) {
  return (
    <form
      onSubmit={onSave}
      className="bg-white border border-[#e8e3db] rounded-lg p-6 space-y-5 shadow-sm"
    >
      <h2 className="text-sm font-bold text-[#1a1a1a] uppercase tracking-wider pb-2 border-b border-[#e8e3db]">
        Profile & Workspace Identity
      </h2>

      <div>
        <label className="block text-xs font-semibold text-[#8b8b8b] uppercase tracking-wider mb-2">
          Email Address
        </label>
        <div className="flex items-center gap-3 px-3 py-2 bg-[#f8f7f4] border border-[#e8e3db] rounded-md text-sm text-[#6b6b6b]">
          <Mail className="w-4 h-4 text-[#8b8b8b]" />
          <span>{email || "No email bound"}</span>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-xs font-semibold text-[#8b8b8b] uppercase tracking-wider mb-2">
            Username
          </label>
          <div className="relative flex items-center">
            <User className="absolute left-3 w-4 h-4 text-[#8b8b8b]" />
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full pl-9 pr-3 py-2 bg-white border border-[#e8e3db] rounded-md text-sm text-[#1a1a1a] focus:outline-none focus:border-[#1a1a1a]"
              minLength={3}
              required
            />
          </div>
        </div>

        <div>
          <label className="block text-xs font-semibold text-[#8b8b8b] uppercase tracking-wider mb-2">
            System Role
          </label>
          <div className="relative flex items-center">
            <Shield className="absolute left-3 w-4 h-4 text-[#8b8b8b]" />
            <input
              type="text"
              value={role}
              disabled
              className="w-full pl-9 pr-3 py-2 bg-[#f8f7f4] border border-[#e8e3db] rounded-md text-sm text-[#6b6b6b] capitalize cursor-not-allowed"
            />
          </div>
        </div>
      </div>

      <div>
        <label className="block text-xs font-semibold text-[#8b8b8b] uppercase tracking-wider mb-2">
          Tagline / Status
        </label>
        <input
          type="text"
          value={tagline}
          onChange={(e) => setTagline(e.target.value)}
          placeholder="#QUESTLOG"
          className="w-full px-3 py-2 bg-white border border-[#e8e3db] rounded-md text-sm text-[#1a1a1a] focus:outline-none focus:border-[#1a1a1a]"
        />
      </div>

      <div className="flex justify-end pt-2 border-t border-[#e8e3db]">
        <button
          type="submit"
          disabled={saving || !userId}
          className="flex items-center gap-2 px-4 py-2 bg-[#1a1a1a] hover:bg-black text-white text-sm font-medium rounded-md transition-colors disabled:opacity-50 shadow-sm cursor-pointer"
        >
          {saving ? (
            <Loader2 className="w-4 h-4 animate-spin" />
          ) : (
            <Save className="w-4 h-4" />
          )}
          {saving ? "Saving..." : "Save Profile"}
        </button>
      </div>
    </form>
  );
}
