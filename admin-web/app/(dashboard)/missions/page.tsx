"use client";

import { useEffect, useState, useRef } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import {
  FolderKanban,
  CheckSquare,
  Users2,
  MoreVertical,
  Loader2,
  Archive,
  X,
  RotateCcw,
  Trash2,
} from "lucide-react";
import { toast } from "sonner";
import { NewMissionDialog } from "@/components/new-mission-dialog";
import Link from "next/link";

interface MissionWithStats {
  id: string;
  name: string;
  description: string | null;
  active: boolean;
  questsTotal: number;
  questsDone: number;
  memberCount: number;
}

interface ArchivedMission {
  id: string;
  name: string;
}

export default function MissionsPage() {
  const [missions, setMissions] = useState<MissionWithStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [showNewMissionDialog, setShowNewMissionDialog] = useState(false);
  const [openMissionMenuId, setOpenMissionMenuId] = useState<string | null>(
    null,
  );

  // Archive Popover State & Ref
  const [isArchiveOpen, setIsArchiveOpen] = useState(false);
  const [archivedMissions, setArchivedMissions] = useState<ArchivedMission[]>(
    [],
  );
  const [fetchingArchived, setFetchingArchived] = useState(false);
  const archiveContainerRef = useRef<HTMLDivElement>(null);

  const supabase = createClient();

  // Close archive popover when clicking anywhere outside of it
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        archiveContainerRef.current &&
        !archiveContainerRef.current.contains(event.target as Node)
      ) {
        setIsArchiveOpen(false);
      }
    };

    if (isArchiveOpen) {
      document.addEventListener("mousedown", handleClickOutside);
    }

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [isArchiveOpen]);

  // Load active missions
  const loadMissions = async () => {
    try {
      setLoading(true);

      const { data, error } = await supabase
        .from("missions")
        .select(
          `
          id,
          name,
          description,
          is_active,
          created_at,
          tasks:tasks!tasks_mission_id_fk_fkey ( id, done ),
          mission_members!left ( user_id )
        `,
        )
        .eq("is_active", true)
        .order("created_at", { ascending: false });

      if (error) throw error;

      const formattedMissions: MissionWithStats[] = (data || []).map(
        (m: any) => {
          const taskList = Array.isArray(m.tasks) ? m.tasks : [];
          const memberList = Array.isArray(m.mission_members)
            ? m.mission_members
            : [];

          return {
            id: m.id,
            name: m.name,
            description: m.description || "",
            active: Boolean(m.is_active),
            questsTotal: taskList.length,
            questsDone: taskList.filter((t: any) => Boolean(t.done)).length,
            memberCount: memberList.length,
          };
        },
      );

      setMissions(formattedMissions);
    } catch (error: any) {
      console.error("Error loading missions:", error);
      toast.error(error.message || "Failed to fetch missions");
    } finally {
      setLoading(false);
    }
  };

  // Fetch inactive missions for the popup list
  const fetchArchivedMissions = async () => {
    try {
      setFetchingArchived(true);
      const { data, error } = await supabase
        .from("missions")
        .select("id, name")
        .eq("is_active", false)
        .order("created_at", { ascending: false });

      if (error) throw error;
      setArchivedMissions(data || []);
    } catch (err: any) {
      toast.error("Failed to load archived missions");
    } finally {
      setFetchingArchived(false);
    }
  };

  const toggleArchiveDrawer = () => {
    if (!isArchiveOpen) {
      fetchArchivedMissions();
    }
    setIsArchiveOpen(!isArchiveOpen);
  };

  useEffect(() => {
    loadMissions();
  }, []);

  const handleArchiveMission = async (
    missionId: string,
    missionName: string,
  ) => {
    setOpenMissionMenuId(null);
    try {
      const { error } = await supabase
        .from("missions")
        .update({ is_active: false })
        .eq("id", missionId);

      if (error) throw error;

      toast.success(`"${missionName}" archived`);
      loadMissions();
    } catch (err: any) {
      toast.error(err.message || "Could not archive mission");
    }
  };

  const handleUnarchive = async (id: string, name: string) => {
    try {
      const { error } = await supabase
        .from("missions")
        .update({ is_active: true })
        .eq("id", id);

      if (error) throw error;

      toast.success(`"${name}" restored`);
      setArchivedMissions((prev) => prev.filter((m) => m.id !== id));
      loadMissions();
    } catch (err: any) {
      toast.error(err.message || "Failed to unarchive mission");
    }
  };

  const handleDeleteArchived = async (id: string) => {
    try {
      // 1. Clean up tasks manually (prevents trigger mismatches on task delete)
      const { error: taskErr } = await supabase
        .from("tasks")
        .delete()
        .eq("mission_id", id);

      if (taskErr) {
        console.warn("Could not pre-delete tasks:", taskErr.message);
      }

      // 2. Clean up mission members manually
      const { error: memberErr } = await supabase
        .from("mission_members")
        .delete()
        .eq("mission_id", id);

      if (memberErr) {
        console.warn("Could not pre-delete members:", memberErr.message);
      }

      // 3. Delete target mission
      const { data, error } = await supabase
        .from("missions")
        .delete()
        .eq("id", id)
        .select();

      if (error) {
        console.error("Supabase Delete Error:", {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code,
        });
        throw new Error(error.message || "Database rejected delete operation.");
      }

      if (!data || data.length === 0) {
        toast.error("Delete blocked: Check Row Level Security (RLS) policies.");
        return;
      }

      toast.success("Mission deleted permanently");
      setArchivedMissions((prev) => prev.filter((m) => m.id !== id));
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
      {/* Main Header */}
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

      {/* Grid */}
      {missions.length === 0 ? (
        <div className="text-center py-12 border border-dashed border-[#e8e3db] rounded-lg">
          <p className="text-gray-500 text-sm">
            No active missions found. Create your first mission pack to get
            started!
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {missions.map((mission) => {
            const progressPercent =
              mission.questsTotal > 0
                ? Math.round((mission.questsDone / mission.questsTotal) * 100)
                : 0;

            return (
              <div
                key={mission.id}
                className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 hover:shadow-md transition-all h-full flex flex-col justify-between relative"
              >
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
                          setOpenMissionMenuId(
                            openMissionMenuId === mission.id
                              ? null
                              : mission.id,
                          );
                        }}
                        className="p-1 hover:bg-[#e8e3db] rounded-md transition-colors"
                      >
                        <MoreVertical className="w-5 h-5 text-[#6b6b6b]" />
                      </button>

                      {openMissionMenuId === mission.id && (
                        <div className="absolute top-full right-0 mt-2 bg-white border border-[#e8e3db] rounded-lg shadow-lg z-20 min-w-48">
                          <Link
                            href={`/missions/${mission.id}`}
                            className="block px-4 py-2 hover:bg-[#f0ebe4] text-sm text-[#1a1a1a] first:rounded-t-lg"
                            onClick={() => setOpenMissionMenuId(null)}
                          >
                            Manage Tasks
                          </Link>
                          <hr className="border-[#e8e3db]" />
                          <button
                            onClick={() =>
                              handleArchiveMission(mission.id, mission.name)
                            }
                            className="w-full text-left px-4 py-2 hover:bg-[#f0ebe4] text-sm text-rose-600 last:rounded-b-lg"
                          >
                            Archive Pack
                          </button>
                        </div>
                      )}
                    </div>
                  </div>

                  <Link
                    href={`/missions/${mission.id}`}
                    className="block text-inherit"
                  >
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
                        {mission.questsDone}/{mission.questsTotal} (
                        {progressPercent}%)
                      </span>
                    </div>
                  </Link>
                </div>

                <div className="flex items-center justify-between pt-4 border-t border-[#e8e3db]/60 mt-auto">
                  <span
                    className={`inline-block px-2 py-0.5 rounded text-xs font-semibold ${
                      mission.active
                        ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                        : "bg-gray-100 text-gray-600 border border-gray-200"
                    }`}
                  >
                    {mission.active ? "Live Pack" : "Archived"}
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* BOTTOM-LEFT ARCHIVE POPOVER CONTAINER */}
      <div ref={archiveContainerRef} className="fixed bottom-2 left-55 z-30">
        {/* Scrollable Popup (Opens Upward Above Button) */}
        {isArchiveOpen && (
          <div className="mb-2 w-72 max-h-80 bg-white border border-[#e8e3db] rounded-xl shadow-xl flex flex-col overflow-hidden animate-in fade-in slide-in-from-bottom-2">
            <div className="p-3 border-b border-[#e8e3db] bg-[#fafaf9] flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Archive className="w-4 h-4 text-rose-500" />
                <span className="text-xs font-semibold text-[#1a1a1a]">
                  Archived Missions
                </span>
              </div>
              <button
                onClick={() => setIsArchiveOpen(false)}
                className="p-1 hover:bg-[#e8e3db] rounded transition-colors text-gray-500"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="p-2 overflow-y-auto space-y-1.5 flex-1 max-h-60">
              {fetchingArchived ? (
                <div className="flex items-center justify-center py-6 text-xs text-gray-400 gap-2">
                  <Loader2 className="w-3.5 h-3.5 animate-spin" /> Loading...
                </div>
              ) : archivedMissions.length === 0 ? (
                <p className="text-xs text-gray-400 text-center py-6">
                  No archived missions.
                </p>
              ) : (
                archivedMissions.map((item) => (
                  <div
                    key={item.id}
                    className="p-2.5 bg-[#fafaf9] border border-[#e8e3db] rounded-lg flex items-center justify-between gap-2"
                  >
                    {/* Non-clickable name */}
                    <span className="text-xs font-medium text-[#1a1a1a] truncate">
                      {item.name}
                    </span>

                    {/* Actions */}
                    <div className="flex items-center gap-1 shrink-0">
                      <button
                        onClick={() => handleUnarchive(item.id, item.name)}
                        className="p-1 text-emerald-700 hover:bg-emerald-50 rounded border border-emerald-200 transition-colors"
                        title="Unarchive"
                      >
                        <RotateCcw className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleDeleteArchived(item.id)}
                        className="p-1 text-rose-600 hover:bg-rose-50 rounded border border-rose-200 transition-colors"
                        title="Delete permanently"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        )}

        {/* Trigger Button */}
        <button
          onClick={toggleArchiveDrawer}
          className="bg-[#1a1a1a] text-white px-4 py-2.5 rounded-lg text-xs font-semibold uppercase tracking-wider shadow-lg hover:bg-black transition-colors flex items-center gap-2 border border-gray-800"
        >
          <Archive className="w-4 h-4 text-rose-400" />
          <span>Archive Missions</span>
        </button>
      </div>

      {showNewMissionDialog && (
        <NewMissionDialog
          onClose={() => setShowNewMissionDialog(false)}
          onSuccess={() => {
            setShowNewMissionDialog(false);
            loadMissions();
          }}
        />
      )}
    </div>
  );
}
