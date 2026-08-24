"use client";

import { useState, useEffect, useCallback } from "react";
import { useAuthCheck } from "@/hooks/useAuthCheck";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";
import { getManagerReportsData, ReportsPayload } from "@/actions/reports";

import { ReportsHeader } from "@/components/reports/ReportsHeader";
import {
  ViewFilterBar,
  ViewMode,
  Timeframe,
} from "@/components/reports/ViewFilterBar";
import {
  UserReportView,
  UserOption,
} from "@/components/reports/UserReportView";
import {
  MissionReportView,
  MissionOption,
} from "@/components/reports/MissionReportView";

export default function ReportsPage() {
  const { loading: authLoading } = useAuthCheck();

  const [viewMode, setViewMode] = useState<ViewMode>("user");
  const [timeframe, setTimeframe] = useState<Timeframe>("weekly");

  const [loading, setLoading] = useState(true);
  const [isManager, setIsManager] = useState(false);
  const [reportData, setReportData] = useState<ReportsPayload | null>(null);

  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [selectedMissionId, setSelectedMissionId] = useState<string | null>(
    null,
  );

  const loadData = useCallback(async (tf: Timeframe) => {
    setLoading(true);
    try {
      const res = await getManagerReportsData(tf);
      setIsManager(res.isManager);
      setReportData(res.data);

      const data = res.data;
      if (data) {
        if (data.users.length > 0) {
          setSelectedUserId((prev) =>
            prev && data.users.some((u) => u.id === prev)
              ? prev
              : data.users[0].id,
          );
        }
        if (data.missions.length > 0) {
          setSelectedMissionId((prev) =>
            prev && data.missions.some((m) => m.id === prev)
              ? prev
              : data.missions[0].id,
          );
        }
      }
    } catch (err: any) {
      toast.error("Failed to load reports data");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (!authLoading) {
      loadData(timeframe);
    }
  }, [authLoading, timeframe, loadData]);

  const selectedUser =
    reportData?.users.find((u) => u.id === selectedUserId) ||
    reportData?.users[0] ||
    null;
  const selectedMission =
    reportData?.missions.find((m) => m.id === selectedMissionId) ||
    reportData?.missions[0] ||
    null;

  const handleExportCSV = () => {
    if (!reportData) return;
    const escapeCsv = (str: string) => `"${str.replace(/"/g, '""')}"`;
    let csvContent = "data:text/csv;charset=utf-8,";

    if (viewMode === "user" && selectedUser) {
      csvContent += "Task/Action,Project,Points,Date\n";
      const userActs = reportData.activities[selectedUser.id] || [];
      userActs.forEach((a) => {
        csvContent += `${escapeCsv(a.task)},${escapeCsv(a.project)},"${a.points ?? 0}","${a.timestamp}"\n`;
      });
    } else if (viewMode === "mission" && selectedMission) {
      csvContent += "Member,Assigned,Done,XP Earned\n";
      const members = reportData.missionMembers[selectedMission.id] || [];
      members.forEach((m) => {
        csvContent += `${escapeCsv(m.name)},"${m.assigned}","${m.done}","${m.xp}"\n`;
      });
    }

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `report_${viewMode}_${timeframe}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    toast.success("CSV report downloaded");
  };

  if (authLoading || loading) {
    return (
      <div className="flex h-96 items-center justify-center p-8">
        <Loader2 className="w-6 h-6 animate-spin text-[#1a1a1a]" />
      </div>
    );
  }

  if (!isManager) {
    return (
      <div className="p-8">
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-12 text-center text-[#8b8b8b]">
          Access restricted. Manager privileges required to view reports.
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 space-y-8">
      <ReportsHeader
        hasMissions={(reportData?.missions.length || 0) > 0}
        onExportCSV={handleExportCSV}
      />

      <ViewFilterBar
        viewMode={viewMode}
        timeframe={timeframe}
        onViewModeChange={setViewMode}
        onTimeframeChange={setTimeframe}
      />

      {!reportData || reportData.missions.length === 0 ? (
        <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-12 text-center text-[#8b8b8b]">
          You are not managing any active missions yet.
        </div>
      ) : (
        <>
          {viewMode === "user" && selectedUser && (
            <UserReportView
              usersList={reportData.users}
              selectedUser={selectedUser}
              userActivities={reportData.activities[selectedUser.id] || []}
              completionStats={
                reportData.completionStats[selectedUser.id] || {
                  done: 0,
                  total: 0,
                  rate: 0,
                }
              }
              onSelectUser={(u: UserOption) => setSelectedUserId(u.id)}
            />
          )}

          {viewMode === "mission" && selectedMission && (
            <MissionReportView
              missionsList={reportData.missions}
              selectedMission={selectedMission}
              missionMembers={
                reportData.missionMembers[selectedMission.id] || []
              }
              onSelectMission={(m: MissionOption) => setSelectedMissionId(m.id)}
            />
          )}
        </>
      )}
    </div>
  );
}
