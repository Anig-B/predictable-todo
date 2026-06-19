# QuestLog — Product Vision

## Overview

QuestLog is a **gamified todo app published on the Play Store** for anyone to download and use for free. The **B2B SaaS layer is invisible** until a user is invited by a paying manager — only then do they become part of a paid tier.

---

## Deployment Model

- **One Flutter app** on the Play Store — free for everyone
- **Web app** (paid subscription) — only for managers/employers
- The Flutter app behaves identically for all users by default
- Paid features unlock per-user only when their manager's subscription is active


## Mission Flow

1. Manager signs up on the web app and subscribes
2. Manager creates a **Mission** (name, description, tasks/quests)
3. Manager **searches for users** by email/username and sends an invite
4. Invited user receives a notification in the Flutter app
5. User accepts → mission tasks appear in their todo list alongside their own tasks
6. Manager's dashboard shows live progress for each member
7. If the manager's subscription lapses, employees lose gated features (proof system)

---

## User Types

| Role | Description | Pays? |
|------|-------------|-------|
| **Manager** | Creates missions, invites employees, views dashboard | **Yes** (subscription) |
| **Employee** | Invited into a mission by their manager | Free (perks tied to manager's sub) |
| **Free user** | Uses the app independently, never invited | Always free |

---

## Feature Tiers

| Feature | Free User | Paid Manager's Employee |
|---------|-----------|------------------------|
| Tasks (CRUD) | ✅ | ✅ |
| XP, levels, bosses, quests | ✅ | ✅ |
| Companion, loot, spin wheel | ✅ | ✅ |
| Badges, rank tiers | ✅ | ✅ |
| Leaderboard, stats | ✅ | ✅ |
| **Proof system** (photo, ratings, bonus XP) | ❌ | ✅ |

Proof system is gated to cover **Supabase Storage costs** (bandwidth + storage). Employees of paying managers get it; free users and employees of lapsed subscriptions do not.

---

## Current Issues in Flutter App

| Issue | Status | Notes |
|-------|--------|-------|
| **Push notifications** | ❌ Not implemented | `NotificationService` is an empty stub. Reminders for scheduled tasks exist in-app but no push delivery. Must be built before Play Store launch. |
| **Streak shield logic** | ⚠️ Partial | Shield count stored in DB but no "auto-use shield when streak would break" logic. |



