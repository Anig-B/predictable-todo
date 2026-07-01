# QuestLog — Database Schema & System Workflow

**App:** Gamified Todo App (Flutter + Supabase)  
**Database:** Supabase (PostgreSQL)  
**Auth:** Supabase Auth (email/password)  
**Push:** Firebase Cloud Messaging  

---

## Tables

### 1. `profiles`
User display/profile information. Auto-created on signup via trigger.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | `uuid` | PK, FK → `auth.users(id) ON DELETE CASCADE` | Matches auth user ID |
| `username` | `text` | NOT NULL, DEFAULT `'Quest Master'` | Display name |
| `avatar_url` | `text` | nullable | Emoji or URL avatar |
| `short_id` | `text` | nullable | Short friend code (e.g. "A3F8K") |
| `tagline` | `text` | nullable | User motto/tagline |
| `project` | `text` | nullable | Current active project name |
| `role` | `text` | NOT NULL, DEFAULT `'user'`, CHECK (`'user'`, `'admin'`) | Permission level |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT `now()` | Account creation time |
| `updated_at` | `timestamptz` | nullable | Last profile update |

**RLS:** SELECT public; UPDATE own only; INSERT via trigger.  
**Trigger:** `on_auth_user_created` → `handle_new_user()` inserts row when `auth.users` row is created.

---

### 2. `tasks`
Core todo items with gamification fields, proof system, and optional mission linkage.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | `text` | PK | UUID-like string identifier |
| `user_id` | `uuid` | FK → `auth.users`, NOT NULL | Owner of the task |
| `title` | `text` | | Task name/title |
| `desc` | `text` | | Description |
| `time` | `text` | | Time estimate (e.g. "9am", "15m", "1h") |
| `points` | `int` | | Base XP value for completion |
| `project` | `text` | | Project grouping label |
| `streak` | `int` | | Personal streak count for this specific task |
| `done` | `bool` | | Completion status |
| `priority` | `int` | | 0=high, 1=medium, 2=low |
| `category` | `int` | | 0=work, 1=health, 2=learning, 3=personal |
| `bonusEarned` | `int` | DEFAULT 0 | Bonus XP awarded on completion |
| `recurring` | `int` | DEFAULT 0 | 0=none, 1=daily, 2=weekly, 3=monthly |
| `lastCompletedAt` | `text` | nullable | ISO date string of last completion |
| `weeklyDay` | `int` | nullable | Day of week for weekly recurring (1=Mon..7=Sun) |
| `monthlyDay` | `int` | nullable | Day of month (1-28) or 0=last day |
| `proof_notes` | `text` | nullable | Text proof submitted on completion |
| `proof_image` | `text` | nullable | URL to uploaded proof image |
| `proof_rating` | `int` | DEFAULT 0 | Rating for proof quality (0-5) |
| `mission_id` | `text` | nullable | Links to `missions(id)` — non-null means this is a mission quest |
| `created_at` | `timestamptz` | | Creation timestamp |

**RLS:** Users CRUD own tasks (`user_id = auth.uid()`). Mission quests have additional constraints:
- Delete requires admin or manager role
- Insert with `mission_id` requires admin or manager
- Update policies recreated to work with `trg_prevent_quest_edit` trigger

**Triggers:**
- `handle_task_completion()` — On UPDATE of `done`, calculates XP/combo/boss damage, logs to `activity_logs`
- `prevent_quest_uncomplete()` — Blocks setting `done=false` on mission quests
- `prevent_quest_edit()` — Blocks content edits (title, desc, points, etc.) on mission quests by non-managers
- `require_quest_proof()` — Requires proof (notes or image) when completing a mission quest
- `validate_quest_mission()` — Ensures `mission_id` references an existing mission

---

