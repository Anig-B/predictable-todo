# Predictable Todo — Database Schema & Migration Plan

## Overview

**Database:** Supabase (PostgreSQL)  
**Clients:** Flutter app (existing) + Admin web app (new) share the same database  
**Auth:** Supabase Auth (email/password)

---

## Current Tables

### 1. `profiles`
User display/profile information. Auto-created on signup via trigger.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid PK` | References `auth.users(id) ON DELETE CASCADE` |
| `username` | `text NOT NULL` | Default: `'Quest Master'` |
| `avatar_url` | `text` | Nullable |
| `short_id` | `text` | Short friend code (e.g. "A3F8K") |
| `tagline` | `text` | User's motto |
| `project` | `text` | Current active project |
| `created_at` | `timestamptz` | Default: `now()` |
| `updated_at` | `timestamptz` | Nullable |

**RLS:** SELECT — public; UPDATE/INSERT — own profile only.  
**Trigger:** `on_auth_user_created` auto-inserts row on signup.

---

### 2. `tasks`
Core todo items with gamification and proof fields.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `text PK` | UUID-like string |
| `user_id` | `uuid` | References `auth.users NOT NULL` |
| `title` | `text` | Task name |
| `desc` | `text` | Description |
| `time` | `text` | e.g. "9am", "15m", "1h" |
| `points` | `int` | XP value |
| `project` | `text` | Project grouping |
| `streak` | `int` | Personal streak count |
| `done` | `bool` | Completion status |
| `priority` | `int` | 0=high, 1=medium, 2=low |
| `category` | `int` | 0=work, 1=health, 2=learning, 3=personal |
| `bonusEarned` | `int` | Default: 0 |
| `recurring` | `int` | 0=none, 1=daily, 2=weekly, 3=monthly |
| `lastCompletedAt` | `text` | ISO date |
| `weeklyDay` | `int` | 1=Mon .. 7=Sun |
| `monthlyDay` | `int` | 1-28 or 0=last day |
| `proof_notes` | `text` | Text proof when completing |
| `proof_image` | `text` | URL to uploaded proof |
| `proof_rating` | `int` | Default: 0 (0-5) |
| `created_at` | `timestamptz` | |

**Trigger:** `handle_task_completion()` — on UPDATE of `done`, calculates XP/combo/boss and logs to `activity_logs`.  
**RLS:** User can CRUD only their own tasks (`user_id = auth.uid()`).

---

### 3. `user_stats`
Gamification state — one row per user.

| Column | Type | Notes |
|--------|------|-------|
| `user_id` | `uuid PK` | References `auth.users` |
| `xp` | `int` | Default: 0 |
| `level` | `int` | Default: 1 |
| `current_streak` | `int` | Default: 0 |
| `weekly_xp` | `int` | Default: 0 |
| `total_lifetime_tasks` | `int` | Default: 0 |
| `combo_count` | `int` | Default: 0 |
| `combo_points` | `int` | Default: 0 |
| `combo_multi` | `numeric` | Default: 1.0 |
| `bonus_xp` | `int` | Default: 0 |
| `multiplier` | `int` | From spin wheel |
| `shields` | `int` | Default: 1 |
| `loot_count` | `int` | Default: 0 |
| `spin_used` | `bool` | Default: false |
| `last_spun_date` | `timestamptz` | Nullable |
| `last_active_at` | `timestamptz` | Nullable |
| `updated_at` | `timestamptz` | |
| `boss_id` | `text` | Nullable |
| `boss_hp` | `int` | Default: 0 |
| `boss_tasks_done` | `int` | Default: 0 |
| `last_boss_reset_at` | `timestamptz` | Nullable |
| `last_boss_id` | `text` | Nullable |
| `boss_reward_claimed` | `bool` | Default: false |
| `unlocked_badges` | `text[]` | Default: `'{}'` |
| `selected_badges` | `text[]` | Default: `'{}'` |
| `unlocked_skills` | `text[]` | Default: `'{}'` |
| `skill_points` | `int` | Default: 0 |
| `daily_quest_reward_claimed` | `bool` | Default: false |
| `daily_quests` | `jsonb` | Default: `'[]'` |
| `quests_last_reset_at` | `timestamptz` | Nullable |
| `night_owl_count` | `int` | |

**RLS:** SELECT/INSERT/UPDATE — own row only.

---

### 4. `activity_logs`
Audit trail of completed tasks.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `bigint PK` | Generated always as identity |
| `user_id` | `uuid` | References `auth.users NOT NULL` |
| `task_id` | `text` | References `tasks.id` (logical FK) |
| `task` | `text` | Task title at completion |
| `project` | `text` | Default: `'General'` |
| `points` | `int` | Default: 0 |
| `time` | `text` | Default: `''` |
| `icon` | `text` | Default: `'📝'` |
| `rating` | `int` | Default: 0 |
| `notes` | `text` | Nullable |
| `image_url` | `text` | Nullable |
| `created_at` | `timestamptz` | Default: `now()` |

**RLS:** SELECT/INSERT/DELETE — own rows only.

---

### 5. `notes`
Free-form text notes.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `text PK` | UUID-like string |
| `user_id` | `uuid` | References `auth.users NOT NULL` |
| `content` | `text NOT NULL` | |
| `created_at` | `timestamptz` | Default: `now()` |

**RLS:** Full CRUD — own notes only.

---

### 6. `notifications`
In-app notifications.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid PK` | Default: `gen_random_uuid()` |
| `user_id` | `uuid` | References `profiles(id) ON DELETE CASCADE` |
| `type` | `text` | Default: `'system'` |
| `title` | `text` | Default: `''` |
| `message` | `text` | Nullable |
| `is_read` | `bool` | Default: false |
| `metadata` | `jsonb` | Default: `'{}'` |
| `created_at` | `timestamptz` | Default: `now()` |

