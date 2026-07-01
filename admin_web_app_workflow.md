# Admin Web App — Workflow & Feature Spec

## Overview

A separate web app (not Flutter) that shares the same Supabase DB. Two types of users can log in:

- **System admins** (`profiles.role = 'admin'`) — global access, see & manage all missions
- **Managers** (`mission_members.role = 'manager'`) — scoped to their missions only

Regular `member` users see a 403 page — they manage their quests from the Flutter app.

---

## Roles

### System-level (`profiles.role`)
| Role | Access |
|---|---|
| `admin` | Bypasses all RLS — full CRUD on everything globally |
| `user` (default) | Regular user, subject to per-mission roles |

### Per-mission (`mission_members.role`)
| Role | Can do |
|---|---|
| `member` | View mission, complete quests with proof |
| `manager` | Add/edit/delete quests, invite & manage members, review proofs |

System `admin` bypasses everything — they don't even need a `mission_members` row.

---

## Manager View

Managers see a scoped version of the web app — only missions they're a manager of.

### What managers CAN do (per their missions)
- View mission dashboard, members, quests
- Create, edit, delete quests
- Invite new members (sends Flutter notification)
- Promote members to manager / demote managers to member
- Remove members
- Review proof submissions (approve/reject)

### What managers CANNOT do
- Create new missions (only system admins can)
- Delete the mission
- Access other missions they aren't a manager of
- View/edit/delete quests they don't have permission for (enforced at DB level)

### Implementation note
The web app queries `mission_members` for the logged-in user with `role = 'manager'` to determine which missions to show. System admins see every mission via a separate query (no membership check).

---

## Core Workflows

### 1. Auth
- Login via Supabase Auth (same instance as the Flutter app)
- On login, check role:
  - `profiles.role = 'admin'` → full access, sees all missions
  - `mission_members` has a row with `role = 'manager'` → scoped access, sees only their missions
  - Otherwise → 403 page

### 2. Mission CRUD
- **List missions** — query `missions` table, show all (admin bypass)
- **Create** — insert into `missions` with `created_by = auth.uid()`
  - Auto-insert creator into `mission_members` as `manager`
- **Edit** — name, description, active/inactive toggle
- **Delete** — cascade deletes `mission_members` and orphaned quests

### 3. Member Management
- **View members** — `SELECT * FROM mission_members WHERE mission_id = :id`
- **Invite** — insert row into `mission_members` with `invited_by`, no `joined_at`
  - The existing DB trigger `notify_mission_invite()` auto-creates a notification in the Flutter app
  - Users accept/decline from the Flutter notifications page (via RPCs `accept_mission_invite` / `decline_mission_invite`)
- **Change role** — `UPDATE mission_members SET role = 'manager' WHERE ...`
- **Remove** — `DELETE FROM mission_members WHERE ...`

### 4. Quest (Task) Management
- **List quests** — `SELECT * FROM tasks WHERE mission_id = :mission_id`
- **Create** — insert into `tasks` with `mission_id`, `user_id` (assigned to a member)
  - Insert triggers: `validate_quest_mission` (checks mission exists), `require_quest_proof` won't fire (not completing yet)
- **Edit** — title, description, points, priority, etc.
- **Delete** — delete the task

### 5. Proof Review
- **List submissions** — tasks with `done = true AND mission_id IS NOT NULL AND (proof_notes IS NOT NULL OR proof_image IS NOT NULL)`
- **View proof** — show `proof_notes` and `proof_image` (URL from `task-proofs` storage bucket)
- **Review actions**:
  - **Approve** — insert into `proof_reviews` with `approved = true`, optionally `feedback`
  - **Reject** — insert into `proof_reviews` with `approved = false`, `feedback` required
    - On reject: set `done = false` on the task (admin-only DB action — the `prevent_quest_uncomplete` trigger blocks regular users from uncompleting)
- **Review history** — all rows from `proof_reviews` for a given `task_id`

### 6. Stats & Dashboard
- Per mission:
  - Total quests, completed quests, pending reviews
  - Member leaderboard (XP earned from quests)
  - Recent activity

---

## DB Entities Summary

