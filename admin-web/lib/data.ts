// Dummy data for the admin panel

export type User = {
  id: string;
  shortId: string;
  name: string;
  email: string;
  role: "admin" | "user";
  joinedDate: string;
  xp: number;
  level: number;
  streak: number;
  weeklyXp: number;
  avatar: string;
};

export type Mission = {
  id: string;
  name: string;
  description: string;
  questsDone: number;
  questsTotal: number;
  memberCount: number;
  active: boolean;
  color: string;
};

export type Quest = {
  id: string;
  missionId: string;
  title: string;
  description: string;
  assignedTo: string;
  points: number;
  priority: "High" | "Medium" | "Low";
  category: "Work" | "Health" | "Learning" | "Personal";
  status: "Done" | "Pending";
  proofStatus: "Approved" | "Pending review" | null;
  estimateTime?: string;
};

export type ProofSubmission = {
  id: string;
  userId: string;
  missionId: string;
  questId: string;
  userName: string;
  missionName: string;
  questTitle: string;
  notes: string;
  rating: number;
  status: "pending" | "approved" | "rejected";
  feedbackText?: string;
};

export type ActivityItem = {
  id: string;
  userId: string;
  userName: string;
  action: string;
  missionName?: string;
  points?: number;
  timestamp: string;
};

export const users: User[] = [
  {
    id: "1",
    shortId: "A3F8K",
    name: "Alice",
    email: "alice@email.com",
    role: "admin",
    joinedDate: "Jan 12 2026",
    xp: 4200,
    level: 8,
    streak: 12,
    weeklyXp: 840,
    avatar: "Alice",
  },
  {
    id: "2",
    shortId: "B7X2P",
    name: "Bob",
    email: "bob@email.com",
    role: "user",
    joinedDate: "Feb 3 2026",
    xp: 2800,
    level: 6,
    streak: 8,
    weeklyXp: 620,
    avatar: "Bob",
  },
  {
    id: "3",
    shortId: "C9R4M",
    name: "Carol",
    email: "carol@email.com",
    role: "user",
    joinedDate: "Mar 7 2026",
    xp: 1950,
    level: 5,
    streak: 5,
    weeklyXp: 410,
    avatar: "Carol",
  },
  {
    id: "4",
    shortId: "D2K8L",
    name: "David",
    email: "david@email.com",
    role: "user",
    joinedDate: "Apr 15 2026",
    xp: 1100,
    level: 4,
    streak: 3,
    weeklyXp: 280,
    avatar: "David",
  },
  {
    id: "5",
    shortId: "E5N1Q",
    name: "Eve",
    email: "eve@email.com",
    role: "user",
    joinedDate: "May 20 2026",
    xp: 850,
    level: 3,
    streak: 2,
    weeklyXp: 120,
    avatar: "Eve",
  },
];

export const missions: Mission[] = [
  {
    id: "1",
    name: "Website Redesign",
    description: "Redesign the main marketing site",
    questsDone: 5,
    questsTotal: 8,
    memberCount: 3,
    active: true,
    color: "#3b82f6",
  },
  {
    id: "2",
    name: "Marketing Q3",
    description: "Q3 content and social media push",
    questsDone: 2,
    questsTotal: 5,
    memberCount: 2,
    active: true,
    color: "#14b8a6",
  },
  {
    id: "3",
    name: "Onboarding",
    description: "New hire onboarding tasks",
    questsDone: 1,
    questsTotal: 3,
    memberCount: 1,
    active: true,
    color: "#a855f7",
  },
  {
    id: "4",
    name: "Product Launch",
    description: "v2.0 launch preparation",
    questsDone: 8,
    questsTotal: 10,
    memberCount: 4,
    active: true,
    color: "#f97316",
  },
  {
    id: "5",
    name: "Brand Refresh",
    description: "Logo and brand identity update",
    questsDone: 6,
    questsTotal: 6,
    memberCount: 2,
    active: false,
    color: "#6366f1",
  },
  {
    id: "6",
    name: "Q2 Review",
    description: "Quarterly review tasks",
    questsDone: 4,
    questsTotal: 4,
    memberCount: 3,
    active: false,
    color: "#ec4899",
  },
];

