"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Clock, ChevronDown, ChevronUp } from "lucide-react";
import { ExpandedReviewPanel } from "./ExpandedReviewPanel";
import { ProofTask, getInitials, getTimeAgo } from "@/actions/proofs";

interface ProofCardProps {
  task: ProofTask;
  submitting: boolean;
  onReview: (
    task: ProofTask,
    approved: boolean,
    feedback: string,
  ) => Promise<void>;
}

export function ProofCard({ task, submitting, onReview }: ProofCardProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <div className="rounded-2xl border border-border/50 bg-card overflow-hidden transition-all shadow-sm">
      <div className="p-5 space-y-3">
        <div className="flex items-start justify-between gap-4">
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
              <div className="flex items-center gap-2 flex-wrap">
                <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-muted text-foreground border border-border/40">
                  {task.points} XP
                </span>
                <span className="text-xs font-medium px-2.5 py-0.5 rounded-full bg-amber-500/10 text-amber-500 border border-amber-500/20 flex items-center gap-1">
                  <Clock className="w-3 h-3" /> Awaiting review
                </span>
              </div>
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
                  • {getTimeAgo(task.created_at)}
                </span>
              </div>
            </div>
          </div>

          <Button
            variant="secondary"
            size="sm"
            onClick={() => setIsExpanded(!isExpanded)}
            className="rounded-xl px-3 text-xs font-medium bg-secondary text-secondary-foreground hover:bg-secondary/80 flex items-center gap-1"
          >
            Review submission
            {isExpanded ? (
              <ChevronUp className="w-3.5 h-3.5" />
            ) : (
              <ChevronDown className="w-3.5 h-3.5" />
            )}
          </Button>
        </div>
      </div>

      {isExpanded && (
        <ExpandedReviewPanel
          task={task}
          submitting={submitting}
          onClose={() => setIsExpanded(false)}
          onReview={onReview}
        />
      )}
    </div>
  );
}
