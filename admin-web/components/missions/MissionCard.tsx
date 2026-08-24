"use client";

import Link from "next/link";
import { CheckSquare, Users2, MoreVertical } from "lucide-react";
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
    <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 hover:shadow-md transition-all h-full flex flex-col justify-between relative">
      <div>
        <div className="flex items-start justify-between mb-2">
          <Link
            href={`/missions/${mission.id}`}
            className="text-lg font-semibold text-[#1a1a1a] hover:underline flex-1 truncate pr-2"
          >
            {mission.name}
          </Link>

          <div className="relative z-10">
            <button
              onClick={(e) => {
                e.stopPropagation();
                onToggleMenu();
              }}
              className="p-1 hover:bg-[#e8e3db] rounded-md transition-colors"
            >
              <MoreVertical className="w-5 h-5 text-[#6b6b6b]" />
            </button>

            {isMenuOpen && (
              <div className="absolute top-full right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-20 min-w-48">
                <Link
                  href={`/missions/${mission.id}`}
                  className="block px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] rounded-t-lg"
                >
                  Manage Tasks
                </Link>
                <hr className="border-[#e8e3db]" />
                <button
                  onClick={() => onArchive(mission.id, mission.name)}
                  className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-rose-600 rounded-b-lg"
                >
                  Archive Pack
                </button>
              </div>
            )}
          </div>
        </div>

        <Link href={`/missions/${mission.id}`} className="block text-inherit">
          <div className="flex items-center gap-3 text-xs font-medium text-gray-400 mb-4">
            <span className="flex items-center gap-1">
              <CheckSquare className="w-3.5 h-3.5" />
              {mission.questsTotal} Tasks
            </span>
            <span>•</span>
            <span className="flex items-center gap-1">
              <Users2 className="w-3.5 h-3.5" />
              {mission.memberCount} Members
            </span>
          </div>

          <div className="mb-2 mt-4">
            <div className="w-full bg-[#e8e3db] rounded-full h-1.5 overflow-hidden">
              <div
                className="h-1.5 rounded-full bg-[#1a1a1a] transition-all duration-300"
                style={{ width: `${progressPercent}%` }}
              />
            </div>
          </div>
          <div className="flex justify-between items-center text-xs text-[#8b8b8b] mb-6">
            <span>Task Pack Completion</span>
            <span className="font-semibold text-gray-700">
              {mission.questsDone}/{mission.questsTotal} ({progressPercent}%)
            </span>
          </div>
        </Link>
      </div>

      <div className="flex items-center justify-between pt-4 border-t border-[#e8e3db]/60 mt-auto">
        <span className="inline-block px-2 py-0.5 rounded text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
          Live Pack
        </span>
      </div>
    </div>
  );
}