**RLS:** Full CRUD — own notifications only.

---

### 7. `friends`
Bidirectional friendships.

| Column | Type | Notes |
|--------|------|-------|
| `uid_1` | `uuid` | References `profiles(id) ON DELETE CASCADE` |
| `uid_2` | `uuid` | References `profiles(id) ON DELETE CASCADE` |
| `created_at` | `timestamptz` | Default: `now()` |
| PK | `(uid_1, uid_2)` | |

**RLS:** SELECT — if user is in either column; INSERT — only as `uid_1`; DELETE — if user is in either column.

---

### 8. `social_challenges`
Peer-to-peer challenge duels.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid PK` | Default: `gen_random_uuid()` |
| `challenger_id` | `uuid` | References `profiles(id) ON DELETE CASCADE` |
| `challenged_id` | `uuid` | References `profiles(id) ON DELETE CASCADE` |
| `status` | `text` | Default: `'pending'` CHECK IN (pending, accepted, rejected, completed) |
| `reward` | `int` | Default: 0 |
| `created_at` | `timestamptz` | Default: `now()` |

**RLS:** SELECT/UPDATE — if user is challenger or challenged; INSERT — only as challenger.  
**Trigger:** `notify_challenge_sent()` — auto-creates notification on INSERT.

---

### 9. `leaderboard_view` (View)
Joins `profiles` and `user_stats` for rankings. Includes: user_id, username, short_id, avatar_url, project, xp, weekly_xp, level, current_streak, selected_badges, total_lifetime_tasks.

---

## Changes to Make

### Modified Tables

#### `profiles` — Add column

```sql
ALTER TABLE profiles ADD COLUMN role TEXT NOT NULL DEFAULT 'user'
  CHECK (role IN ('user', 'admin'));
```

| New Column | Type | Notes |
|------------|------|-------|
| `role` | `text` | `'user'` (default) or `'admin'` |

#### `tasks` — Add column

```sql
ALTER TABLE tasks ADD COLUMN mission_id TEXT;
```

| New Column | Type | Notes |
|------------|------|-------|
| `mission_id` | `text` nullable | NULL = personal todo. Non-NULL = quest from that mission |

- A task with `mission_id = NULL` = a normal user's personal todo
- A task with `mission_id = 'abc'` = a quest assigned from mission 'abc'
- When admin creates a quest and assigns to 5 people → 5 task rows, same `mission_id`, different `user_id`s
- Each user has their own `done`, `proof_notes`, `proof_image`, `proof_rating` — already built in

#### `activity_logs` — Add column

```sql
ALTER TABLE activity_logs ADD COLUMN quest_id TEXT;
```

| New Column | Type | Notes |
|------------|------|-------|
| `quest_id` | `text` nullable | Links to quest task ID if from a mission |

---

### New Tables

#### `missions`
Created by admins. A mission = a project that users can be invited to.

```sql
CREATE TABLE missions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  description TEXT,
  icon        TEXT,
  color       TEXT,
  created_by  UUID REFERENCES profiles(id),
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);
```

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid PK` | |
| `name` | `text NOT NULL` | Mission/project name |
| `description` | `text` | |
| `icon` | `text` | Emoji |
| `color` | `text` | Hex color |
| `created_by` | `uuid` | References `profiles(id)` |
| `is_active` | `bool` | Default: true (set false to archive) |
| `created_at` | `timestamptz` | |
| `updated_at` | `timestamptz` | |

**RLS:**
- SELECT — mission members + admins
- INSERT — admin only
- UPDATE — admin only
- DELETE — admin only

#### `mission_members`
Who is in which mission, with granular permissions.