### 3. `user_stats`
Gamification state — one row per user. Tracks all game mechanics progress.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `user_id` | `uuid` | PK, FK → `auth.users` | One row per user |
| `xp` | `int` | DEFAULT 0 | Total lifetime XP |
| `level` | `int` | DEFAULT 1 | User level (calculated from XP/200) |
| `current_streak` | `int` | DEFAULT 0 | Consecutive days with task completions |
| `weekly_xp` | `int` | DEFAULT 0 | XP earned this week (resets Monday) |
| `total_lifetime_tasks` | `int` | DEFAULT 0 | Total tasks completed ever |
| `combo_count` | `int` | DEFAULT 0 | Consecutive task completions (resets after 24h idle) |
| `combo_points` | `int` | DEFAULT 0 | Accumulated combo XP points |
| `combo_multi` | `numeric` | DEFAULT 1.0 | Current combo multiplier (1x-4x) |
| `bonus_xp` | `int` | DEFAULT 0 | XP from bonuses (multiplier, proof bonuses) |
| `multiplier` | `int` | DEFAULT 1 | Spin wheel XP multiplier |
| `shields` | `int` | DEFAULT 1 | Protection shields from spin wheel |
| `loot_count` | `int` | DEFAULT 0 | Total loot items collected |
| `spin_used` | `bool` | DEFAULT false | Whether daily spin has been used today |
| `last_spun_date` | `timestamptz` | nullable | When last spin occurred |
| `last_active_at` | `timestamptz` | nullable | Last task completion timestamp |
| `updated_at` | `timestamptz` | | Last stats update |
| `boss_id` | `text` | nullable | Current weekly boss identifier |
| `boss_hp` | `int` | DEFAULT 0 | Current boss remaining HP |
| `boss_tasks_done` | `int` | DEFAULT 0 | Tasks contributed to current boss |
| `last_boss_reset_at` | `timestamptz` | nullable | When boss was last reset |
| `last_boss_id` | `text` | nullable | Previous week's boss ID |
| `boss_reward_claimed` | `bool` | DEFAULT false | Whether boss defeat reward was collected |
| `unlocked_badges` | `text[]` | DEFAULT `'{}'` | Array of earned badge names |
| `selected_badges` | `text[]` | DEFAULT `'{}'` | Currently displayed badges (max 3) |
| `unlocked_skills` | `text[]` | DEFAULT `'{}'` | Unlocked skill identifiers |
| `skill_points` | `int` | DEFAULT 0 | Points allocated to skills |
| `daily_quest_reward_claimed` | `bool` | DEFAULT false | Whether daily quest reward was claimed |
| `daily_quests` | `jsonb` | DEFAULT `'[]'` | Serialized array of daily quest objects with progress |
| `quests_last_reset_at` | `timestamptz` | nullable | When daily quests were last rolled |
| `night_owl_count` | `int` | | Tasks completed after 8PM |

**RLS:** SELECT/INSERT/UPDATE own row only.

---

### 4. `activity_logs`
Audit trail of completed tasks. Each completion (and its XP earn) creates one row.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | `bigint` | PK, GENERATED ALWAYS AS IDENTITY | Auto-incrementing ID |
| `user_id` | `uuid` | FK → `auth.users`, NOT NULL | Who completed the task |
| `task_id` | `text` | NOT NULL | Links to `tasks(id)` |
| `task` | `text` | NOT NULL | Snapshot of task title at completion |
| `project` | `text` | NOT NULL, DEFAULT `'General'` | Project category |
| `points` | `int` | NOT NULL, DEFAULT 0 | XP earned (includes combo + proof bonuses) |
| `time` | `text` | NOT NULL, DEFAULT `''` | Time string of completion |
| `icon` | `text` | NOT NULL, DEFAULT `'📝'` | Category emoji icon |
| `rating` | `int` | NOT NULL, DEFAULT 0 | Mood/effort rating (1-5) |
| `notes` | `text` | nullable | Proof notes submitted |
| `image_url` | `text` | nullable | Proof image URL |
| `quest_id` | `text` | nullable | Links to task ID if completion was from a mission quest |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT `now()` | When completed |

**RLS:** SELECT/INSERT/DELETE own rows only.

