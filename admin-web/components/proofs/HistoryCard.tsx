"use client";

import { Check, X } from "lucide-react";
import {
  ProofTask,
  ProofReview,
  getInitials,
  getTimeAgo,
} from "@/actions/proofs";

interface HistoryCardProps {
  task: ProofTask;
  review: ProofReview;
}

export function HistoryCard({ task, review }: HistoryCardProps) {
  return (
    <div className="p-5 rounded-2xl border border-border/50 bg-card flex items-start justify-between gap-4 transition-all shadow-sm">
      <div className="flex gap-4">
        {task.proof_image && (
          <div className="w-16 h-16 rounded-xl overflow-hidden bg-muted shrink-0 border border-border/40">
            <img
              src={task.proof_image}
              alt={task.title}
              className="w-full h-full object-cover"
            />
          </div>
        )}
        <div className="space-y-1">
          <h3 className="text-base font-semibold text-foreground pt-0.5">
            {task.title}
          </h3>
          {task.desc && (
            <p className="text-xs text-muted-foreground line-clamp-1">
              {task.desc}
            </p>
          )}
          <div className="flex items-center gap-2 pt-1">
            <div className="w-5 h-5 rounded-full bg-muted-foreground/20 text-foreground text-[10px] font-bold flex items-center justify-center">
              {getInitials(task.profiles?.username)}
            </div>
            <span className="text-xs font-medium text-foreground">
              {task.profiles?.username || "Unknown"}
            </span>
            <span className="text-xs text-muted-foreground">
              • {getTimeAgo(review.reviewed_at)}
            </span>
          </div>
          {review.feedback && (
            <p className="text-xs text-muted-foreground italic mt-2 p-2.5 rounded-xl bg-muted/40 border border-border/40">
              "{review.feedback}"
            </p>
          )}
        </div>
      </div>

      {/* Right side status badges */}
      <div className="flex items-center gap-2 shrink-0">
        {review.approved ? (
          <span className="text-xs font-medium px-2.5 py-0.5 rounded-full bg-emerald-500/10 text-emerald-500 border border-emerald-500/20 flex items-center gap-1">
            <Check className="w-3 h-3" /> Approved
          </span>
        ) : (
          <span className="text-xs font-medium px-2.5 py-0.5 rounded-full bg-rose-500/10 text-rose-500 border border-rose-500/20 flex items-center gap-1">
            <X className="w-3 h-3" /> Needs resubmission
          </span>
        )}
      </div>
    </div>
  );
}
