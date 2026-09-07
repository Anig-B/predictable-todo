"use client";

import { useState } from "react";
import Link from "next/link";
import {
  ChevronDown,
  CheckCircle2,
  Clock,
  ExternalLink,
  Folder,
  ArrowRight,
  ListTodo,
} from "lucide-react";
import { PendingReview, ActiveMission } from "@/actions/reports";

export interface UserOption {
  id: string;
  name: string;
  avatarUrl?: string;
}

export interface UserActivity {
  id: string;
  task: string;
  project: string;
  points: number | null;
  timestamp: string;
}

export interface UserReportViewProps {
  usersList: UserOption[];
  selectedUser: UserOption;
  userActivities?: UserActivity[];
  completionStats: {
    done: number;
    total: number;
    pending: number;
    rate: number;
  };
  pendingReviews?: PendingReview[];
  activeMissions?: ActiveMission[];
  onSelectUser: (user: UserOption) => void;
}

export function UserReportView({
  usersList,
  selectedUser,
  userActivities = [],
  completionStats,
  pendingReviews = [],
  activeMissions = [],
  onSelectUser,
}: UserReportViewProps) {
  const [selectedMissionFilter, setSelectedMissionFilter] =
    useState("All Missions");

  const filteredMissions =
    selectedMissionFilter === "All Missions"
      ? activeMissions
      : activeMissions.filter((m) => m.name === selectedMissionFilter);

  return (
    <div className="space-y-6 max-w-5xl mx-auto p-6 bg-[#fafaf8] border border-[#e8e3db] rounded-xl text-[#1a1a1a]">
      {/* Header & Controls */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-6 border-b border-[#e8e3db]">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-full bg-[#e8e3db] flex items-center justify-center overflow-hidden font-semibold text-lg text-[#6b6b6b]">
            {selectedUser.avatarUrl ? (
              <img
                src={selectedUser.avatarUrl}
                alt={selectedUser.name}
                className="w-full h-full object-cover"
              />
            ) : (
              selectedUser.name.charAt(0)
            )}
          </div>
          <div>
            <h1 className="text-xl font-bold text-[#1a1a1a]">
              {selectedUser.name}
            </h1>
          </div>
        </div>

        <div className="flex items-center gap-3">
          {/* User Selector Dropdown */}
          <div className="relative">
            <select
              value={selectedUser.id}
              onChange={(e) => {
                const found = usersList.find((u) => u.id === e.target.value);
                if (found) onSelectUser(found);
              }}
              className="appearance-none bg-white border border-[#e8e3db] rounded-lg px-4 py-2 pr-8 text-sm font-medium hover:bg-[#f0ebe4] transition-colors cursor-pointer focus:outline-none"
            >
              {usersList.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.name}
                </option>
              ))}
            </select>
            <ChevronDown className="w-4 h-4 absolute right-2.5 top-1/2 -translate-y-1/2 text-[#6b6b6b] pointer-events-none" />
          </div>

          {/* Mission Filter Dropdown */}
          <div className="relative">
            <select
              value={selectedMissionFilter}
              onChange={(e) => setSelectedMissionFilter(e.target.value)}
              className="appearance-none bg-white border border-[#e8e3db] rounded-lg px-4 py-2 pr-8 text-sm font-medium hover:bg-[#f0ebe4] transition-colors cursor-pointer focus:outline-none"
            >
              <option>All Missions</option>
              {activeMissions.map((m) => (
                <option key={m.id} value={m.name}>
                  {m.name}
                </option>
              ))}
            </select>
            <ChevronDown className="w-4 h-4 absolute right-2.5 top-1/2 -translate-y-1/2 text-[#6b6b6b] pointer-events-none" />
          </div>
        </div>
      </div>

      {/* Metrics at a Glance */}
      <div>
        <h2 className="text-xs font-bold uppercase tracking-wider text-[#8b8b8b] mb-3">
          Metrics at a Glance
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="bg-white border border-[#e8e3db] rounded-lg p-5">
            <p className="text-sm text-[#6b6b6b] mb-1">Completion Rate</p>
            <p className="text-3xl font-bold">{completionStats.rate}%</p>
          </div>
          <div className="bg-white border border-[#e8e3db] rounded-lg p-5">
            <p className="text-sm text-[#6b6b6b] mb-1">Completed Tasks</p>
            <p className="text-3xl font-bold">{completionStats.done}</p>
          </div>
          <div className="bg-white border border-[#e8e3db] rounded-lg p-5 flex items-center justify-between">
            <div>
              <p className="text-sm text-[#6b6b6b] mb-1">Pending Tasks</p>
              <p className="text-3xl font-bold">{completionStats.pending}</p>
            </div>
            <ListTodo className="w-8 h-8 text-[#6b6b6b]" />
          </div>
        </div>
      </div>

      {/* Pending Reviews */}
      <div>
        <h2 className="text-xs font-bold uppercase tracking-wider text-[#8b8b8b] mb-3">
          Pending Reviews ({pendingReviews.length})
        </h2>
        <div className="space-y-3">
          {pendingReviews.length === 0 ? (
            <div className="bg-white border border-[#e8e3db] rounded-lg p-4 text-center text-sm text-[#8b8b8b]">
              No pending reviews
            </div>
          ) : (
            pendingReviews.map((review) => (
              <div
                key={review.id}
                className="bg-white border border-[#e8e3db] rounded-lg p-4 flex flex-col md:flex-row md:items-center justify-between gap-4"
              >
                <div className="space-y-1">
                  <p className="text-sm font-semibold">
                    Task: {review.task}{" "}
                    <span className="font-normal text-[#6b6b6b]">
                      | Mission: {review.mission}
                    </span>
                  </p>
                  <div className="flex items-center gap-2 text-xs text-[#6b6b6b]">
                    <span>Note: "{review.note}"</span>
                    {review.proofUrl && (
                      <a
                        href={review.proofUrl}
                        target="_blank"
                        rel="noreferrer"
                        className="inline-flex items-center gap-1 text-blue-600 hover:underline font-medium"
                      >
                        [Proof Link] <ExternalLink className="w-3 h-3" />
                      </a>
                    )}
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <Link
                    href={`/missions/${review.missionId}`}
                    className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-[#1a1a1a] text-white text-xs font-medium rounded-md hover:bg-[#333333] transition-colors"
                  >
                    View in Mission <ArrowRight className="w-3.5 h-3.5" />
                  </Link>
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Active Missions */}
      <div>
        <h2 className="text-xs font-bold uppercase tracking-wider text-[#8b8b8b] mb-3">
          Active Missions
        </h2>
        <div className="space-y-4">
          {filteredMissions.length === 0 ? (
            <div className="bg-white border border-[#e8e3db] rounded-lg p-4 text-center text-sm text-[#8b8b8b]">
              No active missions
            </div>
          ) : (
            filteredMissions.map((mission) => (
              <div
                key={mission.id}
                className="bg-white border border-[#e8e3db] rounded-lg p-5 space-y-4"
              >
                {/* Mission Progress Header */}
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2 font-semibold text-sm">
                      <Folder className="w-4 h-4 text-[#6b6b6b]" />
                      <Link
                        href={`/missions/${mission.id}`}
                        className="hover:underline hover:text-blue-600"
                      >
                        Mission: {mission.name}
                      </Link>
                    </div>
                    <span className="text-xs font-medium text-[#6b6b6b]">
                      {mission.progress}%
                    </span>
                  </div>
                  {/* Progress Bar */}
                  <div className="w-full h-2 bg-[#f0ebe4] rounded-full overflow-hidden">
                    <div
                      className="h-full bg-[#1a1a1a] transition-all duration-300"
                      style={{ width: `${mission.progress}%` }}
                    />
                  </div>
                </div>

                {/* Task Breakdown */}
                <div className="space-y-2 pt-2 border-t border-[#f0ebe4]">
                  {mission.tasks.map((task) => (
                    <div
                      key={task.id}
                      className="flex items-center justify-between text-xs py-1"
                    >
                      <div className="flex items-center gap-2">
                        {task.status === "completed" && (
                          <CheckCircle2 className="w-3.5 h-3.5 text-green-600" />
                        )}
                        {task.status === "pending_approval" && (
                          <Clock className="w-3.5 h-3.5 text-amber-600" />
                        )}
                        {task.status === "due" && (
                          <span className="w-3.5 h-3.5 rounded-full border border-[#8b8b8b] inline-block" />
                        )}
                        <span
                          className={
                            task.status === "completed"
                              ? "line-through text-[#8b8b8b]"
                              : "text-[#1a1a1a]"
                          }
                        >
                          {task.title}
                        </span>
                      </div>

                      <span className="text-[#8b8b8b]">
                        (
                        {task.status === "completed"
                          ? `Completed ${task.dateText}`
                          : task.status === "pending_approval"
                            ? "Pending Approval"
                            : `Due ${task.dateText}`}
                        )
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