---

### 5. `notes`
Free-form text notes for personal journaling.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | `text` | PK | UUID-like string |
| `user_id` | `uuid` | FK → `auth.users`, NOT NULL | Owner |
| `content` | `text` | NOT NULL | Note text content |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT `now()` | Creation timestamp |

**RLS:** Full CRUD own notes only.

---

### 6. `notifications`
In-app notifications for challenges, mission invites, and system messages. Supports push tracking.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | `uuid` | PK, DEFAULT `gen_random_uuid()` | Auto-generated UUID |
| `user_id` | `uuid` | NOT NULL, FK → `profiles(id) ON DELETE CASCADE` | Notification recipient |
| `type` | `text` | NOT NULL, DEFAULT `'system'` | Category: `system`, `challenge_received`, `mission_invite` |
| `title` | `text` | NOT NULL, DEFAULT `''` | Notification title |
| `message` | `text` | nullable | Body text |
| `is_read` | `bool` | NOT NULL, DEFAULT false | Read/unread status |
| `is_push_sent` | `bool` | NOT NULL, DEFAULT false | Whether FCM push notification was sent |
| `metadata` | `jsonb` | NOT NULL, DEFAULT `'{}'` | Flexible payload (`mission_id`, `challenge_id`, etc.) |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT `now()` | Creation timestamp |

**RLS:** Full CRUD own notifications only.  
**Index:** `idx_notifications_pending_push` — partial index on `created_at` WHERE `is_push_sent = false` (for cron processing).

---

### 7. `device_tokens`
Firebase Cloud Messaging device tokens for push notifications.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `user_id` | `uuid` | NOT NULL, FK → `auth.users(id) ON DELETE CASCADE` | Device owner |
| `fcm_token` | `text` | NOT NULL | Firebase Cloud Messaging token |
| `platform` | `text` | NOT NULL, DEFAULT `'unknown'`, CHECK (`'android'`, `'ios'`, `'unknown'`) | Device OS |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT `now()` | When registered |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT `now()` | Last update |
| **PK** | | | `(user_id, fcm_token)` — one token per user per device |

**RLS:** Users manage own tokens.  
**Index:** `device_tokens_user_id_idx ON (user_id)`  
**RPC:** `upsert_device_token(p_fcm_token, p_platform)` — insert or update token.

---

### 8. `friends`
Bidirectional friendships (one row per pair, no directionality).

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `uid_1` | `uuid` | NOT NULL, FK → `profiles(id) ON DELETE CASCADE` | First friend |
| `uid_2` | `uuid` | NOT NULL, FK → `profiles(id) ON DELETE CASCADE` | Second friend |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT `now()` | When friendship formed |
| **PK** | | | `(uid_1, uid_2)` |

**RLS:** SELECT if user in either column; INSERT only as `uid_1`; DELETE if in either column.

---

### 9. `social_challenges`
Peer-to-peer challenge duels between friends.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | `uuid` | PK, DEFAULT `gen_random_uuid()` | Auto-generated UUID |
| `challenger_id` | `uuid` | NOT NULL, FK → `profiles(id) ON DELETE CASCADE` | User who sent the challenge |
| `challenged_id` | `uuid` | NOT NULL, FK → `profiles(id) ON DELETE CASCADE` | User who received the challenge |
| `status` | `text` | NOT NULL, DEFAULT `'pending'`, CHECK (`'pending'`, `'accepted'`, `'rejected'`, `'completed'`) | Current state |
| `reward` | `int` | NOT NULL, DEFAULT 0 | XP reward on completion |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT `now()` | When sent |

**RLS:** SELECT/UPDATE if user is challenger or challenged; INSERT only as challenger.  
**Trigger:** `notify_challenge_sent()` — auto-creates notification on INSERT.  
**RPC:** `accept_challenge(uuid)` — updates status to 'accepted' + creates bidirectional friendship.

---

