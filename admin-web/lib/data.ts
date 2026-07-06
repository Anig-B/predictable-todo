// app/lib/data.ts

export interface UserData {
  id: string;
  name: string;
  level: number;
  streak: number;
  weeklyXp: number;
}

export interface MissionData {
  id: string;
  name: string;
  active: boolean;
  memberCount: number;
  questsTotal: number;
  questsDone: number;
  color: string;
}

export interface ActivityData {
  id: string;
  userName: string;
  action: string;
  points?: number;
  missionName?: string;
  timestamp: string;
}

export interface ProofSubmissionData {
  id: string;
  userName: string;
  questTitle: string;
  missionName: string;
  status: "pending" | "approved" | "rejected";
}

export const users: UserData[] = [
  { id: "1", name: "Alex Mercer", level: 12, streak: 5, weeklyXp: 450 },
  { id: "2", name: "Sarah Connor", level: 9, streak: 14, weeklyXp: 620 },
  { id: "3", name: "Bruce Wayne", level: 24, streak: 3, weeklyXp: 310 },
  { id: "4", name: "Diana Prince", level: 18, streak: 22, weeklyXp: 580 },
];

export const missions: MissionData[] = [
  {
    id: "1",
    name: "Core Flutter Setup",
    active: true,
    memberCount: 12,
    questsTotal: 5,
    questsDone: 4,
    color: "#0284c7",
  },
  {
    id: "2",
    name: "Database Architecture",
    active: true,
    memberCount: 8,
    questsTotal: 4,
    questsDone: 2,
    color: "#16a34a",
  },
  {
    id: "3",
    name: "UI Polishing Sprints",
    active: true,
    memberCount: 15,
    questsTotal: 8,
    questsDone: 3,
    color: "#ea580c",
  },
  {
    id: "4",
    name: "Legacy System Cleanup",
    active: false,
    memberCount: 4,
    questsTotal: 3,
    questsDone: 3,
    color: "#4b5563",
  },
];

export const activities: ActivityData[] = [
  {
    id: "1",
    userName: "Sarah Connor",
    action: 'completed quest "Install SDK Helpers"',
    points: 50,
    missionName: "Core Flutter Setup",
    timestamp: "2 mins ago",
  },
  {
    id: "2",
    userName: "Diana Prince",
    action: 'submitted proof for "Schema Review"',
    missionName: "Database Architecture",
    timestamp: "15 mins ago",
  },
  {
    id: "3",
    userName: "Alex Mercer",
    action: "joined a new operational mission",
    missionName: "UI Polishing Sprints",
    timestamp: "1 hour ago",
  },
];

export const proofSubmissions: ProofSubmissionData[] = [
  {
    id: "1",
    userName: "Diana Prince",
    questTitle: "Schema Review Upload",
    missionName: "Database Architecture",
    status: "pending",
  },
  {
    id: "2",
    userName: "Alex Mercer",
    questTitle: "App Entry Point Integration",
    missionName: "Core Flutter Setup",
    status: "pending",
  },
];
