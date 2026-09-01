export interface ProofReview {
  id: string;
  approved: boolean | null;
  feedback: string | null;
  reviewed_at: string;
  reviewer?: { username: string } | null;
}

export interface ProofTask {
  id: string;
  user_id: string;
  title: string;
  desc: string | null;
  points: number;
  proof_notes: string | null;
  proof_image: string | null;
  created_at: string;
  done: boolean;
  profiles: {
    username: string;
    avatar_url: string | null;
  } | null;
  proof_reviews: ProofReview[];
}

export const getInitials = (name?: string) => {
  if (!name) return "U";
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
};

export const getTimeAgo = (dateString: string) => {
  const diff = Math.floor(
    (new Date().getTime() - new Date(dateString).getTime()) / 1000,
  );
  if (diff < 60) return "Just now";
  if (diff < 3600) return `${Math.floor(diff / 60)} min ago`;
  if (diff < 86400) return `${Math.floor(diff / 3600)} hours ago`;
  if (diff < 172800) return "Yesterday";
  return `${Math.floor(diff / 86400)} days ago`;
};