### 10. `missions`
Admin-created projects that groups of users can join and complete quests for.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | `uuid` | PK, DEFAULT `gen_random_uuid()` | Auto-generated UUID |
| `name` | `text` | NOT NULL | Mission/project name |
| `description` | `text` | nullable | Mission description |
| `created_by` | `uuid` | nullable, FK → `profiles(id)` | Admin who created it |
| `is_active` | `bool` | DEFAULT true | Whether mission is active (set false to archive) |
| `created_at` | `timestamptz` | DEFAULT `now()` | Creation timestamp |
| `updated_at` | `timestamptz` | DEFAULT `now()` | Last update |

**RLS:** SELECT mission members + admins; INSERT/UPDATE/DELETE admin only.

---

### 11. `mission_members`
Who belongs to which mission, with role-based permissions.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `mission_id` | `uuid` | NOT NULL, FK → `missions(id) ON DELETE CASCADE` | Mission reference |
| `user_id` | `uuid` | NOT NULL, FK → `profiles(id) ON DELETE CASCADE` | Member user |
| `role` | `text` | NOT NULL, DEFAULT `'member'`, CHECK (`'member'`, `'manager'`) | `member` = basic, `manager` = can add/delete quests, review proofs, invite |
| `invited_by` | `uuid` | nullable, FK → `profiles(id)` | Who invited this user |
| `joined_at` | `timestamptz` | nullable | NULL = invite pending; non-NULL = accepted |
| **PK** | | | `(mission_id, user_id)` |

**RLS:** SELECT own records or admin; INSERT admin/manager; UPDATE/DELETE admin/manager (users can update own to leave).  
**Trigger:** `notify_mission_invite()` — auto-creates notification on INSERT when `joined_at IS NULL`.  
**RPC:** `accept_mission_invite(uuid, uuid)` — sets `joined_at = now()`.  
**RPC:** `decline_mission_invite(uuid, uuid)` — deletes the row.

---

### 12. `proof_reviews`
Admin/manager review of proof submissions for mission quest completions.

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `id` | `uuid` | PK, DEFAULT `gen_random_uuid()` | Auto-generated UUID |
| `task_id` | `text` | FK → `tasks(id)` | Quest task being reviewed |
| `reviewed_by` | `uuid` | nullable, FK → `profiles(id)` | Admin/manager who reviewed |
| `approved` | `bool` | nullable | Whether proof was accepted (null = pending) |
| `feedback` | `text` | nullable | Reviewer notes/feedback |
| `reviewed_at` | `timestamptz` | DEFAULT `now()` | When reviewed |

**RLS:** SELECT task owner, admin, or manager of that mission; INSERT/UPDATE admin or manager only.

---

### View: `leaderboard_view`
Read-only JOIN of `profiles` + `user_stats` for ranking queries.

| Column | Source | Purpose |
|--------|--------|---------|
| `user_id` | `profiles.id` | User identifier |
| `username` | `profiles.username` | Display name |
| `short_id` | `profiles.short_id` | Friend code |
| `avatar_url` | `profiles.avatar_url` | Avatar |
| `project` | `profiles.project` | Current project |
| `xp` | `user_stats.xp` | Total XP |
| `weekly_xp` | `user_stats.weekly_xp` | Weekly XP |
| `level` | `xp / 200 + 1` | Computed level |
| `current_streak` | `user_stats.current_streak` | Streak |
| `selected_badges` | `user_stats.selected_badges` | Display badges |
| `total_lifetime_tasks` | `user_stats.total_lifetime_tasks` | Total completions |

**Filter:** Excludes rows where `username IS NULL OR username = ''`.  
**Grants:** SELECT to `authenticated` and `anon`.

---

### Storage Bucket: `task-proofs`
Public bucket for proof image uploads.

| Property | Value |
|----------|-------|
| Name | `task-proofs` |
| Public | true |
| Path pattern | `{user_id}/{filename}` |
| Upload policy | User can upload to own folder (`auth.uid()` matches folder name) |
| Read policy | Any authenticated user can view |

