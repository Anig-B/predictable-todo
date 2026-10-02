"use client";

import { RefreshCw } from "lucide-react";

interface SettingsHeaderProps {
  onRefresh: () => void;
}

export default function SettingsHeader({ onRefresh }: SettingsHeaderProps) {
  return (
    <div className="flex items-center justify-between mb-8">
      <div>
        <h1 className="text-2xl font-bold text-[#1a1a1a] tracking-tight">
          Manager Settings
        </h1>
        <p className="text-sm text-[#8b8b8b]">
          Configure your administrative profile and message active mission
          squads.
        </p>
      </div>
      <button
        onClick={onRefresh}
        title="Refresh settings"
        className="p-2 bg-white border border-[#e8e3db] hover:bg-[#efefeb] rounded-md text-[#6b6b6b] transition-colors shadow-sm cursor-pointer"
      >
        <RefreshCw className="w-4 h-4" />
      </button>
    </div>
  );
}