| Table | Purpose |
|---|---|
| `missions` | A mission group — container for quests and members |
| `mission_members` | Links users to missions with a role; invite lifecycle |
| `proof_reviews` | Admin/manager review records for completed quest proof |
| `tasks` | Shared with Flutter app; quests have `mission_id` set |
| `profiles` | User profiles; `role` column flags system admins |
| `notifications` | In-app notifications; `mission_invite` type for invites |
| `activity_logs` | XP-earning activity; `quest_id` set for quest completions |
| `proof_reviews` | Approval/rejection records with feedback |

---

## DB Enforcement (Triggers & RLS)

All business rules are enforced at the DB level — the web app can't bypass them either:

| Rule | Enforced by |
|---|---|
| Can't uncomplete a quest | `prevent_quest_uncomplete` trigger |
| Can't edit quest content without role | `prevent_quest_edit` trigger |
| Can't delete quest without role | RLS policy on `tasks` |
| Can't insert quest without role | RLS policy on `tasks` |
| Can't complete quest without proof | `require_quest_proof` trigger |
| `mission_id` must reference real mission | `validate_quest_mission` trigger |
| Invite auto-creates notification | `notify_mission_invite` trigger |

---

## Tables & Columns

### `missions`
| Column | Type | Description |
|---|---|---|
| `id` | `UUID PK` | Unique mission ID |
| `name` | `TEXT NOT NULL` | Mission name |
| `description` | `TEXT` | Optional description |
| `created_by` | `UUID FK -> profiles.id` | Who created it |
| `is_active` | `BOOLEAN DEFAULT true` | Soft-disable |
| `created_at` | `TIMESTAMPTZ` | Creation timestamp |
| `updated_at` | `TIMESTAMPTZ` | Last update |

### `mission_members`
| Column | Type | Description |
|---|---|---|
| `mission_id` | `UUID FK -> missions.id` | Which mission |
| `user_id` | `UUID FK -> profiles.id` | Which user |
| `role` | `TEXT DEFAULT 'member'` | `member` or `manager` |
| `invited_by` | `UUID FK -> profiles.id` | Who sent the invite |
| `joined_at` | `TIMESTAMPTZ` | NULL until user accepts |

### `proof_reviews`
| Column | Type | Description |
|---|---|---|
| `id` | `UUID PK` | Unique review ID |
| `task_id` | `TEXT FK -> tasks.id` | Which quest was reviewed |
| `reviewed_by` | `UUID FK -> profiles.id` | Who reviewed |
| `approved` | `BOOLEAN` | true = approved, false = rejected, null = pending |
| `feedback` | `TEXT` | Optional review notes |
| `reviewed_at` | `TIMESTAMPTZ` | When reviewed |

### `tasks` (quest-relevant columns)
| Column | Type | Description |
|---|---|---|
| `id` | `TEXT PK` | Unique task ID |
| `user_id` | `UUID FK -> profiles.id` | Assigned user |
| `mission_id` | `TEXT` | NULL for personal tasks, set for quests |
| `title` | `TEXT NOT NULL` | Quest title |
| `description` | `TEXT` | Quest description |
| `points` | `INTEGER` | XP value |
| `done` | `BOOLEAN` | Completion status |
| `proof_notes` | `TEXT` | Proof text submitted by user |
| `proof_image` | `TEXT` | Proof image URL |
| `proof_rating` | `INTEGER` | Rating (1-5) |
| `priority` | `INTEGER` | Priority level |
| `recurring` | `TEXT` | Recurring type |
| `lastCompletedAt` | `TIMESTAMPTZ` | Last completion timestamp |
| `bonusEarned` | `INTEGER` | Bonus XP earned |

### `profiles`
| Column | Type | Description |
|---|---|---|
| `id` | `UUID PK` | Matches `auth.users.id` |
| `role` | `TEXT DEFAULT 'user'` | `user` or `admin` |
| `username` | `TEXT` | Display name |
| `avatar_url` | `TEXT` | Profile picture |
| `xp` | `INTEGER` | Total XP |

