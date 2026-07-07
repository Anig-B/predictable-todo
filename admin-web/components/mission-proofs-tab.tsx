"use client";

import { useState } from "react";
import { proofSubmissions } from "@/lib/data";
import { UserAvatar } from "./user-avatar";
import { Star } from "lucide-react";
import { toast } from "sonner";

interface MissionProofsTabProps {
  missionId: string;
}

export function MissionProofsTab({ missionId }: MissionProofsTabProps) {
  const [proofs, setProofs] = useState(
    proofSubmissions.filter((p) => p.missionId === missionId),
  );

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase();
  };

  const handleApprove = (proofId: string) => {
    setProofs((prev) =>
      prev.map((p) =>
        p.id === proofId ? { ...p, status: "approved" as const } : p,
      ),
    );
    toast.success("Proof approved");
  };

  const handleReject = (proofId: string) => {
    toast.error("Please provide feedback before rejecting");
  };

  const renderStars = (rating: number) => {
    return (
      <div className="flex gap-1">
        {Array.from({ length: 5 }).map((_, i) => (
          <Star
            key={i}
            className={`w-4 h-4 ${
              i < rating ? "fill-[#fbbf24] text-[#fbbf24]" : "text-[#d1d5db]"
            }`}
          />
        ))}
      </div>
    );
  };

  const pendingProofs = proofs.filter((p) => p.status === "pending");
  const reviewedProofs = proofs.filter((p) => p.status !== "pending");

  return (
    <div className="space-y-8">
      {/* Pending Proofs */}
      {pendingProofs.length > 0 && (
        <div>
          <h3 className="text-lg font-semibold text-[#1a1a1a] mb-4">
            Pending ({pendingProofs.length})
          </h3>
          <div className="space-y-3">
            {pendingProofs.map((proof) => (
              <div
                key={proof.id}
                className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6"
              >
                <div className="grid grid-cols-[1fr_auto] gap-6">
                  {/* Left: User info and notes */}
                  <div>
                    <div className="flex items-center gap-3 mb-3">
                      <UserAvatar
                        name={proof.userName}
                        initials={getInitials(proof.userName)}
                        size="sm"
                      />
                      <div>
                        <p className="text-sm font-medium text-[#1a1a1a]">
                          {proof.userName}
                        </p>
                        <p className="text-xs text-[#8b8b8b]">
                          {proof.missionName}
                        </p>
                      </div>
                    </div>
                    <p className="text-sm font-medium text-[#1a1a1a] mb-1">
                      {proof.questTitle}
                    </p>
                    <p className="text-sm text-[#6b6b6b] line-clamp-2 mb-3">
                      {proof.notes}
                    </p>

                    {/* Proof image placeholder */}
                    <div className="w-24 h-24 bg-[#e8e3db] rounded-lg flex items-center justify-center text-[#8b8b8b]">
                      <svg
                        className="w-6 h-6"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                        />
                      </svg>
                    </div>
                  </div>

                  {/* Right: Rating and actions */}
                  <div className="flex flex-col items-end justify-between">
                    <div>{renderStars(proof.rating)}</div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleApprove(proof.id)}
                        className="px-4 py-2 bg-[#d1fae5] text-[#065f46] rounded-lg text-sm font-medium hover:bg-[#a7f3d0] transition-colors"
                      >
                        Approve
                      </button>
                      <button
                        onClick={() => handleReject(proof.id)}
                        className="px-4 py-2 border border-[#fecaca] text-[#991b1b] rounded-lg text-sm font-medium hover:bg-[#fee2e2] transition-colors"
                      >
                        Reject
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Reviewed Proofs */}
      {reviewedProofs.length > 0 && (
        <div>
          <h3 className="text-lg font-semibold text-[#1a1a1a] mb-4">
            Reviewed
          </h3>
          <div className="space-y-3">
            {reviewedProofs.map((proof) => (
              <div
                key={proof.id}
                className="bg-[#fafaf8] border border-[#e8e3db] rounded-lg p-6"
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <UserAvatar
                        name={proof.userName}
                        initials={getInitials(proof.userName)}
                        size="sm"
                      />
                      <div>
                        <p className="text-sm font-medium text-[#1a1a1a]">
                          {proof.userName}
                        </p>
                        <p className="text-xs text-[#8b8b8b]">
                          {proof.missionName} · {proof.questTitle}
                        </p>
                      </div>
                    </div>
                    <div className="mt-2">
                      <span
                        className={`inline-block px-2 py-1 rounded text-xs font-medium ${
                          proof.status === "approved"
                            ? "bg-[#d1fae5] text-[#065f46]"
                            : "bg-[#fee2e2] text-[#991b1b]"
                        }`}
                      >
                        {proof.status === "approved" ? "Approved" : "Rejected"}
                      </span>
                    </div>
                    {proof.feedbackText && (
                      <p className="text-sm text-[#6b6b6b] mt-2">
                        {proof.feedbackText}
                      </p>
                    )}
                  </div>
                  <div className="ml-4">{renderStars(proof.rating)}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
