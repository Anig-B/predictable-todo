import { TrendingUp } from "lucide-react";

interface Stats {
  totalUsers: number;
  newUsersThisWeek: number;
  activeMissionsCount: number;
  archivedMissionsCount: number;
  pendingProofsCount: number;
  totalXpEarned: number;
  xpEarnedToday: number;
}

export default function StatCards({ stats }: { stats?: Stats }) {
  if (!stats) return null;

  return (
    <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
      {/* Company Members */}
      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-sm font-medium text-[#8b8b8b] mb-1">
              Company Members
            </p>
            <p className="text-3xl font-bold text-[#1a1a1a]">
              {stats.totalUsers}
            </p>
          </div>
          <div className="text-right">
            <div className="flex items-center gap-1 text-sm font-medium text-emerald-600">
              <TrendingUp className="w-4 h-4" />
              <span>+{stats.newUsersThisWeek}</span>
            </div>
            <p className="text-xs text-[#8b8b8b]">this week</p>
          </div>
        </div>
      </div>

      {/* Managed Missions */}
      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-sm font-medium text-[#8b8b8b] mb-1">
              Active Missions
            </p>
            <p className="text-3xl font-bold text-[#1a1a1a]">
              {stats.activeMissionsCount}
            </p>
          </div>
          <div className="text-right">
            <p className="text-xs text-muted-foreground font-medium bg-secondary px-2 py-1 rounded">
              {stats.archivedMissionsCount} archived
            </p>
          </div>
        </div>
      </div>

      {/* Pending Proofs */}
      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-sm font-medium text-[#8b8b8b] mb-1">
              Pending Proofs
            </p>
            <p className="text-3xl font-bold text-[#1a1a1a]">
              {stats.pendingProofsCount}
            </p>
          </div>
          <div className="text-right">
            {stats.pendingProofsCount > 0 && (
              <div className="px-2.5 py-1 bg-amber-500 text-white text-xs font-semibold rounded animate-pulse">
                Needs Review
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Company XP */}
      <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-sm font-medium text-[#8b8b8b] mb-1">
              Company XP Earned
            </p>
            <p className="text-3xl font-bold text-[#1a1a1a]">
              {stats.totalXpEarned.toFixed(1)}k
            </p>
          </div>
          <div className="text-right">
            <div className="flex items-center gap-1 text-sm font-medium text-emerald-600">
              <TrendingUp className="w-4 h-4" />
              <span>+{stats.xpEarnedToday.toFixed(2)}k</span>
            </div>
            <p className="text-xs text-[#8b8b8b]">today</p>
          </div>
        </div>
      </div>
    </div>
  );
}