### `notifications`
| Column | Type | Description |
|---|---|---|
| `id` | `UUID PK` | Unique ID |
| `user_id` | `UUID FK -> profiles.id` | Recipient |
| `type` | `TEXT` | `mission_invite`, `challenge`, etc. |
| `title` | `TEXT` | Notification title |
| `body` | `TEXT` | Notification body |
| `data` | `JSONB` | Extra data (e.g. `{mission_id, inviter_name}`) |
| `read` | `BOOLEAN` | Read status |
| `created_at` | `TIMESTAMPTZ` | When created |

### `activity_logs`
| Column | Type | Description |
|---|---|---|
| `id` | `UUID PK` | Unique ID |
| `task_id` | `TEXT` | Related task |
| `user_id` | `UUID` | Who earned the XP |
| `task` | `TEXT` | Task title snapshot |
| `points` | `INTEGER` | XP earned |
| `time` | `TEXT` | Timestamp string |
| `icon` | `TEXT` | Display icon |
| `rating` | `INTEGER` | Rating |
| `notes` | `TEXT` | Proof notes snapshot |
| `image_url` | `TEXT` | Proof image snapshot |
| `quest_id` | `TEXT` | Set for quest completions |

---

## RLS Policies

### `missions`
| Policy | Action | Access |
|---|---|---|
| Members and admins can view missions | SELECT | Member of mission OR admin |
| Admins can insert missions | INSERT | Admin only |
| Admins can update missions | UPDATE | Admin only |
| Admins can delete missions | DELETE | Admin only |

### `mission_members`
| Policy | Action | Access |
|---|---|---|
| Members and admins can view | SELECT | Self OR admin |
| Admins and managers can insert | INSERT | Admin OR manager in mission |
| Admins and managers can update | UPDATE | Admin OR manager (or self for leave) |
| Admins and managers can delete | DELETE | Admin OR manager |

### `proof_reviews`
| Policy | Action | Access |
|---|---|---|
| Task owner, admins, managers can view | SELECT | Task owner OR admin OR manager in mission |
| Admins and managers can insert | INSERT | Admin OR manager in mission |
| Admins and managers can update | UPDATE | Admin OR manager in mission |

### `tasks`
| Policy | Action | Access |
|---|---|---|
| Users can view their own tasks | SELECT | Owned by user |
| Users can insert their own tasks | INSERT | Owned by user, and if mission_id set: admin OR manager |
| Users can update their own tasks | UPDATE | Owned by user |
| Users can delete their own tasks | DELETE | Owned by user, and if mission_id set: admin OR manager |

---

## Key DB Triggers

| Trigger | When | What |
|---|---|---|
| `prevent_quest_uncomplete` | BEFORE UPDATE on tasks | Blocks `done: true→false` on quests |
| `prevent_quest_edit` | BEFORE UPDATE on tasks | Blocks content edits on quests unless admin/manager |
| `require_quest_proof` | BEFORE UPDATE on tasks | Blocks completing quests without proof |
| `validate_quest_mission` | BEFORE INSERT/UPDATE of mission_id on tasks | Ensures `mission_id` references a real mission |
| `notify_mission_invite` | AFTER INSERT on mission_members | Auto-creates notification when `joined_at IS NULL` |
| `handle_task_completion` | (expected trigger on tasks) | XP/gamification logic on complete/uncomplete |

## Invite Flow

1. Web app inserts `mission_members` row with `joined_at = NULL` and `invited_by` set
2. DB trigger `notify_mission_invite()` creates notification in `notifications` table
3. Flutter user sees notification in their notification list with Accept/Decline buttons
4. On accept: `accept_mission_invite` RPC sets `joined_at = now()`
5. On decline: `decline_mission_invite` RPC deletes the `mission_members` row
6. The state resets in real-time via the existing Supabase subscription

## Migration Run Order

1. `20260628000000_add_missions_feature.sql` — tables + base RLS + updated `handle_task_completion`
2. `20260629000000_remove_mission_icon_color.sql` — drops `icon`/`color` from `missions`
3. `20260629000001_mission_invite_notification_trigger.sql` — auto-notify + accept/decline RPCs
4. `20260630000001_mission_member_roles.sql` — replaces permission booleans with `role` column
5. `20260630000000_block_quest_undo.sql` — DB-level enforcement triggers + task RLS policies