```sql
CREATE TABLE mission_members (
  mission_id        UUID REFERENCES missions(id) ON DELETE CASCADE,
  user_id           UUID REFERENCES profiles(id) ON DELETE CASCADE,
  can_add_quests    BOOLEAN DEFAULT false,
  can_edit_quests   BOOLEAN DEFAULT false,
  can_delete_quests BOOLEAN DEFAULT false,
  can_view_stats    BOOLEAN DEFAULT false,
  can_review_proofs BOOLEAN DEFAULT false,
  invited_by        UUID REFERENCES profiles(id),
  joined_at         TIMESTAMPTZ,
  PRIMARY KEY (mission_id, user_id)
);
```

| Column | Type | Notes |
|--------|------|-------|
| `mission_id` | `uuid` | References `missions(id)` |
| `user_id` | `uuid` | References `profiles(id)` |
| `can_add_quests` | `bool` | Default: false |
| `can_edit_quests` | `bool` | Default: false |
| `can_delete_quests` | `bool` | Default: false |
| `can_view_stats` | `bool` | Default: false |
| `can_review_proofs` | `bool` | Default: false |
| `invited_by` | `uuid` | References `profiles(id)` |
| `joined_at` | `timestamptz` | NULL = invite pending |
| PK | `(mission_id, user_id)` | |

**RLS:**
- SELECT — if user is in `user_id` or is admin
- INSERT — admin or user with invite permission
- UPDATE/DELETE — admin only

#### `proof_reviews`
Admin review of proof submissions for quest completions.

```sql
CREATE TABLE proof_reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id     TEXT REFERENCES tasks(id),
  reviewed_by UUID REFERENCES profiles(id),
  approved    BOOLEAN,
  feedback    TEXT,
  reviewed_at TIMESTAMPTZ DEFAULT now()
);
```

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid PK` | |
| `task_id` | `text` | References `tasks(id)` |
| `reviewed_by` | `uuid` | References `profiles(id)` |
| `approved` | `bool` | |
| `feedback` | `text` | Admin notes |
| `reviewed_at` | `timestamptz` | |

**RLS:**
- SELECT — task owner + admins + users with `can_review_proofs`
- INSERT/UPDATE — admin or user with `can_review_proofs`

---

## Relationship Diagram

```
auth.users
  │
  ├── 1:1 ──> profiles (id)
  ├── 1:1 ──> user_stats (user_id)
  ├── 1:N ──> tasks (user_id)
  ├── 1:N ──> activity_logs (user_id)
  ├── 1:N ──> notes (user_id)
  └── 1:N ──> notifications (user_id)

profiles
  ├── 1:N ──> missions (created_by)
  ├── 1:N ──> mission_members (user_id / invited_by)
  ├── 1:N ──> proof_reviews (reviewed_by)
  ├── 1:N ──> friends (uid_1 / uid_2)
  └── 1:N ──> social_challenges (challenger_id / challenged_id)

missions
  └── 1:N ──> mission_members (mission_id)

tasks
  ├── N:1 ──> missions (mission_id, logical FK)
  ├── 1:N ──> activity_logs (logical: task_id)
  └── 1:N ──> proof_reviews (task_id)
```

---

## User Flow

### Normal User
- Uses the app exactly as before
- Personal tasks, XP, levels, streaks, combos, boss battles, spin wheel, loot boxes, badges, friends, challenges
- **No proof system** — tasks complete on tap
- Never sees missions, quests, or admin features

### Project User (invited)
- Sees assigned missions in a new "Missions" section
- Views quests for each mission
- Completing a quest requires **proof** (notes/image)
- Admin reviews proof before quest is fully approved
- May get extra permissions (add/edit quests, view stats, review proofs)

### Admin
- Creates missions
- Invites users to missions
- Sets member permissions
- Creates/edits/deletes quests (which become tasks assigned to members)
- Reviews proof submissions
- Views stats of all users in the mission

---

## What Stays Unchanged

- `user_stats` table — unchanged
- `notes` table — unchanged
- `notifications` table — unchanged
- `friends` table — unchanged
- `social_challenges` table — unchanged
- `leaderboard_view` — unchanged
- All existing triggers (`handle_new_user`, `handle_task_completion`, `notify_challenge_sent`)
- All existing gamification features in Flutter
- Supabase Storage bucket `task-proofs`

---

## Migration Order

1. Add `role` to `profiles`
2. Add `mission_id` to `tasks`
3. Add `quest_id` to `activity_logs`
4. Create `missions` table + RLS policies
5. Create `mission_members` table + RLS policies
6. Create `proof_reviews` table + RLS policies
7. Manually set `UPDATE profiles SET role = 'admin' WHERE id = '<admin-uuid>'`
8. Update existing task completion trigger to handle quest-aware logging (optional)
