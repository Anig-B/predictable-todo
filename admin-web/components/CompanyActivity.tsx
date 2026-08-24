interface ActivityItem {
  id: string;
  userName: string;
  action: string;
  points?: number;
  missionName?: string;
  timestamp: string;
}

const getInitials = (name: string) =>
  name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase();

export default function CompanyActivity({
  activities,
}: {
  activities: ActivityItem[];
}) {
  return (
    <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
      <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
        Company Activity
      </h2>
      <div className="space-y-4">
        {activities.length === 0 ? (
          <p className="text-xs text-muted-foreground">
            No activity from company members yet.
          </p>
        ) : (
          activities.map((activity) => (
            <div
              key={activity.id}
              className="flex items-start gap-4 pb-4 border-b border-[#e8e3db] last:border-0 last:pb-0"
            >
              <div className="w-8 h-8 rounded-full bg-primary/10 text-primary font-bold text-xs flex items-center justify-center shrink-0">
                {getInitials(activity.userName)}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm text-[#1a1a1a]">
                  <span className="font-semibold">{activity.userName}</span>{" "}
                  {activity.action}
                  {activity.points && (
                    <span className="font-semibold text-emerald-600">
                      {" "}
                      +{activity.points} XP
                    </span>
                  )}
                </p>
                <div className="flex items-center gap-2 mt-1">
                  {activity.missionName && (
                    <p className="text-xs text-muted-foreground">
                      {activity.missionName}
                    </p>
                  )}
                  <p className="text-xs text-[#8b8b8b]">{activity.timestamp}</p>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