---

## Entity Relationships

```
auth.users (Supabase Auth — external)
  │
  ├── 1:1 ──> profiles (id)
  ├── 1:1 ──> user_stats (user_id)
  ├── 1:N ──> tasks (user_id)
  ├── 1:N ──> activity_logs (user_id)
  ├── 1:N ──> notes (user_id)
  ├── 1:N ──> notifications (user_id)
  └── 1:N ──> device_tokens (user_id)

profiles
  ├── 1:N ──> missions (created_by)
  ├── 1:N ──> mission_members (user_id)
  ├── 1:N ──> mission_members (invited_by)
  ├── 1:N ──> proof_reviews (reviewed_by)
  ├── 1:N ──> friends (uid_1)
  ├── 1:N ──> friends (uid_2)
  ├── 1:N ──> social_challenges (challenger_id)
  └── 1:N ──> social_challenges (challenged_id)

missions
  └── 1:N ──> mission_members (mission_id)

tasks
  ├── N:1 ──> missions (mission_id — logical text FK)
  ├── 1:N ──> activity_logs (task_id — logical FK)
  └── 1:N ──> proof_reviews (task_id)

leaderboard_view ──> JOIN of profiles + user_stats (read-only)
```

---

## System Workflow

### A. User Registration & Onboarding

```
User opens app
  → main.dart initializes Firebase, Supabase, NotificationService
  → app_router checks auth state
  → No user → redirect to /auth (AuthPage)
  → User enters email/password
  → AuthRepository.signUpWithEmail() → Supabase Auth
  → Supabase creates user in auth.users
  → TRIGGER: on_auth_user_created fires
    → handle_new_user() inserts row in profiles (id, username)
  → Auto-login → user_stats row created on first gamification sync
  → Redirected to /tasks (home page)
```

### B. Task Creation

```
User taps "+" FAB
  → navigate to /new-quest (AddTaskPage)
  → Fill form: title, desc, priority, category, time, recurring settings
  → Submit → taskProvider.addTask()
    → Creates TaskModel with all fields
    → Optimistic UI update (task appears immediately)
    → TaskRepository.addTask() → supabase.from('tasks').insert(data)
    → Realtime subscription refreshes UI from server
  → If recurring + has time → inserts reminder notification
```

### C. Task Completion (Core Loop)

```
User taps task card on home_page.dart
  → _completeTask() orchestrates 5-step flow:

  STEP 1 — Gamification (client-side via GamificationProvider):
    • Calculate pet bonuses & effective multiplier
    • Update combo count & combo points
    • Calculate boss damage = boss.damagePerTask + companionDmg
    • Reduce boss HP
    • Calculate XP = basePoints + bonus(if multi>1) + companionXp
    • Update streak (consecutive days)
    • Check night owl (tasks after 8PM)
    • Update weekly XP
    • Check badge unlocks (streak milestone, tasks milestone, boss kill, combo milestone)
    • _syncToRemote() → ProfileRepository.updateUserStats() → writes to user_stats

  STEP 2 — Task state (via TaskProvider):
    • Optimistic: mark task done=true, set lastCompletedAt
    • TaskRepository.setTaskCompletionFull() → updates tasks table in Supabase

  STEP 3 — Database trigger fires:
    • handle_task_completion() on tasks BEFORE UPDATE
    • Calculates combo multiplier (1x-4x based on combo_points)
    • Calculates proof bonus (+10 for notes, +15 for image)
    • Updates user_stats: xp, combo_count, combo_points, combo_multi, current_streak
    • Inserts row into activity_logs with quest_id if mission quest

  STEP 4 — Daily Quest progression (via ChallengeProvider):
    • Checks each active daily quest type (earlyBird, tripleThreat, healthHero, consistency, proofProvider, etc.)
    • Progresses matching quests → syncs to user_stats.daily_quests JSON

  STEP 5 — Visual effects:
    • Spawns XP float overlay
    • Shows combo toast at 3x/4x
    • Triggers confetti + toast if boss defeated
    • Shows loot box modal if lootCount % 5 == 0
```

