"use client";

import Link from "next/link";
import {
  CheckSquare,
  Users2,
  MoreVertical,
  Layers,
  Archive,
  ArrowRight,
} from "lucide-react";
import { MissionWithStats } from "@/actions/missions";

interface MissionCardProps {
  mission: MissionWithStats;
  isMenuOpen: boolean;
  onToggleMenu: () => void;
  onArchive: (id: string, name: string) => void;
}

export function MissionCard({
  mission,
  isMenuOpen,
  onToggleMenu,
  onArchive,
}: MissionCardProps) {
  const progressPercent =
    mission.questsTotal > 0
      ? Math.round((mission.questsDone / mission.questsTotal) * 100)
      : 0;

  return (
    <div className="bg-[#fafaf8] border border-[#e8e3db] hover:border-[#1a1a1a]/30 rounded-lg p-6 transition-all duration-200 h-full flex flex-col justify-between relative group shadow-xs hover:shadow-md">
      <div>
        {/* Title and Options Header */}
        <div className="flex items-start justify-between gap-3 mb-3">
          <Link
            href={`/missions/${mission.id}`}
            className="text-base font-bold text-[#1a1a1a] hover:underline truncate transition-colors leading-snug"
          >
            {mission.name}
          </Link>

          {/* More Action Dropdown */}
          <div className="relative z-10 shrink-0">
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                onToggleMenu();
              }}
              aria-label="Toggle Mission Menu"
              className="p-1 hover:bg-[#e8e3db] text-[#8b8b8b] hover:text-[#1a1a1a] rounded-md transition-colors cursor-pointer"
            >
              <MoreVertical className="w-4 h-4" />
            </button>

            {isMenuOpen && (
              <div className="absolute top-full right-0 mt-1 bg-white border border-[#e8e3db] rounded-md shadow-lg z-20 min-w-44 py-1 animate-in fade-in zoom-in-95 duration-100">
                <Link
                  href={`/missions/${mission.id}`}
                  className="flex items-center gap-2 px-3 py-2 text-xs font-semibold text-[#1a1a1a] hover:bg-[#f8f7f4] transition-colors"
                >
                  <Layers className="w-3.5 h-3.5 text-[#8b8b8b]" />
                  Manage Tasks
                </Link>
                <div className="my-1 border-t border-[#e8e3db]" />
                <button
                  type="button"
                  onClick={() => onArchive(mission.id, mission.name)}
                  className="w-full flex items-center gap-2 px-3 py-2 text-xs font-semibold text-rose-600 hover:bg-rose-50 transition-colors cursor-pointer"
                >
                  <Archive className="w-3.5 h-3.5 text-rose-600" />
                  Archive Pack
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Task Stats Overview */}
        <Link href={`/missions/${mission.id}`} className="block group/link">
          <div className="flex items-center gap-3 text-xs font-medium text-[#8b8b8b] mb-4">
            <span className="flex items-center gap-1.5">
              <CheckSquare className="w-3.5 h-3.5 text-[#1a1a1a]" />
              {mission.questsTotal} Tasks
            </span>
            <span className="text-[#e8e3db]">•</span>
            <span className="flex items-center gap-1.5">
              <Users2 className="w-3.5 h-3.5 text-[#1a1a1a]" />
              {mission.memberCount} Members
            </span>
          </div>

          {/* Progress Bar */}
          <div className="space-y-1.5 my-4">
            <div className="w-full bg-[#e8e3db] rounded-full h-2 overflow-hidden p-0.5">
              <div
                className="h-full rounded-full bg-[#1a1a1a] transition-all duration-500 ease-out"
                style={{ width: `${progressPercent}%` }}
              />
            </div>
            <div className="flex justify-between items-center text-[11px] text-[#8b8b8b] pt-1">
              <span>Task Pack Completion</span>
              <span className="font-bold text-[#1a1a1a]">
                {mission.questsDone}/{mission.questsTotal} ({progressPercent}%)
              </span>
            </div>
          </div>
        </Link>
      </div>

      {/* Footer Status & Action */}
      <div className="flex items-center justify-between pt-4 border-t border-[#e8e3db] mt-auto">
        <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider bg-emerald-50 text-emerald-800 border border-emerald-200">
          Live Pack
        </span>

        <Link
          href={`/missions/${mission.id}`}
          className="inline-flex items-center gap-1 text-xs font-semibold text-[#8b8b8b] group-hover:text-[#1a1a1a] transition-colors"
        >
          View Details
          <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-0.5" />
        </Link>
      </div>
    </div>
  );
}
