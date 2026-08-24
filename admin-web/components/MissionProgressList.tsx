interface MissionProgress {
  id: string;
  name: string;
  questsDone: number;
  questsTotal: number;
  memberCount: number;
}

export default function MissionProgressList({
  activeMissions,
}: {
  activeMissions: MissionProgress[];
}) {
  return (
    <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
      <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
        Company Mission Progress
      </h2>
      <div className="space-y-5">
        {activeMissions.length === 0 ? (
          <p className="text-xs text-muted-foreground">
            No active company missions.
          </p>
        ) : (
          activeMissions.map((mission) => {
            const done = Number(mission.questsDone) || 0;
            const total = Number(mission.questsTotal) || 1;
            const percent = Math.min(100, (done / total) * 100);

            return (
              <div key={mission.id} className="space-y-2">
                <div className="flex items-center justify-between">
                  <p className="text-sm font-semibold text-[#1a1a1a] truncate max-w-40">
                    {mission.name}
                  </p>
                  <span className="text-xs text-muted-foreground font-medium">
                    {done}/{total} Done
                  </span>
                </div>

                <div className="w-full bg-[#e8e3db] rounded-full h-2">
                  <div
                    className="h-2 rounded-full bg-indigo-600 transition-all duration-300"
                    style={{ width: `${percent}%` }}
                  />
                </div>
                <p className="text-xs text-[#8b8b8b]">
                  {mission.memberCount} assigned members
                </p>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
