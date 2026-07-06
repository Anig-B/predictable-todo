"use client";

import { useState } from "react";
import { missions, users } from "@/lib/data"; // Pointing directly to your centralized mock data
import { Button } from "@/components/ui/button";
import { MoreVertical, FolderKanban, CheckSquare, Users2 } from "lucide-react";
import { toast } from "sonner";
import { NewMissionDialog } from "@/components/new-mission-dialog";
import Link from "next/link";

export default function MissionsPage() {
  const [showNewMissionDialog, setShowNewMissionDialog] = useState(false);
  const [openMissionMenuId, setOpenMissionMenuId] = useState<string | null>(
    null,
  );

  const handleArchiveMission = (missionName: string) => {
    setOpenMissionMenuId(null);
    toast.success(`"${missionName}" project pack archived`);
  };

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  return (
    <div className="p-8">
      {/* Page Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-semibold text-[#1a1a1a]">
            Mission Packs
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Manage operational project packs, nested task groups, and team
            resource routing.
          </p>
        </div>
        <Button
          onClick={() => setShowNewMissionDialog(true)}
          className="bg-[#1a1a1a] text-white hover:bg-[#333333] flex items-center gap-2"
        >
          <FolderKanban className="w-4 h-4" />
          Create Mission Pack
        </Button>
      </div>

      {/* Missions Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {missions.map((mission) => (
          <Link
            key={mission.id}
            href={`/missions/${mission.id}`}
            className="block"
          >
            <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 hover:shadow-md transition-all cursor-pointer h-full flex flex-col justify-between">
              <div>
                {/* Header with Menu */}
                <div className="flex items-start justify-between mb-2">
                  <h3 className="text-lg font-semibold text-[#1a1a1a] flex-1 truncate pr-2">
                    {mission.name}
                  </h3>
                  <div className="relative">
                    <button
                      onClick={(e) => {
                        e.preventDefault();
                        setOpenMissionMenuId(
                          openMissionMenuId === mission.id ? null : mission.id,
                        );
                      }}
                      className="p-1 hover:bg-[#e8e3db] rounded-md transition-colors"
                    >
                      <MoreVertical className="w-5 h-5 text-[#6b6b6b]" />
                    </button>
                    {openMissionMenuId === mission.id && (
                      <div className="absolute top-full right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-10 min-w-48">
                        <button
                          onClick={(e) => {
                            e.preventDefault();
                            setOpenMissionMenuId(null);
                            toast.info("Task batch edit coming soon");
                          }}
                          className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] first:rounded-t-lg"
                        >
                          Manage Tasks
                        </button>
                        <button
                          onClick={(e) => {
                            e.preventDefault();
                            setOpenMissionMenuId(null);
                            toast.info("Assign team workflows coming soon");
                          }}
                          className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a]"
                        >
                          Assign Team Members
                        </button>
                        <hr className="border-[#e8e3db]" />
                        <button
                          onClick={(e) => {
                            e.preventDefault();
                            handleArchiveMission(mission.name);
                          }}
                          className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-rose-600 last:rounded-b-lg"
                        >
                          Archive Pack
                        </button>
                      </div>
                    )}
                  </div>
                </div>

                {/* Meta Indicators for Task Breakdowns */}
                <div className="flex items-center gap-3 text-xs font-medium text-gray-400 mb-4">
                  <span className="flex items-center gap-1">
                    <CheckSquare className="w-3.5 h-3.5" />
                    {mission.questsTotal} Tasks in Pack
                  </span>
                  <span>•</span>
                  <span className="flex items-center gap-1">
                    <Users2 className="w-3.5 h-3.5" />
                    {mission.memberCount} Assigned
                  </span>
                </div>

                {/* Progress Bar Layout */}
                <div className="mb-2 mt-4">
                  <div className="w-full bg-[#e8e3db] rounded-full h-1.5">
                    <div
                      className="h-1.5 rounded-full transition-all duration-300"
                      style={{
                        backgroundColor: mission.color,
                        width: `${(mission.questsDone / mission.questsTotal) * 100}%`,
                      }}
                    />
                  </div>
                </div>
                <div className="flex justify-between items-center text-xs text-[#8b8b8b] mb-6">
                  <span>Task Pack Completion</span>
                  <span className="font-semibold text-gray-700">
                    {mission.questsDone}/{mission.questsTotal} Done
                  </span>
                </div>
              </div>

              {/* Bottom Row: Status Badge + Assigned Team Avatar Stack */}
              <div className="flex items-center justify-between pt-4 border-t border-[#e8e3db]/60 mt-auto">
                <span
                  className={`inline-block px-2 py-0.5 rounded text-xs font-semibold ${
                    mission.active
                      ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                      : "bg-gray-100 text-gray-600"
                  }`}
                >
                  {mission.active ? "Live Pack" : "Draft"}
                </span>

                {/* Inline Team Stack Preview */}
                <div className="flex -space-x-2 overflow-hidden">
                  {users.slice(0, 3).map((user) => (
                    <div
                      key={user.id}
                      title={user.name}
                      className=" h-6 w-6 rounded-full ring-2 ring-[#fafaf8] bg-gray-200 text-[9px] font-bold text-gray-600 flex items-center justify-center tracking-tighter"
                    >
                      {getInitials(user.name)}
                    </div>
                  ))}
                  {users.length > 3 && (
                    <div className=" h-6 w-6 rounded-full ring-2 ring-[#fafaf8] bg-gray-100 text-[9px] font-bold text-gray-500 flex items-center justify-center">
                      +{users.length - 3}
                    </div>
                  )}
                </div>
              </div>
            </div>
          </Link>
        ))}
      </div>

      {/* New Mission Dialog */}
      {showNewMissionDialog && (
        <NewMissionDialog
          onClose={() => setShowNewMissionDialog(false)}
          onSubmit={(data) => {
            setShowNewMissionDialog(false);
            toast.success("Mission pack configured with structural items");
          }}
        />
      )}
    </div>
  );
}