### D. Task Uncompletion (Undo)

```
User taps completed task
  → If mission quest → BLOCKED by DB trigger prevent_quest_uncomplete()
  → If personal task → _confirmUndo() checks recency (24h window) & proof presence
  → uncompleteTask() in TaskProvider:
    • Local: mark done=false, remove activity log entry
    • Backend: TaskRepository.setTaskCompletion(id, false)
      → clears done, lastCompletedAt, proof_notes, proof_image
  → DB trigger handle_task_completion() fires again (true→false branch):
    • Reverses XP (xp = greatest(0, xp - xp_change))
    • Reduces combo_count by 1
    • Reduces combo_points by old task points
    • Recalculates combo_multi
    • Deletes activity_log row for this completion
  → Client GamificationProvider reverses XP, combo, boss HP changes
```

### E. Recurring Task Reset

```
Timer.periodic every 60 seconds in TaskNotifier._resetDueTasks()
  → Check each done recurring task
  → If isDue() returns true based on schedule (daily/weekly/monthly):
    • Reset to done=false
    • Clear lastCompletedAt
    • Schedule next reminder notification
```

### F. Boss System (Weekly)

```
On app start or login → GamificationNotifier._checkWeeklyBossReset()
  → If no active boss OR past Monday → determine new boss:

  Boss Selection Logic:
    • Consistency (weekly active >= 10 + 20% random) → Mystery Genie
    • Overdue tasks > 15 → Chaos Lord
    • Overdue > 5 or low streak → Procrastination Zombie
    • No activity → Lazy Master
    • Default → random from available pool

  Boss Fight Mechanics:
    • boss.damagePerTask = maxHp / tasksNeeded
    • Each task completion reduces boss_hp by damagePerTask
    • When boss_hp <= 0 → BOSS DEFEATED:
      → Confetti + toast celebration
      → Reward unlocked (claimed via claim_boss_reward() RPC)
    • Boss resets every Monday
```

### G. Daily Spin Wheel

```
User taps spin button in header
  → Shows SpinWheelModal
  → User spins → random result:
    • XP bonus: 50 / 100 / 200
    • Multiplier: 2x / 3x
    • Shield: 1 protection
  → applySpinResult() updates:
    • Local GamificationProvider state
    • Syncs to user_stats (multiplier, shields, spin_used, last_spun_date)
  → Limited to 1 spin per day (tracked by last_spun_date)
```

### H. Social Features

```
FRIEND SEARCH:
  → UserSearchModal → search by short_id
  → LeaderboardRepository.searchUsers() → queries profiles

SEND CHALLENGE:
  → LeaderboardRepository.sendChallenge(targetUser)
    → Inserts social_challenges row (status='pending')
    → Trigger notify_challenge_sent() auto-creates notification
    → Sends FCM push via NotificationService.sendPush()

ACCEPT CHALLENGE:
  → NotificationProvider.acceptChallenge(challengeId)
    → Calls RPC accept_challenge(uuid):
      1. Updates social_challenges status → 'accepted'
      2. Inserts row in friends table (bidirectional)
    → Notification dismissed

FRIENDS LIST:
  → Queries leaderboard_view filtered by friend IDs
  → Shows XP, level, streak, badges in ranked list
```

### I. Missions Feature

```
ADMIN CREATES MISSION:
  → Inserts row in missions table
  → Creates quests → inserts tasks rows with mission_id set

ADMIN INVITES USERS:
  → Inserts into mission_members with joined_at=NULL
  → Trigger notify_mission_invite() auto-creates notification

USER ACCEPTS INVITE:
  → Calls RPC accept_mission_invite(mission_id, user_id)
    → Sets joined_at = now()
  → User sees mission quests in "Missions" section

QUEST COMPLETION (stricter than personal tasks):
  → MUST provide proof (notes or image)
    → Enforced by DB trigger require_quest_proof()
  → Cannot undo completion
    → Enforced by DB trigger prevent_quest_uncomplete()
  → Cannot edit quest content (title, desc, points)
    → Enforced by DB trigger prevent_quest_edit()
  → Admin/Manager reviews proof in proof_reviews table
```