export const quests: Quest[] = [
  {
    id: "1",
    missionId: "1",
    title: "Write homepage copy",
    description: "Write compelling copy for the homepage",
    assignedTo: "1",
    points: 50,
    priority: "High",
    category: "Work",
    status: "Done",
    proofStatus: "Approved",
  },
  {
    id: "2",
    missionId: "1",
    title: "Design hero section",
    description: "Create hero section design",
    assignedTo: "2",
    points: 80,
    priority: "High",
    category: "Work",
    status: "Done",
    proofStatus: "Pending review",
  },
  {
    id: "3",
    missionId: "1",
    title: "QA testing",
    description: "Test the redesigned pages",
    assignedTo: "3",
    points: 30,
    priority: "Medium",
    category: "Work",
    status: "Pending",
    proofStatus: null,
  },
  {
    id: "4",
    missionId: "1",
    title: "Write meta descriptions",
    description: "Write SEO meta descriptions",
    assignedTo: "1",
    points: 20,
    priority: "Low",
    category: "Work",
    status: "Pending",
    proofStatus: null,
  },
  {
    id: "5",
    missionId: "1",
    title: "Set up analytics",
    description: "Configure analytics tracking",
    assignedTo: "2",
    points: 40,
    priority: "Medium",
    category: "Work",
    status: "Pending",
    proofStatus: null,
  },
];

export const proofSubmissions: ProofSubmission[] = [
  {
    id: "1",
    userId: "2",
    missionId: "1",
    questId: "2",
    userName: "Bob",
    missionName: "Website Redesign",
    questTitle: "Design hero section",
    notes:
      "Completed the Figma mockup for all breakpoints, attached screenshots",
    rating: 4,
    status: "pending",
  },
  {
    id: "2",
    userId: "3",
    missionId: "2",
    questId: "q-blog",
    userName: "Carol",
    missionName: "Marketing Q3",
    questTitle: "Write blog post",
    notes:
      "Draft is ready at the Google Doc link, covered all topics from the brief",
    rating: 3,
    status: "pending",
  },
  {
    id: "3",
    userId: "5",
    missionId: "3",
    questId: "q-handbook",
    userName: "Eve",
    missionName: "Onboarding",
    questTitle: "Read handbook",
    notes: "Read all 42 pages, took notes on the key policies section",
    rating: 5,
    status: "pending",
  },
  {
    id: "4",
    userId: "1",
    missionId: "1",
    questId: "1",
    userName: "Alice",
    missionName: "Website Redesign",
    questTitle: "Write homepage copy",
    notes: "Completed the copy revision rounds",
    rating: 5,
    status: "approved",
    feedbackText: "Great work! Perfect tone and messaging.",
  },
  {
    id: "5",
    userId: "2",
    missionId: "2",
    questId: "q-social",
    userName: "Bob",
    missionName: "Marketing Q3",
    questTitle: "Social media campaign",
    notes: "Campaign scheduled and ready to launch",
    rating: 4,
    status: "rejected",
    feedbackText: "Need to adjust the target audience. Let&apos;s discuss.",
  },
];

export const activities: ActivityItem[] = [
  {
    id: "1",
    userId: "1",
    userName: "Alice",
    action: "completed Write homepage copy",
    points: 50,
    missionName: "Website Redesign",
    timestamp: "2 hours ago",
  },
  {
    id: "2",
    userId: "2",
    userName: "Bob",
    action: "submitted proof for Design hero section",
    missionName: "Website Redesign",
    timestamp: "5 hours ago",
  },
  {
    id: "3",
    userId: "3",
    userName: "Carol",
    action: "joined Marketing Q3 mission",
    missionName: "Marketing Q3",
    timestamp: "1 day ago",
  },
  {
    id: "4",
    userId: "4",
    userName: "David",
    action: "completed Run social ads",
    points: 30,
    missionName: "Marketing Q3",
    timestamp: "2 days ago",
  },
  {
    id: "5",
    userId: "1",
    userName: "Alice",
    action: "reached Level 9",
    timestamp: "3 days ago",
  },
];

export function getAvatarColor(name: string): string {
  const colors: { [key: string]: string } = {
    Alice: "bg-gradient-to-br from-[#14b8a6] to-[#06b6d4]",
    Bob: "bg-gradient-to-br from-[#8b5cf6] to-[#6366f1]",
    Carol: "bg-gradient-to-br from-[#f59e0b] to-[#f97316]",
    David: "bg-gradient-to-br from-[#f43f5e] to-[#fb7185]",
    Eve: "bg-gradient-to-br from-[#ec4899] to-[#f43f5e]",
    Admin: "bg-gradient-to-br from-[#14b8a6] to-[#06b6d4]",
  };
  return colors[name] || "bg-gray-400";
}
