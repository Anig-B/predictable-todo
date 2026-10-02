"use client";

import { useEffect, useState, useCallback } from "react";
import { Button } from "@/components/ui/button";
import { FolderKanban, Plus } from "lucide-react";
import { toast } from "sonner";
import { NewMissionDialog } from "@/components/new-mission-dialog";
import {
  getMissionsData,
  toggleMissionArchiveStatus,
  deleteMissionPermanently,
  MissionWithStats,
  ArchivedMission,
} from "@/actions/missions";
import { MissionCard } from "@/components/missions/MissionCard";
import { ArchivedMissionsDrawer } from "@/components/missions/ArchivedMissionsDrawer";

export default function MissionsPage() {
  const [missions, setMissions] = useState<MissionWithStats[]>([]);
  const [archivedMissions, setArchivedMissions] = useState<ArchivedMission[]>(
    [],
  );
  const [loading, setLoading] = useState(true);
  const [showNewMissionDialog, setShowNewMissionDialog] = useState(false);
  const [openMissionMenuId, setOpenMissionMenuId] = useState<string | null>(
    null,
  );
  const [isArchiveOpen, setIsArchiveOpen] = useState(false);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const data = await getMissionsData();
      setMissions(data.activeMissions);
      setArchivedMissions(data.archivedMissions);
    } catch (err: any) {
      toast.error(err.message || "Failed to fetch missions");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleArchive = async (id: string, name: string) => {
    setOpenMissionMenuId(null);
    try {
      await toggleMissionArchiveStatus(id, false);
      toast.success(`"${name}" archived`);
      loadData();
    } catch (err: any) {
      toast.error(err.message || "Could not archive mission");
    }
  };

  const handleUnarchive = async (id: string, name: string) => {
    try {
      await toggleMissionArchiveStatus(id, true);
      toast.success(`"${name}" restored`);
      loadData();
    } catch (err: any) {
      toast.error(err.message || "Failed to restore mission");
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await deleteMissionPermanently(id);
      toast.success("Mission deleted permanently");
      loadData();
    } catch (err: any) {
      toast.error(err.message || "Failed to delete mission");
    }
  };

  if (loading) {
    return (
      <div className="p-8 max-w-7xl mx-auto space-y-8 animate-pulse">
        {/* Header Skeleton */}
        <div className="flex items-center justify-between pb-4 border-b border-[#e8e3db]">
          <div className="space-y-2">
            <div className="h-8 bg-[#e8e3db] rounded w-48"></div>
            <div className="h-4 bg-[#e8e3db] rounded w-80"></div>
          </div>
          <div className="h-10 bg-[#e8e3db] rounded w-44"></div>
        </div>

        {/* Cards Grid Skeleton */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[...Array(6)].map((_, i) => (
            <div
              key={i}
              className="h-56 bg-[#e8e3db] rounded-lg border border-[#e8e3db]"
            ></div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-6 relative min-h-screen pb-24">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-[#e8e3db]">
        <div>
          <h1 className="text-2xl font-bold text-[#1a1a1a] tracking-tight">
            Mission Packs
          </h1>
          <p className="text-sm text-[#8b8b8b] mt-1">
            Manage operational project packs, nested task groups, and team
            resource routing.
          </p>
        </div>
        <Button
          onClick={() => setShowNewMissionDialog(true)}
          className="bg-[#1a1a1a] hover:bg-black text-white text-xs uppercase font-semibold tracking-wider px-4 py-2 flex items-center gap-2 shadow-sm cursor-pointer"
        >
          <FolderKanban className="w-4 h-4" />
          Create Mission Pack
        </Button>
      </div>

      {/* Main Grid Content / Empty State */}
      {missions.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 px-4 bg-white border border-dashed border-[#e8e3db] rounded-lg text-center shadow-sm">
          <div className="w-12 h-12 rounded-full bg-[#f8f7f4] border border-[#e8e3db] flex items-center justify-center text-[#8b8b8b] mb-4">
            <FolderKanban className="w-6 h-6" />
          </div>
          <h3 className="text-base font-semibold text-[#1a1a1a] mb-1">
            No Active Missions
          </h3>
          <p className="text-sm text-[#8b8b8b] max-w-sm mb-6">
            There are currently no active mission packs in your workspace.
            Create one to organize project tasks.
          </p>
          <Button
            onClick={() => setShowNewMissionDialog(true)}
            variant="outline"
            className="border-[#e8e3db] text-[#1a1a1a] hover:bg-[#f8f7f4] text-xs uppercase font-semibold tracking-wider flex items-center gap-2 cursor-pointer"
          >
            <Plus className="w-4 h-4" />
            Create First Mission
          </Button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {missions.map((mission) => (
            <MissionCard
              key={mission.id}
              mission={mission}
              isMenuOpen={openMissionMenuId === mission.id}
              onToggleMenu={() =>
                setOpenMissionMenuId((prev) =>
                  prev === mission.id ? null : mission.id,
                )
              }
              onArchive={handleArchive}
            />
          ))}
        </div>
      )}

      {/* Drawer & Dialogs */}
      <ArchivedMissionsDrawer
        isOpen={isArchiveOpen}
        archivedMissions={archivedMissions}
        onToggle={() => setIsArchiveOpen((prev) => !prev)}
        onClose={() => setIsArchiveOpen(false)}
        onUnarchive={handleUnarchive}
        onDelete={handleDelete}
      />

      {showNewMissionDialog && (
        <NewMissionDialog
          onClose={() => setShowNewMissionDialog(false)}
          onSuccess={() => {
            setShowNewMissionDialog(false);
            loadData();
          }}
        />
      )}
    </div>
  );
}
