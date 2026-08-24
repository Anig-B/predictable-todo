"use client";

import { useEffect, useState, useCallback } from "react";
import { Button } from "@/components/ui/button";
import { FolderKanban, Loader2 } from "lucide-react";
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
      <div className="flex items-center justify-center min-h-100">
        <Loader2 className="w-6 h-6 animate-spin text-gray-500" />
      </div>
    );
  }

  return (
    <div className="p-8 relative min-h-screen pb-24">
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

      {missions.length === 0 ? (
        <div className="text-center py-12 border border-dashed border-[#e8e3db] rounded-lg">
          <p className="text-gray-500 text-sm">
            No active missions found. Create your first mission pack to get
            started!
          </p>
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