### J. Notifications & Push

```
IN-APP NOTIFICATIONS:
  → Stored in notifications table
  → NotificationProvider subscribes to realtime changes
  → Types: system, challenge_received, mission_invite

FCM PUSH (two pathways):
  Client-side:
    → NotificationService.sendPush() → Firebase Admin SDK via OAuth2 JWT
  Server-side (scheduled):
    → pg_cron runs every minute
    → Calls Supabase Edge Function: process-scheduled-notifications
    → EF picks up unsent notifications (is_push_sent=false)
    → Looks up user's device_tokens
    → Sends FCM push via Firebase Admin SDK
    → Marks notification as is_push_sent=true

PUSH REGISTRATION:
  → On login: NotificationService.registerDeviceToken()
    → Calls upsert_device_token() RPC
    → Stores FCM token + platform in device_tokens table
```

### K. Stats & Analytics

```
STATS PAGE aggregates from activity_logs:
  → Category breakdown (donut chart) — work/health/learning/personal
  → Weekly trends (bar chart) — tasks per day for current week
  → Hourly heatmap — productivity by hour of day
  → Project breakdown — tasks grouped by project label
  → Momentum tracking — streak history over time
  → Sparklines — daily completion count trend
  → Gauge — current progress toward daily goal

Data sources:
  → activity_logs — all completed task history
  → user_stats — accumulated totals, streaks, weekly XP
  → tasks — current overdue counts, project distribution
```

---

## Database Triggers Summary

| Trigger | Table | Event | Purpose |
|---------|-------|-------|---------|
| `on_auth_user_created` | `auth.users` | AFTER INSERT | Auto-create `profiles` row on signup |
| `handle_task_completion` | `tasks` | BEFORE UPDATE | Calculate XP/combo/streak/boss, log activity |
| `prevent_quest_uncomplete` | `tasks` | BEFORE UPDATE | Block uncompleting mission quests |
| `prevent_quest_edit` | `tasks` | BEFORE UPDATE | Block content edits by non-managers |
| `require_quest_proof` | `tasks` | BEFORE UPDATE | Require proof for mission quest completion |
| `validate_quest_mission` | `tasks` | BEFORE INSERT OR UPDATE | Validate `mission_id` references real mission |
| `notify_challenge_sent` | `social_challenges` | AFTER INSERT | Auto-create notification on challenge |
| `notify_mission_invite` | `mission_members` | AFTER INSERT | Auto-create notification on invite |

---

## RPC Functions

| Function | Parameters | Purpose |
|----------|-----------|---------|
| `upsert_device_token` | `p_fcm_token text, p_platform text` | Register or update FCM device token |
| `accept_challenge` | `challenge_id uuid` | Accept social challenge, create friendship |
| `claim_boss_reward` | (none — uses `auth.uid()`) | Claim boss defeat reward |
| `accept_mission_invite` | `p_mission_id uuid, p_user_id uuid` | Accept mission membership |
| `decline_mission_invite` | `p_mission_id uuid, p_user_id uuid` | Decline mission membership (deletes row) |

---

## Supabase Edge Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `send-notification` | HTTP POST | Send FCM push to a specific user |
| `process-scheduled-notifications` | `pg_cron` every minute | Process all unsent notifications, send FCM pushes |

---

## Data Flow Pattern (Architecture)

```
User Action
  → Widget
    → Provider (Riverpod StateNotifier)
      → Optimistic UI Update (immediate feedback)
      → Repository
        → Supabase DB (INSERT/UPDATE/DELETE)
          → DB Triggers (auto-calculations)
            → Realtime subscription emits changes
              → Provider updates from stream
                → UI rebuilds
```
