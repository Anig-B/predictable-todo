import Link from "next/link";
import { ExternalLink } from "lucide-react";

interface ProofItem {
  taskId: string;
  questTitle: string;
  missionId: string;
  missionName: string;
  userName: string;
  done?: boolean; // Optional property if passed from backend
}

const getInitials = (name: string) =>
  name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase();

export default function ProofQueue({ proofs }: { proofs: ProofItem[] }) {
  // Client-side safety filter: remove any items explicitly marked done
  const pendingProofs = proofs.filter((p) => !p.done);

  return (
    <div className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6 shadow-sm">
      <h2 className="text-lg font-semibold text-[#1a1a1a] mb-6">
        Proof Verification Queue ({pendingProofs.length})
      </h2>
      <div className="space-y-4">
        {pendingProofs.length === 0 ? (
          <p className="text-xs text-muted-foreground">
            No pending proof reviews for your company missions.
          </p>
        ) : (
          pendingProofs.map((proof) => (
            <div
              key={proof.taskId}
              className="flex items-center justify-between pb-4 border-b border-[#e8e3db] last:border-0 last:pb-0 hover:bg-[#f3f0ea]/50 p-2 rounded transition-colors"
            >
              <div className="flex items-center gap-3 flex-1 min-w-0">
                <div className="w-8 h-8 rounded-full bg-amber-500/10 text-amber-600 font-bold text-xs flex items-center justify-center shrink-0">
                  {getInitials(proof.userName)}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold text-[#1a1a1a] truncate">
                    {proof.questTitle}
                  </p>
                  <p className="text-xs text-muted-foreground truncate">
                    {proof.missionName} • By {proof.userName}
                  </p>
                </div>
              </div>

              <Link
                href={`/missions/${proof.missionId}?taskId=${proof.taskId}`}
                className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold bg-indigo-50 text-indigo-700 border border-indigo-200 hover:bg-indigo-100 rounded transition-colors shrink-0"
              >
                <span>Review Proof</span>
                <ExternalLink className="w-3.5 h-3.5" />
              </Link>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
