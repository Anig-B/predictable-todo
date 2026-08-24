interface TopMember {
  id: string;
  name: string;
  level: number;
  streak: number;
  xp: number;
}

const getInitials = (name: string) =>
  name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase();

export default function TopMembersList({
  topMembers,
}: {
  topMembers: TopMember[];
}) {
  return (
    <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
      <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">Top Members</h2>
      <div className="space-y-4">
        {topMembers.length === 0 ? (
          <p className="text-xs text-muted-foreground">
            No company members found.
          </p>
        ) : (
          topMembers.map((user, idx) => (
            <div
              key={user.id}
              className="flex items-center justify-between pb-3 border-b border-[#e8e3db] last:border-0 last:pb-0 text-sm"
            >
              <div className="flex items-center gap-3 min-w-0">
                <span className="font-bold text-muted-foreground w-4">
                  {idx + 1}
                </span>
                <div className="w-8 h-8 rounded-full bg-slate-100 font-bold text-xs flex items-center justify-center shrink-0">
                  {getInitials(user.name)}
                </div>
                <div className="min-w-0">
                  <p className="font-semibold text-[#1a1a1a] truncate">
                    {user.name}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    Lvl {user.level} • {user.streak}d streak
                  </p>
                </div>
              </div>
              <span className="font-bold text-primary shrink-0">
                {user.xp} XP
              </span>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
