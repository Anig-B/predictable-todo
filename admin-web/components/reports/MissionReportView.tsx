"use client";

import React from "react";
import { Grid } from "lucide-react";
import { ReportsPayload } from "@/actions/reports";

type MissionReportViewProps = {
  data: ReportsPayload;
  activeMission: ReportsPayload["missions"][number];
  onSelectMission: (id: string) => void;
  getHeatmapBg: (percentage: number) => string;
};

export function MissionReportView({
  data,
  activeMission,
  onSelectMission,
  getHeatmapBg,
}: MissionReportViewProps) {
  const activeMissionId = String(activeMission.id);

  const missionMembers = data.missionMembers[activeMissionId] || [];
  const missionLogs = data.missionActivities[activeMissionId] || [];

  return (
    <>
      {/* Selector Pills */}
      <div className="flex items-center gap-2 overflow-x-auto pb-2 w-full mb-6">
        {data.missions.map((m) => (
          <button
            key={m.id}
            onClick={() => onSelectMission(String(m.id))}
            className={`px-4 py-2 rounded-lg text-sm font-medium border transition-all whitespace-nowrap ${
              activeMissionId === String(m.id)
                ? "bg-[#1a1a1a] text-white border-[#1a1a1a]"
                : "bg-white text-gray-600 border-[#e8e3db] hover:border-gray-400"
            }`}
          >
            {m.name}
          </button>
        ))}
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
        <MetricCard
          title="Completion Progress"
          value={`${activeMission.completionRate}%`}
        />
        <MetricCard
          title="Tasks Completed"
          value={`${activeMission.tasksDone} / ${activeMission.tasksTotal}`}
        />
        <MetricCard
          title="XP Accumulated"
          value={`${activeMission.xpEarned} XP`}
        />
      </div>

      {/* Member Heatmap */}
      <div className="border border-[#e8e3db] rounded-xl bg-white p-6 mb-8">
        <div className="flex items-center gap-2 mb-1">
          <Grid className="w-5 h-5 text-[#1a1a1a]" />
          <h2 className="text-lg font-semibold text-[#1a1a1a]">
            Member Heatmap
          </h2>
        </div>
        <p className="text-sm text-gray-500 mb-6">
          Member performance visualizer for{" "}
          <span className="font-semibold text-gray-800">
            {activeMission.name}
          </span>
          .
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {missionMembers.map((mem, idx) => {
            const completionPct =
              mem.assigned > 0
                ? Math.round((mem.done / mem.assigned) * 100)
                : 0;

            return (
              <HeatmapCard
                key={`${mem.name}-${idx}`}
                title={mem.name}
                badge={`${mem.xp} XP`}
                subtext={`${mem.done} of ${mem.assigned} tasks completed`}
                progress={completionPct}
                progressLabel="Completion"
                getHeatmapBg={getHeatmapBg}
              />
            );
          })}
        </div>
      </div>

      {/* Logs & Member Breakdown Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="border border-[#e8e3db] rounded-xl bg-white p-6">
          <h2 className="text-lg font-semibold text-[#1a1a1a] mb-4">
            Activities on Mission
          </h2>
          {missionLogs.length === 0 ? (
            <p className="text-sm text-gray-500">
              No activity recorded for this mission.
            </p>
          ) : (
            <div className="space-y-3">
              {missionLogs.map((act) => (
                <ActivityItem
                  key={act.id}
                  title={act.task}
                  subtitle={act.timestamp}
                  points={act.points}
                />
              ))}
            </div>
          )}
        </div>

        <div className="border border-[#e8e3db] rounded-xl bg-white p-6">
          <h2 className="text-lg font-semibold text-[#1a1a1a] mb-4">
            Member Breakdown
          </h2>
          <div className="space-y-3">
            {missionMembers.map((mem, idx) => (
              <div
                key={`${mem.name}-${idx}`}
                className="p-3.5 border border-[#e8e3db] rounded-lg flex items-center justify-between"
              >
                <div>
                  <p className="text-sm font-semibold">{mem.name}</p>
                  <p className="text-xs text-gray-500">
                    {mem.done} of {mem.assigned} tasks completed
                  </p>
                </div>
                <span className="text-xs font-semibold bg-gray-100 px-2.5 py-1 rounded-full">
                  {mem.xp} XP
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

function MetricCard({
  title,
  value,
}: {
  title: string;
  value: React.ReactNode;
}) {
  return (
    <div className="p-5 border border-[#e8e3db] rounded-xl bg-white">
      <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
        {title}
      </span>
      <p className="text-2xl font-semibold text-[#1a1a1a] mt-2">{value}</p>
    </div>
  );
}

function HeatmapCard({
  title,
  badge,
  subtext,
  progress,
  progressLabel,
  getHeatmapBg,
}: {
  title: string;
  badge: string;
  subtext: string;
  progress: number;
  progressLabel: string;
  getHeatmapBg: (pct: number) => string;
}) {
  return (
    <div
      className={`p-4 rounded-xl border flex flex-col justify-between transition-all ${getHeatmapBg(
        progress,
      )}`}
    >
      <div>
        <div className="flex items-start justify-between gap-2">
          <p className="text-sm font-semibold truncate">{title}</p>
          <span className="text-xs font-bold px-2 py-0.5 rounded bg-black/10 whitespace-nowrap">
            {badge}
          </span>
        </div>
        <p className="text-xs opacity-80 mt-1">{subtext}</p>
      </div>

      <div className="mt-4 space-y-1.5">
        <div className="flex justify-between items-center text-xs font-semibold">
          <span>{progressLabel}</span>
          <span>{progress}%</span>
        </div>
        <div className="w-full bg-black/10 rounded-full h-1.5 overflow-hidden">
          <div
            className="bg-current h-full transition-all"
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>
    </div>
  );
}

function ActivityItem({
  title,
  subtitle,
  points,
}: {
  title: string;
  subtitle: string;
  points: number | null;
}) {
  return (
    <div className="p-3.5 border border-[#e8e3db] rounded-lg flex justify-between items-center">
      <div>
        <p className="text-sm font-medium">{title}</p>
        <p className="text-xs text-gray-500">{subtitle}</p>
      </div>
      {points !== null && (
        <span className="text-xs font-semibold bg-gray-100 px-2.5 py-1 rounded-full">
          +{points} XP
        </span>
      )}
    </div>
  );
}
