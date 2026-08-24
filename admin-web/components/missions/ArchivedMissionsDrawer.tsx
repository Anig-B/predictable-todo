"use client";

import { useRef, useEffect } from "react";
import { Archive, X, RotateCcw, Trash2 } from "lucide-react";
import { ArchivedMission } from "@/actions/missions";

interface ArchivedMissionsDrawerProps {
  isOpen: boolean;
  archivedMissions: ArchivedMission[];
  onToggle: () => void;
  onClose: () => void;
  onUnarchive: (id: string, name: string) => void;
  onDelete: (id: string) => void;
}

export function ArchivedMissionsDrawer({
  isOpen,
  archivedMissions,
  onToggle,
  onClose,
  onUnarchive,
  onDelete,
}: ArchivedMissionsDrawerProps) {
  const drawerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (drawerRef.current && !drawerRef.current.contains(e.target as Node)) {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [isOpen, onClose]);

  return (
    // Changed fixed to relative positioning anchored to the page container
    <div ref={drawerRef} className="fixed bottom-6 left-70 z-30">
      {isOpen && (
        <div className="mb-2 w-72 max-h-80 bg-white border border-[#e8e3db] rounded-xl shadow-xl flex flex-col overflow-hidden animate-in fade-in slide-in-from-bottom-2">
          <div className="p-3 border-b border-[#e8e3db] bg-[#fafaf9] flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Archive className="w-4 h-4 text-rose-500" />
              <span className="text-xs font-semibold text-[#1a1a1a]">
                Archived Missions
              </span>
            </div>
            <button
              onClick={onClose}
              className="p-1 hover:bg-[#e8e3db] rounded transition-colors text-gray-500"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="p-2 overflow-y-auto space-y-1.5 flex-1 max-h-60">
            {archivedMissions.length === 0 ? (
              <p className="text-xs text-gray-400 text-center py-6">
                No archived missions.
              </p>
            ) : (
              archivedMissions.map((item) => (
                <div
                  key={item.id}
                  className="p-2.5 bg-[#fafaf9] border border-[#e8e3db] rounded-lg flex items-center justify-between gap-2"
                >
                  <span className="text-xs font-medium text-[#1a1a1a] truncate">
                    {item.name}
                  </span>

                  <div className="flex items-center gap-1 shrink-0">
                    <button
                      onClick={() => onUnarchive(item.id, item.name)}
                      className="p-1 text-emerald-700 hover:bg-emerald-50 rounded border border-emerald-200 transition-colors"
                      title="Unarchive"
                    >
                      <RotateCcw className="w-3.5 h-3.5" />
                    </button>
                    <button
                      onClick={() => onDelete(item.id)}
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

      <button
        onClick={onToggle}
        className="bg-[#1a1a1a] text-white px-4 py-2.5 rounded-lg text-xs font-semibold uppercase tracking-wider shadow-lg hover:bg-black transition-colors flex items-center gap-2 border border-gray-800"
      >
        <Archive className="w-4 h-4 text-rose-400" />
        <span>Archive Missions</span>
      </button>
    </div>
  );
}
