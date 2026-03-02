import { useState, useEffect, useMemo, useCallback, useRef } from "react";

/* ══════════════════ DATA ══════════════════ */
const TASKS_INIT = [
  { id: 1, title: "Morning Meditation", desc: "10 minutes of mindfulness breathing exercises.", time: "6:30 AM", points: 50, project: "Wellness", streak: 12, done: false, priority: "high", category: "Health" },
  { id: 2, title: "Review Pull Requests", desc: "Check and approve pending PRs on the main repo.", time: "9:00 AM", points: 80, project: "DevOps", streak: 5, done: true, priority: "high", category: "Work" },
  { id: 3, title: "Read 20 Pages", desc: "Continue reading 'Atomic Habits' — Chapter 7.", time: "12:30 PM", points: 30, project: "Growth", streak: 21, done: false, priority: "medium", category: "Learning" },
  { id: 4, title: "Gym Session", desc: "Upper body: bench, OHP, rows, curls.", time: "5:00 PM", points: 100, project: "Wellness", streak: 8, done: false, priority: "high", category: "Health" },
  { id: 5, title: "Update Design System", desc: "Sync Figma tokens with codebase.", time: "3:00 PM", points: 60, project: "UI Kit", streak: 3, done: false, priority: "medium", category: "Work" },
  { id: 6, title: "Journal Entry", desc: "Wins, lessons, and gratitude list.", time: "9:30 PM", points: 40, project: "Growth", streak: 30, done: false, priority: "low", category: "Personal" },
  { id: 7, title: "Team Standup Notes", desc: "Prepare blockers and progress update.", time: "8:45 AM", points: 25, project: "DevOps", streak: 15, done: true, priority: "low", category: "Work" },
  { id: 8, title: "Drink 2L Water", desc: "Track water intake throughout the day.", time: "All day", points: 20, project: "Wellness", streak: 45, done: true, priority: "low", category: "Health" },
];

const LEADERBOARD = [
  { name: "You", xp: 2480, avatar: "🧑‍💻", level: 14, streak: 30, tasksWeek: 42 },
  { name: "Priya S.", xp: 2350, avatar: "👩‍🎨", level: 13, streak: 18, tasksWeek: 38 },
  { name: "Marcus W.", xp: 2100, avatar: "🧔", level: 12, streak: 25, tasksWeek: 35 },
  { name: "Luna K.", xp: 1890, avatar: "👩‍🔬", level: 11, streak: 10, tasksWeek: 31 },
  { name: "Jake T.", xp: 1650, avatar: "🧑‍🚀", level: 10, streak: 7, tasksWeek: 28 },
  { name: "Ava M.", xp: 1520, avatar: "👩‍🏫", level: 9, streak: 14, tasksWeek: 24 },
];

const PROJECT_STATS = [
  { name: "Wellness", completed: 24, total: 30, color: "#06d6a0" },
  { name: "DevOps", completed: 18, total: 25, color: "#8338ec" },
  { name: "Growth", completed: 31, total: 35, color: "#ffbe0b" },
  { name: "UI Kit", completed: 8, total: 15, color: "#fb5607" },
  { name: "Personal", completed: 12, total: 20, color: "#ff006e" },
];

const NOTIFS = [
  { id: 1, text: "🔥 12-day streak for Meditation!", time: "2m ago", read: false },
  { id: 2, text: "🏆 Priya passed your weekly score!", time: "15m ago", read: false },
  { id: 3, text: "⭐ 'Consistency King' badge earned!", time: "1h ago", read: false },
  { id: 4, text: "📈 Productivity up 23% this week.", time: "3h ago", read: true },
];

const ACTIVITY_LOG = [
  { task: "Review Pull Requests", points: 80, time: "Today, 9:14 AM", icon: "💼" },
  { task: "Team Standup Notes", points: 25, time: "Today, 8:52 AM", icon: "💼" },
  { task: "Drink 2L Water", points: 20, time: "Today, 6:00 PM", icon: "💪" },
  { task: "Morning Meditation", points: 50, time: "Yesterday, 6:35 AM", icon: "💪" },
  { task: "Gym Session", points: 100, time: "Yesterday, 5:22 PM", icon: "💪" },
  { task: "Read 20 Pages", points: 30, time: "Yesterday, 12:45 PM", icon: "📚" },
  { task: "Journal Entry", points: 40, time: "Yesterday, 9:40 PM", icon: "🏠" },
  { task: "Update Design System", points: 60, time: "2d ago, 3:15 PM", icon: "💼" },
];

const HOURLY_DATA = [
  { h: "6a", v: 3 }, { h: "7a", v: 2 }, { h: "8a", v: 5 }, { h: "9a", v: 8 }, { h: "10a", v: 7 },
  { h: "11a", v: 6 }, { h: "12p", v: 4 }, { h: "1p", v: 3 }, { h: "2p", v: 5 }, { h: "3p", v: 7 },
  { h: "4p", v: 6 }, { h: "5p", v: 8 }, { h: "6p", v: 4 }, { h: "7p", v: 3 }, { h: "8p", v: 2 },
  { h: "9p", v: 4 }, { h: "10p", v: 1 },
];

const WEEKLY_XP = [
  { day: "Mon", xp: 320 }, { day: "Tue", xp: 480 }, { day: "Wed", xp: 250 },
  { day: "Thu", xp: 560 }, { day: "Fri", xp: 410 }, { day: "Sat", xp: 180 }, { day: "Sun", xp: 340 },
];

const CATEGORY_DATA = [
  { name: "Work", value: 35, color: "#8338ec" },
  { name: "Health", value: 28, color: "#06d6a0" },
  { name: "Learning", value: 20, color: "#ffbe0b" },
  { name: "Personal", value: 17, color: "#ff006e" },
];

const BADGES = [
  { icon: "🔥", name: "Streak Lord", unlocked: true },
  { icon: "⚡", name: "Speed Demon", unlocked: true },
  { icon: "🎯", name: "Perfectionist", unlocked: true },
  { icon: "🏆", name: "Champion", unlocked: true },
  { icon: "🌟", name: "Rising Star", unlocked: true },
  { icon: "💎", name: "Diamond", unlocked: true },
  { icon: "🦁", name: "Brave Heart", unlocked: false },
  { icon: "🌙", name: "Night Owl", unlocked: false },
  { icon: "🌅", name: "Early Bird", unlocked: true },
  { icon: "🤝", name: "Team Player", unlocked: false },
];

const RANK_TIERS = [
  { name: "Bronze", min: 0, icon: "🥉", color: "#cd7f32", glow: "rgba(205,127,50,0.3)" },
  { name: "Silver", min: 500, icon: "🥈", color: "#c0c0c0", glow: "rgba(192,192,192,0.3)" },
  { name: "Gold", min: 1500, icon: "🥇", color: "#ffd700", glow: "rgba(255,215,0,0.3)" },
  { name: "Diamond", min: 3000, icon: "💎", color: "#00d4ff", glow: "rgba(0,212,255,0.3)" },
  { name: "Legend", min: 5000, icon: "👑", color: "#ff006e", glow: "rgba(255,0,110,0.3)" },
];

const WHEEL_SEGMENTS = [
  { label: "+50 XP", value: 50, type: "xp", color: "#06d6a0" },
  { label: "2× Next", value: 2, type: "multi", color: "#8338ec" },
  { label: "+20 XP", value: 20, type: "xp", color: "#3a86ff" },
  { label: "🛡️ Shield", value: 1, type: "shield", color: "#ffbe0b" },
  { label: "+100 XP", value: 100, type: "xp", color: "#ff006e" },
  { label: "+30 XP", value: 30, type: "xp", color: "#fb5607" },
  { label: "3× Next", value: 3, type: "multi", color: "#06d6a0" },
  { label: "+75 XP", value: 75, type: "xp", color: "#8338ec" },
];

const BOSS_INIT = { name: "Procrastination Dragon", emoji: "🐉", hp: 500, maxHp: 500, reward: 300, tasksDone: 0, tasksNeeded: 15 };

const SKILL_TREE = [
  { id: "focus1", name: "Focus I", desc: "+5% Work XP", icon: "🎯", cost: 100, unlocked: true, col: 1, row: 0 },
  { id: "focus2", name: "Focus II", desc: "+10% Work XP", icon: "🎯", cost: 250, unlocked: true, col: 1, row: 1 },
  { id: "focus3", name: "Focus III", desc: "+20% Work XP", icon: "🎯", cost: 500, unlocked: false, col: 1, row: 2 },
  { id: "vitality1", name: "Vitality I", desc: "+5% Health XP", icon: "❤️", cost: 100, unlocked: true, col: 0, row: 0 },
  { id: "vitality2", name: "Vitality II", desc: "+10% Health XP", icon: "❤️", cost: 250, unlocked: false, col: 0, row: 1 },
  { id: "wisdom1", name: "Wisdom I", desc: "+5% Learn XP", icon: "📖", cost: 100, unlocked: true, col: 2, row: 0 },
  { id: "wisdom2", name: "Wisdom II", desc: "+10% Learn XP", icon: "📖", cost: 250, unlocked: false, col: 2, row: 1 },
  { id: "combo", name: "Combo+", desc: "Slower combo decay", icon: "🔥", cost: 400, unlocked: false, col: 1, row: 3 },
];

const DAILY_CHALLENGES_INIT = [
  { id: 1, title: "Early Bird", desc: "Complete a task before 8 AM", reward: 75, icon: "🌅", done: false },
  { id: 2, title: "Triple Threat", desc: "Complete 3 tasks in a row", reward: 100, icon: "⚡", done: false },
  { id: 3, title: "Health Hero", desc: "Complete 2 Health tasks", reward: 60, icon: "💪", done: false },
];

const PET_STAGES = [
  { name: "Egg", emoji: "🥚", minTasks: 0, size: 28 },
  { name: "Baby Slime", emoji: "🫧", minTasks: 3, size: 32 },
  { name: "Fox Cub", emoji: "🦊", minTasks: 10, size: 36 },
  { name: "Phoenix", emoji: "🦅", minTasks: 25, size: 40 },
  { name: "Dragon", emoji: "🐲", minTasks: 50, size: 44 },
];

const generateHeatmap = () => {
  const d = [];
  for (let w = 0; w < 12; w++) { const wk = []; for (let i = 0; i < 7; i++) wk.push(Math.min(Math.floor(Math.random() * 7) + (w > 8 ? 3 : 1), 8)); d.push(wk); }
  return d;
};

/* ══════════════════ COMPONENTS ══════════════════ */

function ConfettiBurst({ show }) {
  if (!show) return null;
  return (
    <div style={{ position: "fixed", top: "50%", left: "50%", zIndex: 9999, pointerEvents: "none" }}>
      {Array.from({ length: 28 }, (_, i) => (
        <div key={i} style={{
          position: "absolute", width: Math.random() * 7 + 3, height: Math.random() * 7 + 3,
          borderRadius: Math.random() > 0.5 ? "50%" : "2px",
          background: ["#06d6a0", "#8338ec", "#ffbe0b", "#fb5607", "#ff006e", "#3a86ff"][i % 6],
          animation: `confetti-burst 0.9s cubic-bezier(.25,.46,.45,.94) ${Math.random() * 0.35}s forwards`,
          "--tx": `${Math.random() * 260 - 130}px`, "--ty": `${Math.random() * -200 - 40}px`, "--tr": `${Math.random() * 540}deg`,
        }} />
      ))}
    </div>
  );
}

function AnimNum({ value }) {
  const [d, setD] = useState(0);
  useEffect(() => { let s = 0; const step = value / 42; const id = setInterval(() => { s += step; if (s >= value) { setD(value); clearInterval(id); } else setD(Math.floor(s)); }, 16); return () => clearInterval(id); }, [value]);
  return <span>{d.toLocaleString()}</span>;
}

function XPFloat({ floats }) {
  return (
    <div style={{ position: "fixed", inset: 0, pointerEvents: "none", zIndex: 9998 }}>
      {floats.map(f => (
        <div key={f.id} style={{ position: "absolute", left: f.x, top: f.y, fontFamily: "'JetBrains Mono'", fontWeight: 800, fontSize: 20, color: f.multi > 1 ? "#ff006e" : "#06d6a0", animation: "xp-float 1.2s ease-out forwards", textShadow: "0 0 12px currentColor" }}>
          +{f.value}{f.multi > 1 ? ` ×${f.multi}` : ""}
        </div>
      ))}
    </div>
  );
}

function AchievementToast({ toast, onDone }) {
  useEffect(() => { if (toast) { const t = setTimeout(onDone, 3200); return () => clearTimeout(t); } }, [toast]);
  if (!toast) return null;
  return (
    <div style={{ position: "fixed", top: 68, left: "50%", transform: "translateX(-50%)", zIndex: 9997, background: "linear-gradient(135deg, #101018, #181824)", border: "1px solid rgba(255,190,11,0.4)", borderRadius: 14, padding: "12px 20px", display: "flex", alignItems: "center", gap: 10, animation: "toast-in 0.5s ease", boxShadow: "0 8px 32px rgba(0,0,0,0.6), 0 0 20px rgba(255,190,11,0.15)", maxWidth: 340 }}>
      <div style={{ fontSize: 28, animation: "badge-bounce 0.6s ease" }}>{toast.icon}</div>
      <div>
        <div style={{ fontSize: 9, color: "#ffbe0b", fontFamily: "'JetBrains Mono'", fontWeight: 700, letterSpacing: 1.5, textTransform: "uppercase" }}>Achievement Unlocked!</div>
        <div style={{ fontSize: 13, fontWeight: 800, marginTop: 1 }}>{toast.title}</div>
        <div style={{ fontSize: 10, color: "#8888a8", marginTop: 1 }}>{toast.desc}</div>
      </div>
    </div>
  );
}

function DonutChart({ data, size = 126 }) {
  const total = data.reduce((s, d) => s + d.value, 0);
  let cum = 0; const r = 46, cx = 63, cy = 63, circ = 2 * Math.PI * r;
  return (
    <svg width={size} height={size} viewBox="0 0 126 126">
      {data.map((seg, i) => { const pct = seg.value / total, dl = pct * circ, off = -cum * circ; cum += pct; return <circle key={i} cx={cx} cy={cy} r={r} fill="none" stroke={seg.color} strokeWidth={18} strokeDasharray={`${dl} ${circ - dl}`} strokeDashoffset={off} strokeLinecap="round" style={{ transition: "stroke-dasharray 1s ease", transform: "rotate(-90deg)", transformOrigin: "center" }} />; })}
      <text x={cx} y={cy - 3} textAnchor="middle" fill="#e8e8f0" fontSize="18" fontWeight="800" fontFamily="'JetBrains Mono'">{total}</text>
      <text x={cx} y={cy + 11} textAnchor="middle" fill="#555570" fontSize="8" fontWeight="600">TASKS</text>
    </svg>
  );
}

function HeatmapGrid({ data }) {
  const days = ["M", "T", "W", "T", "F", "S", "S"];
  const gc = v => v === 0 ? "rgba(255,255,255,0.03)" : v <= 2 ? "rgba(6,214,160,0.15)" : v <= 4 ? "rgba(6,214,160,0.35)" : v <= 6 ? "rgba(6,214,160,0.6)" : "rgba(6,214,160,0.9)";
  return (
    <div style={{ display: "flex", gap: 3 }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 3, marginRight: 2 }}>
        {days.map((d, i) => <div key={i} style={{ width: 12, height: 14, fontSize: 8, color: "#555570", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "'JetBrains Mono'" }}>{d}</div>)}
      </div>
      {data.map((week, wi) => (<div key={wi} style={{ display: "flex", flexDirection: "column", gap: 3 }}>{week.map((val, di) => <div key={di} style={{ width: 14, height: 14, borderRadius: 3, background: gc(val), transition: `background 0.3s ease ${(wi * 7 + di) * 0.006}s` }} />)}</div>))}
    </div>
  );
}

function Sparkline({ data, color = "#06d6a0", height = 52 }) {
  const max = Math.max(...data.map(d => d.xp)); const w = 280, h = height;
  const pts = data.map((d, i) => `${(i / (data.length - 1)) * w},${h - (d.xp / max) * (h - 10) - 5}`).join(" ");
  return (
    <svg width="100%" height={h} viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none">
      <defs><linearGradient id="sf" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor={color} stopOpacity="0.3" /><stop offset="100%" stopColor={color} stopOpacity="0" /></linearGradient></defs>
      <polygon points={`0,${h} ${pts} ${w},${h}`} fill="url(#sf)" /><polyline points={pts} fill="none" stroke={color} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function Gauge({ value, max, label, color }) {
  const pct = (value / max) * 100, r = 32, circ = 2 * Math.PI * r;
  return (<div style={{ textAlign: "center" }}><svg width="76" height="76" viewBox="0 0 76 76"><circle cx="38" cy="38" r={r} fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth="5" /><circle cx="38" cy="38" r={r} fill="none" stroke={color} strokeWidth="5" strokeDasharray={`${(pct / 100) * circ} ${circ - (pct / 100) * circ}`} strokeDashoffset={circ * 0.25} strokeLinecap="round" style={{ transition: "stroke-dasharray 1.2s ease" }} /><text x="38" y="36" textAnchor="middle" fill="#e8e8f0" fontSize="13" fontWeight="800" fontFamily="'JetBrains Mono'">{Math.round(pct)}%</text><text x="38" y="48" textAnchor="middle" fill="#555570" fontSize="7" fontWeight="600">{label}</text></svg></div>);
}

/* ══════════════════ SPIN WHEEL ══════════════════ */
function SpinWheel({ visible, onClose, onResult }) {
  const [spinning, setSpinning] = useState(false);
  const [rotation, setRotation] = useState(0);
  const [result, setResult] = useState(null);

  const spin = () => {
    if (spinning) return; setSpinning(true); setResult(null);
    const segAngle = 360 / WHEEL_SEGMENTS.length;
    const winIdx = Math.floor(Math.random() * WHEEL_SEGMENTS.length);
    const extra = 360 * 5 + (360 - winIdx * segAngle - segAngle / 2);
    setRotation(prev => prev + extra);
    setTimeout(() => { setSpinning(false); setResult(WHEEL_SEGMENTS[winIdx]); onResult(WHEEL_SEGMENTS[winIdx]); }, 3500);
  };

  if (!visible) return null;
  return (
    <div className="modal-ov" onClick={e => { if (e.target === e.currentTarget && !spinning) onClose(); }}>
      <div className="modal-sh" style={{ textAlign: "center", paddingTop: 24 }}>
        <div className="modal-h" />
        <div style={{ fontFamily: "'JetBrains Mono'", fontSize: 15, fontWeight: 700, marginBottom: 18 }}>🎰 Daily Spin</div>
        <div style={{ position: "relative", width: 220, height: 220, margin: "0 auto 18px" }}>
          <div style={{ position: "absolute", top: -8, left: "50%", transform: "translateX(-50%)", zIndex: 2, fontSize: 18, color: "var(--warn)" }}>▼</div>
          <svg width="220" height="220" viewBox="0 0 220 220" style={{ transition: spinning ? "transform 3.5s cubic-bezier(0.17, 0.67, 0.12, 0.99)" : "none", transform: `rotate(${rotation}deg)` }}>
            {WHEEL_SEGMENTS.map((seg, i) => {
              const angle = (2 * Math.PI) / WHEEL_SEGMENTS.length;
              const startA = i * angle - Math.PI / 2, endA = startA + angle;
              const x1 = 110 + 100 * Math.cos(startA), y1 = 110 + 100 * Math.sin(startA);
              const x2 = 110 + 100 * Math.cos(endA), y2 = 110 + 100 * Math.sin(endA);
              const midA = startA + angle / 2;
              const tx = 110 + 65 * Math.cos(midA), ty = 110 + 65 * Math.sin(midA);
              return (
                <g key={i}>
                  <path d={`M110,110 L${x1},${y1} A100,100 0 0,1 ${x2},${y2} Z`} fill={seg.color} opacity="0.8" stroke="var(--bg)" strokeWidth="2" />
                  <text x={tx} y={ty} textAnchor="middle" dominantBaseline="middle" fill="white" fontSize="9" fontWeight="700" fontFamily="'JetBrains Mono'" transform={`rotate(${(i * 360 / WHEEL_SEGMENTS.length) + 360 / WHEEL_SEGMENTS.length / 2}, ${tx}, ${ty})`}>{seg.label}</text>
                </g>
              );
            })}
            <circle cx="110" cy="110" r="20" fill="var(--bg)" stroke="var(--border)" strokeWidth="2" />
            <text x="110" y="114" textAnchor="middle" fill="var(--accent)" fontSize="16">🎰</text>
          </svg>
        </div>
        {result && (
          <div style={{ animation: "scaleIn 0.3s ease", padding: 14, background: "var(--surface2)", borderRadius: 12, marginBottom: 14, border: `1px solid ${result.color}40` }}>
            <div style={{ fontSize: 24, marginBottom: 4 }}>{result.type === "shield" ? "🛡️" : result.type === "multi" ? "✨" : "⚡"}</div>
            <div style={{ fontFamily: "'JetBrains Mono'", fontSize: 16, fontWeight: 800, color: result.color }}>{result.label}</div>
            <div style={{ fontSize: 10, color: "#8888a8", marginTop: 3 }}>{result.type === "shield" ? "Streak Shield — protects one missed day" : result.type === "multi" ? `${result.value}× multiplier on your next task!` : "Bonus XP added!"}</div>
          </div>
        )}
        <button onClick={spinning ? undefined : (result ? onClose : spin)} className="sub-btn" style={{ opacity: spinning ? 0.5 : 1 }}>{spinning ? "Spinning..." : result ? "Collect & Close" : "🎰 SPIN!"}</button>
      </div>
    </div>
  );
}

/* ══════════════════ LOOT BOX ══════════════════ */
function LootBox({ visible, onClose, onOpen }) {
  const [opened, setOpened] = useState(false);
  const [loot, setLoot] = useState(null);
  const loots = [
    { icon: "⚡", name: "+150 Bonus XP", desc: "A surge of energy!", rarity: "Rare", color: "#06d6a0" },
    { icon: "🛡️", name: "Streak Shield", desc: "Protect your streak", rarity: "Epic", color: "#8338ec" },
    { icon: "✨", name: "3× Multiplier", desc: "Triple XP next task", rarity: "Legendary", color: "#ffbe0b" },
    { icon: "🎨", name: "Neon Theme", desc: "Unlock neon glow", rarity: "Rare", color: "#ff006e" },
    { icon: "🐲", name: "Dragon Egg", desc: "Pet evolution boost", rarity: "Legendary", color: "#fb5607" },
  ];
  const open = () => { const item = loots[Math.floor(Math.random() * loots.length)]; setLoot(item); setOpened(true); onOpen(item); };
  const close = () => { setOpened(false); setLoot(null); onClose(); };
  if (!visible) return null;
  return (
    <div className="modal-ov" onClick={e => { if (e.target === e.currentTarget) close(); }}>
      <div className="modal-sh" style={{ textAlign: "center", paddingTop: 24 }}>
        <div className="modal-h" />
        {!opened ? (
          <>
            <div style={{ fontSize: 64, animation: "chest-glow 2s ease-in-out infinite", marginBottom: 14 }}>🎁</div>
            <div style={{ fontFamily: "'JetBrains Mono'", fontSize: 15, fontWeight: 700, marginBottom: 6 }}>Treasure Chest!</div>
            <div style={{ fontSize: 11, color: "#8888a8", marginBottom: 20 }}>Earned by completing a task set.</div>
            <button className="sub-btn" onClick={open}>🔓 Open Chest</button>
          </>
        ) : (
          <>
            <div style={{ animation: "loot-reveal 0.6s ease", fontSize: 52, marginBottom: 10 }}>{loot.icon}</div>
            <div style={{ fontFamily: "'JetBrains Mono'", fontSize: 9, fontWeight: 700, color: loot.color, letterSpacing: 2, textTransform: "uppercase", marginBottom: 3 }}>{loot.rarity}</div>
            <div style={{ fontSize: 16, fontWeight: 800, marginBottom: 3 }}>{loot.name}</div>
            <div style={{ fontSize: 11, color: "#8888a8", marginBottom: 20 }}>{loot.desc}</div>
            <button className="sub-btn" onClick={close}>✨ Collect</button>
          </>
        )}
      </div>
    </div>
  );
}

/* ══════════════════ MAIN APP ══════════════════ */
export default function TaskManager() {
  const [tab, setTab] = useState("tasks");
  const [tasks, setTasks] = useState(TASKS_INIT);
  const [showAdd, setShowAdd] = useState(false);
  const [showNotif, setShowNotif] = useState(false);
  const [showSpin, setShowSpin] = useState(false);
  const [showLoot, setShowLoot] = useState(false);
  const [openDesc, setOpenDesc] = useState(null);
  const [confetti, setConfetti] = useState(false);
  const [notifs, setNotifs] = useState(NOTIFS);
  const [lbFilter, setLbFilter] = useState("weekly");
  const [profileTab, setProfileTab] = useState("activity");
  const [statsTab, setStatsTab] = useState("overview");
  const [activityLog, setActivityLog] = useState(ACTIVITY_LOG);
  const [inviteSent, setInviteSent] = useState(false);
  const [challengeSent, setChallengeSent] = useState(null);
  const [newTask, setNewTask] = useState({ title: "", desc: "", category: "Work", frequency: "Daily", time: "09:00", priority: "medium" });
  const [spinUsed, setSpinUsed] = useState(false);
  const [xpFloats, setXpFloats] = useState([]);
  const [toast, setToast] = useState(null);
  const [dailyChallenges, setDailyChallenges] = useState(DAILY_CHALLENGES_INIT);
  const [combo, setCombo] = useState(0);
  const [comboTimer, setComboTimer] = useState(null);
  const [multiplier, setMultiplier] = useState(1);
  const [bonusXP, setBonusXP] = useState(0);
  const [boss, setBoss] = useState(BOSS_INIT);
  const [totalLifetimeTasks, setTotalLifetimeTasks] = useState(47);
  const [skillTree, setSkillTree] = useState(SKILL_TREE);
  const [skillPoints, setSkillPoints] = useState(320);
  const [shields, setShields] = useState(1);
  const [lootCount, setLootCount] = useState(0);

  const heatmap = useMemo(() => generateHeatmap(), []);
  const totalXP = tasks.filter(t => t.done).reduce((s, t) => s + t.points, 0) + bonusXP;
  const level = Math.floor(totalXP / 200) + 1;
  const xpInLevel = totalXP % 200;
  const unread = notifs.filter(n => !n.read).length;
  const dailyGoal = 5;
  const dailyDone = tasks.filter(t => t.done).length;
  const currentRank = [...RANK_TIERS].reverse().find(r => totalXP >= r.min) || RANK_TIERS[0];
  const nextRank = RANK_TIERS[RANK_TIERS.indexOf(currentRank) + 1];
  const pet = [...PET_STAGES].reverse().find(p => totalLifetimeTasks >= p.minTasks) || PET_STAGES[0];
  const comboMulti = combo >= 5 ? 4 : combo >= 3 ? 3 : combo >= 2 ? 2 : 1;
  const effectiveMulti = Math.max(multiplier, comboMulti);

  const spawnXPFloat = (val, multi) => {
    const id = Date.now() + Math.random();
    setXpFloats(prev => [...prev, { id, x: 80 + Math.random() * 220, y: 280 + Math.random() * 120, value: val, multi }]);
    setTimeout(() => setXpFloats(prev => prev.filter(f => f.id !== id)), 1300);
  };

  const triggerToast = (icon, title, desc) => setToast({ icon, title, desc });

  const toggleTask = (id) => {
    setTasks(prev => prev.map(t => {
      if (t.id === id) {
        if (!t.done) {
          setConfetti(true); setTimeout(() => setConfetti(false), 1100);
          setCombo(c => c + 1);
          if (comboTimer) clearTimeout(comboTimer);
          setComboTimer(setTimeout(() => setCombo(0), 60000));
          const earnedXP = t.points * effectiveMulti;
          spawnXPFloat(earnedXP, effectiveMulti);
          if (effectiveMulti > 1) setBonusXP(prev => prev + t.points * (effectiveMulti - 1));
          if (multiplier > 1) setMultiplier(1);
          setBoss(b => { const dmg = Math.round(b.maxHp / b.tasksNeeded); const newHp = Math.max(0, b.hp - dmg); if (newHp <= 0 && b.hp > 0) { triggerToast("🐉", "Boss Defeated!", `+${b.reward} XP earned!`); setBonusXP(prev => prev + b.reward); } return { ...b, hp: newHp, tasksDone: b.tasksDone + 1 }; });
          setTotalLifetimeTasks(p => p + 1);
          setLootCount(p => { if ((p + 1) % 5 === 0) setTimeout(() => setShowLoot(true), 800); return p + 1; });
          const nc = combo + 1;
          if (nc === 3) triggerToast("🔥", "3× Combo!", "You're on fire!");
          if (nc === 5) triggerToast("⚡", "ULTRA COMBO!", "4× XP multiplier!");
          setDailyChallenges(prev => prev.map(ch => { if (ch.done) return ch; if (ch.id === 3 && t.category === "Health") return { ...ch, done: true }; return ch; }));
          const now = new Date();
          setActivityLog(prev => [{ task: t.title, points: earnedXP, time: `Today, ${now.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}`, icon: t.category === "Work" ? "💼" : t.category === "Health" ? "💪" : t.category === "Learning" ? "📚" : "🏠" }, ...prev]);
        }
        return { ...t, done: !t.done };
      }
      return t;
    }));
  };

  const addTask = () => {
    if (!newTask.title.trim()) return;
    setTasks(prev => [...prev, { id: Date.now(), title: newTask.title, desc: newTask.desc, time: new Date(`2025-01-01T${newTask.time}`).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" }), points: newTask.priority === "high" ? 80 : newTask.priority === "medium" ? 50 : 25, project: newTask.category, streak: 0, done: false, priority: newTask.priority, category: newTask.category }]);
    setNewTask({ title: "", desc: "", category: "Work", frequency: "Daily", time: "09:00", priority: "medium" }); setShowAdd(false);
  };

  const handleSpinResult = (seg) => { setSpinUsed(true); if (seg.type === "xp") setBonusXP(prev => prev + seg.value); if (seg.type === "multi") setMultiplier(seg.value); if (seg.type === "shield") setShields(p => p + 1); };

  const unlockSkill = (id) => {
    setSkillTree(prev => prev.map(s => { if (s.id === id && !s.unlocked && skillPoints >= s.cost) { setSkillPoints(p => p - s.cost); triggerToast(s.icon, `${s.name} Unlocked!`, s.desc); return { ...s, unlocked: true }; } return s; }));
  };

  const bossHpPct = Math.max(0, (boss.hp / boss.maxHp) * 100);

  return (
    <>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700;800&family=Nunito:wght@300;400;500;600;700;800;900&display=swap');
        *{margin:0;padding:0;box-sizing:border-box;-webkit-tap-highlight-color:transparent}
        :root{--bg:#08080e;--surface:#101018;--surface2:#181824;--surface3:#20202e;--border:#252538;--text:#e8e8f0;--text2:#8888a8;--text3:#555570;--accent:#06d6a0;--accent2:#8338ec;--accent3:#3a86ff;--warn:#ffbe0b;--danger:#ff006e;--orange:#fb5607}
        body{background:var(--bg)}
        @keyframes confetti-burst{0%{transform:translate(0,0) rotate(0deg);opacity:1}100%{transform:translate(var(--tx),var(--ty)) rotate(var(--tr));opacity:0}}
        @keyframes slideUp{from{transform:translateY(100%);opacity:0}to{transform:translateY(0);opacity:1}}
        @keyframes fadeIn{from{opacity:0}to{opacity:1}}
        @keyframes slideDown{from{transform:translateY(-14px);opacity:0}to{transform:translateY(0);opacity:1}}
        @keyframes checkPop{0%{transform:scale(0.4)}60%{transform:scale(1.25)}100%{transform:scale(1)}}
        @keyframes badgePulse{0%,100%{transform:scale(1)}50%{transform:scale(1.12)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        @keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-8px)}}
        @keyframes scaleIn{from{transform:scale(0.9);opacity:0}to{transform:scale(1);opacity:1}}
        @keyframes xp-float{0%{opacity:1;transform:translateY(0) scale(1)}100%{opacity:0;transform:translateY(-90px) scale(1.4)}}
        @keyframes toast-in{0%{opacity:0;transform:translateX(-50%) translateY(-20px) scale(0.9)}100%{opacity:1;transform:translateX(-50%) translateY(0) scale(1)}}
        @keyframes badge-bounce{0%{transform:scale(0.5)}50%{transform:scale(1.3)}100%{transform:scale(1)}}
        @keyframes boss-idle{0%,100%{transform:translateY(0) scale(1)}50%{transform:translateY(-6px) scale(1.03)}}
        @keyframes chest-glow{0%,100%{filter:drop-shadow(0 0 8px rgba(255,190,11,0.3));transform:scale(1)}50%{filter:drop-shadow(0 0 20px rgba(255,190,11,0.6));transform:scale(1.05)}}
        @keyframes loot-reveal{0%{transform:scale(0) rotate(-180deg);opacity:0}60%{transform:scale(1.2) rotate(10deg)}100%{transform:scale(1) rotate(0deg);opacity:1}}
        @keyframes combo-pulse{0%,100%{transform:scale(1)}50%{transform:scale(1.02)}}
        @keyframes pet-bounce{0%,100%{transform:translateY(0)}50%{transform:translateY(-4px)}}
        @keyframes glow-ring{0%,100%{box-shadow:0 0 6px var(--glow)}50%{box-shadow:0 0 18px var(--glow)}}
        .app{max-width:430px;min-height:100dvh;margin:0 auto;background:var(--bg);position:relative;overflow-x:hidden;font-family:'Nunito',sans-serif;color:var(--text)}
        .hdr{padding:14px 20px 8px;display:flex;justify-content:space-between;align-items:flex-start;position:sticky;top:0;z-index:50;background:linear-gradient(to bottom,var(--bg) 70%,transparent);backdrop-filter:blur(16px)}
        .hdr-l h1{font-family:'JetBrains Mono';font-size:19px;font-weight:800;background:linear-gradient(135deg,var(--accent),var(--accent3));-webkit-background-clip:text;-webkit-text-fill-color:transparent}
        .hdr-l p{font-size:10px;color:var(--text3);margin-top:1px}
        .hdr-xp{display:flex;align-items:center;gap:8px;margin-top:5px}
        .hdr-xp .bar{flex:1;height:3px;background:var(--surface3);border-radius:4px;overflow:hidden;max-width:100px}
        .hdr-xp .bar .fill{height:100%;border-radius:4px;background:linear-gradient(90deg,var(--accent),var(--accent3));transition:width 0.6s}
        .hdr-xp .lbl{font-family:'JetBrains Mono';font-size:9px;color:var(--accent);font-weight:700}
        .hdr-r{display:flex;gap:8px;align-items:center}
        .ic-btn{width:38px;height:38px;border-radius:11px;background:var(--surface);border:1px solid var(--border);display:flex;align-items:center;justify-content:center;cursor:pointer;transition:all 0.25s;position:relative}
        .ic-btn:active{transform:scale(0.9)}
        .ic-btn svg{width:17px;height:17px;color:var(--text2)}
        .nbadge{position:absolute;top:-3px;right:-3px;min-width:15px;height:15px;border-radius:8px;background:var(--danger);color:white;font-size:8px;font-weight:800;display:flex;align-items:center;justify-content:center;padding:0 3px;animation:badgePulse 2s infinite;font-family:'JetBrains Mono'}
        .page{padding:0 0 130px}
        .px{padding:0 20px}
        .compact-row{display:flex;gap:8px;margin:0 20px 8px}
        .cc{flex:1;display:flex;align-items:center;gap:8px;padding:8px 10px;border-radius:11px}
        .cc.daily{background:rgba(6,214,160,0.06);border:1px solid rgba(6,214,160,0.1)}
        .cc.streak{background:rgba(255,190,11,0.06);border:1px solid rgba(255,190,11,0.1)}
        .cc-ring{position:relative;width:30px;height:30px;flex-shrink:0}
        .cc-ring svg{transform:rotate(-90deg)}
        .cc-num{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;font-family:'JetBrains Mono';font-size:8px;font-weight:800;color:var(--accent)}
        .cc-fire{font-size:18px;flex-shrink:0}
        .cc-t{font-size:10px;font-weight:800;line-height:1.2}
        .cc-s{font-size:8px;color:var(--text3);font-weight:600}
        .rank-b{display:flex;align-items:center;gap:8px;margin:0 20px 8px;padding:8px 12px;border-radius:11px;border:1px solid var(--border);background:var(--surface)}
        .rank-b .ri{font-size:18px}
        .rank-b .rn{font-family:'JetBrains Mono';font-size:10px;font-weight:800}
        .rank-b .rp{font-size:8px;color:var(--text3)}
        .rank-b .rb{height:3px;background:var(--surface3);border-radius:3px;overflow:hidden;margin-top:3px}
        .rank-b .rb .f{height:100%;border-radius:3px;transition:width 0.8s}
        .pet-w{display:flex;align-items:center;gap:10px;margin:0 20px 8px;padding:8px 12px;border-radius:11px;background:var(--surface);border:1px solid var(--border)}
        .pet-w .pe{animation:pet-bounce 2s ease-in-out infinite}
        .pet-w .pi{flex:1;min-width:0}
        .pet-w .pn{font-size:10px;font-weight:800}
        .pet-w .pb{height:3px;background:var(--surface3);border-radius:3px;overflow:hidden;margin-top:3px}
        .pet-w .pb .f{height:100%;background:linear-gradient(90deg,var(--warn),var(--orange));border-radius:3px;transition:width 0.6s}
        .pet-w .ps{font-size:7px;color:var(--text3);margin-top:2px;font-family:'JetBrains Mono'}
        .combo-b{margin:0 20px 8px;padding:8px 12px;border-radius:11px;display:flex;align-items:center;gap:10px;background:linear-gradient(135deg,rgba(255,0,110,0.08),rgba(251,86,7,0.06));border:1px solid rgba(255,0,110,0.12);animation:combo-pulse 1.5s ease-in-out infinite}
        .combo-b .cf{font-size:16px}
        .combo-b .ct{font-family:'JetBrains Mono';font-size:11px;font-weight:800;color:var(--danger)}
        .combo-b .cs{font-size:8px;color:var(--text3)}
        .combo-b .cm{font-family:'JetBrains Mono';font-size:15px;font-weight:800;color:var(--warn);text-shadow:0 0 10px rgba(255,190,11,0.5);margin-left:auto}
        .multi-ind{margin:0 20px 8px;padding:7px 12px;border-radius:11px;background:rgba(131,56,236,0.08);border:1px solid rgba(131,56,236,0.15);display:flex;align-items:center;gap:8px;font-size:10px;font-weight:700;color:var(--accent2)}
        .chal{margin:0 20px 10px}
        .ch-c{display:flex;align-items:center;gap:8px;padding:9px 11px;background:var(--surface);border:1px solid var(--border);border-radius:10px;margin-bottom:5px}
        .ch-c.done{opacity:0.4}
        .ch-c .ci{font-size:16px}
        .ch-c .cn{font-size:10px;font-weight:700}
        .ch-c .cd{font-size:8px;color:var(--text3)}
        .ch-c .cr{font-family:'JetBrains Mono';font-size:9px;font-weight:700;color:var(--warn);white-space:nowrap;margin-left:auto}
        .boss-c{margin:0 20px 10px;background:var(--surface);border:1px solid rgba(255,0,110,0.15);border-radius:13px;padding:14px;background:linear-gradient(135deg,rgba(255,0,110,0.04),rgba(251,86,7,0.03))}
        .boss-c .be{font-size:44px;text-align:center;margin-bottom:8px}
        .boss-c .bn{font-family:'JetBrains Mono';font-size:12px;font-weight:800;text-align:center}
        .boss-c .bd{text-align:center;color:var(--accent);font-weight:800;font-size:12px;margin-top:4px;animation:scaleIn 0.3s}
        .cnt{display:flex;justify-content:space-between;align-items:center;margin:0 20px 8px}
        .cnt span{font-family:'JetBrains Mono';font-size:10px}
        .cnt .l{color:var(--text3)}.cnt .r{color:var(--accent)}
        .tcard{background:var(--surface);border:1px solid var(--border);border-radius:13px;padding:11px 11px 11px 15px;margin-bottom:7px;transition:all 0.3s;animation:slideDown 0.3s ease backwards;position:relative;overflow:hidden}
        .tcard::after{content:'';position:absolute;top:6px;left:0;width:3px;height:calc(100% - 12px);border-radius:0 3px 3px 0}
        .tcard.hi::after{background:var(--danger)}.tcard.md::after{background:var(--warn)}.tcard.lo::after{background:var(--accent)}
        .tcard.done{opacity:0.4}.tcard.done .ttitle{text-decoration:line-through;color:var(--text2)}
        .ttop{display:flex;align-items:flex-start;gap:10px}
        .chk{width:22px;height:22px;border-radius:6px;border:2px solid var(--border);display:flex;align-items:center;justify-content:center;cursor:pointer;transition:all 0.2s;flex-shrink:0;margin-top:2px}
        .chk:active{transform:scale(0.85)}
        .chk.on{background:linear-gradient(135deg,var(--accent),var(--accent3));border-color:transparent;animation:checkPop 0.35s ease}
        .chk.on svg{opacity:1}.chk svg{opacity:0;transition:opacity 0.15s}
        .tinfo{flex:1;min-width:0}.ttitle{font-weight:700;font-size:12px;line-height:1.3;margin-bottom:5px}
        .tmeta{display:flex;flex-wrap:wrap;gap:4px}
        .chip{display:inline-flex;align-items:center;gap:2px;padding:2px 6px;border-radius:5px;font-size:9px;font-weight:600;background:var(--surface2);color:var(--text2);white-space:nowrap}
        .chip.pts{background:rgba(6,214,160,0.1);color:var(--accent);font-family:'JetBrains Mono';font-weight:700}
        .chip.strk{background:rgba(255,190,11,0.1);color:var(--warn)}.chip.proj{color:var(--accent2);background:rgba(131,56,236,0.1)}
        .nbtn{width:28px;height:28px;border-radius:7px;background:var(--surface2);border:1px solid var(--border);display:flex;align-items:center;justify-content:center;cursor:pointer;flex-shrink:0}
        .nbtn:active{transform:scale(0.9)}.nbtn svg{width:12px;height:12px;color:var(--text3)}
        .tdesc{margin-top:8px;padding:8px 10px;background:var(--surface2);border-radius:8px;border:1px solid var(--border);font-size:11px;line-height:1.5;color:var(--text2);animation:scaleIn 0.2s}
        .stitle{font-family:'JetBrains Mono';font-size:9px;font-weight:700;color:var(--text3);text-transform:uppercase;letter-spacing:2px;margin-bottom:10px}
        .scard{background:var(--surface);border:1px solid var(--border);border-radius:13px;padding:14px;margin-bottom:10px;animation:scaleIn 0.3s ease backwards}
        .stabs{display:flex;gap:3px;margin-bottom:14px;background:var(--surface);border-radius:10px;padding:3px;border:1px solid var(--border)}
        .stab{flex:1;padding:6px 2px;border-radius:7px;font-size:10px;font-weight:700;text-align:center;cursor:pointer;transition:all 0.25s;background:transparent;border:none;color:var(--text3);font-family:'Nunito'}
        .stab.on{background:var(--surface3);color:var(--text)}
        .bars{display:flex;flex-direction:column;gap:8px}
        .brow{display:flex;align-items:center;gap:8px}
        .blbl{width:50px;font-size:9px;font-weight:600;color:var(--text2);text-align:right}
        .btrack{flex:1;height:20px;background:var(--surface2);border-radius:6px;overflow:hidden}
        .bfill{height:100%;border-radius:6px;transition:width 1s ease;display:flex;align-items:center;justify-content:flex-end;padding-right:6px;font-family:'JetBrains Mono';font-size:8px;font-weight:700;color:rgba(0,0,0,0.7)}
        .lb-filters{display:flex;gap:3px;margin-bottom:12px;background:var(--surface);border-radius:10px;padding:3px;border:1px solid var(--border)}
        .lb-f{flex:1;padding:6px;border-radius:7px;font-size:10px;font-weight:700;text-align:center;cursor:pointer;transition:all 0.25s;background:transparent;border:none;color:var(--text3);font-family:'Nunito'}
        .lb-f.on{background:var(--accent2);color:white}
        .lbcard{display:flex;align-items:center;gap:10px;padding:11px;background:var(--surface);border:1px solid var(--border);border-radius:11px;margin-bottom:6px;animation:slideDown 0.2s ease backwards}
        .lbcard.you{border-color:rgba(6,214,160,0.3);background:rgba(6,214,160,0.04)}
        .lbrank{font-family:'JetBrains Mono';font-size:12px;font-weight:800;color:var(--text3);width:22px;text-align:center}
        .lbrank.g{color:var(--warn)}.lbrank.s{color:#aaa}.lbrank.b{color:#cd7f32}
        .lbav{font-size:22px}
        .lbinfo{flex:1}.lbname{font-size:11px;font-weight:700}.lbxp{font-family:'JetBrains Mono';font-size:9px;color:var(--accent);font-weight:600}
        .lbmeta{display:flex;gap:6px;margin-top:2px}.lbmeta span{font-size:8px;color:var(--text3)}
        .ch-btn{padding:4px 8px;border-radius:6px;background:rgba(131,56,236,0.15);border:1px solid rgba(131,56,236,0.3);color:var(--accent2);font-size:9px;font-weight:700;cursor:pointer;font-family:'Nunito'}
        .ch-btn:active{transform:scale(0.92)}.ch-btn.sent{background:rgba(6,214,160,0.1);border-color:rgba(6,214,160,0.3);color:var(--accent)}
        .inv-btn{width:100%;padding:12px;border-radius:12px;background:linear-gradient(135deg,var(--accent),var(--accent3));border:none;color:var(--bg);font-family:'Nunito';font-size:12px;font-weight:800;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px}
        .inv-btn:active{transform:scale(0.96)}.inv-btn.sent{background:var(--surface2);color:var(--accent);border:1px solid rgba(6,214,160,0.3)}
        .phdr{text-align:center;padding:8px 0 18px}
        .aring{width:72px;height:72px;border-radius:50%;background:linear-gradient(135deg,var(--accent),var(--accent3));padding:3px;margin:0 auto 10px;animation:float 3s ease-in-out infinite}
        .ainner{width:100%;height:100%;border-radius:50%;background:var(--surface);display:flex;align-items:center;justify-content:center;font-size:30px}
        .pname{font-size:17px;font-weight:800}.ptag{font-family:'JetBrains Mono';font-size:9px;color:var(--accent);margin-top:2px;font-weight:600}
        .xpbar{background:var(--surface);border-radius:12px;padding:12px;border:1px solid var(--border);margin-bottom:12px}
        .xptop{display:flex;justify-content:space-between;align-items:baseline;margin-bottom:6px}
        .xplvl{font-family:'JetBrains Mono';font-size:15px;font-weight:800;color:var(--accent)}
        .xpnum{font-family:'JetBrains Mono';font-size:10px;color:var(--text3)}
        .xptrack{height:6px;background:var(--surface2);border-radius:4px;overflow:hidden}
        .xpfill{height:100%;border-radius:4px;background:linear-gradient(90deg,var(--accent),var(--accent3));background-size:200% 100%;animation:shimmer 3s linear infinite;transition:width 0.8s}
        .sgrid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:12px}
        .scard2{background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:12px;text-align:center}
        .sval{font-family:'JetBrains Mono';font-size:20px;font-weight:800}.slbl{font-size:9px;color:var(--text3);margin-top:2px;font-weight:600}
        .ptabs{display:flex;gap:3px;margin-bottom:12px;background:var(--surface);border-radius:10px;padding:3px;border:1px solid var(--border)}
        .ptab{flex:1;padding:6px;border-radius:7px;font-size:10px;font-weight:700;text-align:center;cursor:pointer;background:transparent;border:none;color:var(--text3);font-family:'Nunito'}
        .ptab.on{background:var(--surface3);color:var(--text)}
        .alog-item{display:flex;align-items:center;gap:10px;padding:9px 11px;background:var(--surface);border:1px solid var(--border);border-radius:10px;margin-bottom:5px;animation:slideDown 0.2s ease backwards}
        .alog-icon{width:30px;height:30px;border-radius:8px;background:var(--surface2);display:flex;align-items:center;justify-content:center;font-size:13px;flex-shrink:0}
        .alog-info{flex:1;min-width:0}.alog-title{font-size:11px;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .alog-time{font-size:8px;color:var(--text3);margin-top:1px;font-family:'JetBrains Mono'}.alog-pts{font-family:'JetBrains Mono';font-size:10px;font-weight:700;color:var(--accent)}
        .badges-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:6px}
        .badge-it{text-align:center;padding:10px 3px;background:var(--surface);border:1px solid var(--border);border-radius:11px}
        .badge-it.locked{opacity:0.25;filter:grayscale(1)}.badge-ic{font-size:20px;margin-bottom:2px}.badge-nm{font-size:7px;color:var(--text3);font-weight:700}
        .skill-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:7px}
        .sk-node{text-align:center;padding:10px 4px;background:var(--surface);border:1px solid var(--border);border-radius:11px;cursor:pointer;transition:all 0.25s}
        .sk-node.unlocked{border-color:rgba(6,214,160,0.3);background:rgba(6,214,160,0.04)}
        .sk-node.locked{opacity:0.35}.sk-node:active{transform:scale(0.95)}
        .sk-ic{font-size:20px;margin-bottom:3px}.sk-nm{font-size:8px;font-weight:700}
        .sk-cost{font-family:'JetBrains Mono';font-size:7px;margin-top:2px}
        .bnav{position:fixed;bottom:0;left:50%;transform:translateX(-50%);width:100%;max-width:430px;background:rgba(16,16,24,0.94);backdrop-filter:blur(20px);border-top:1px solid var(--border);display:flex;align-items:center;justify-content:space-around;padding:4px 2px 22px;z-index:100}
        .nitem{display:flex;flex-direction:column;align-items:center;gap:2px;cursor:pointer;padding:5px 8px;border-radius:10px;background:none;border:none;font-family:'Nunito'}
        .nitem svg{width:18px;height:18px;color:var(--text3);transition:color 0.2s}.nitem span{font-size:8px;font-weight:700;color:var(--text3);transition:color 0.2s}
        .nitem.on svg{color:var(--accent)}.nitem.on span{color:var(--accent)}
        .abtn{width:48px;height:48px;border-radius:14px;background:linear-gradient(135deg,var(--accent),var(--accent3));border:none;display:flex;align-items:center;justify-content:center;cursor:pointer;box-shadow:0 4px 20px rgba(6,214,160,0.25);transition:all 0.3s;margin-top:-20px}
        .abtn:active{transform:scale(0.88)}.abtn svg{width:22px;height:22px;color:var(--bg)}
        .modal-ov{position:fixed;inset:0;background:rgba(0,0,0,0.75);z-index:150;display:flex;align-items:flex-end;justify-content:center;animation:fadeIn 0.2s}
        .modal-sh{width:100%;max-width:430px;max-height:92vh;background:var(--bg);border-radius:20px 20px 0 0;padding:20px 20px 36px;animation:slideUp 0.3s ease;overflow-y:auto}
        .modal-h{width:36px;height:4px;border-radius:4px;background:var(--border);margin:0 auto 16px}
        .fg{margin-bottom:12px}
        .fl{font-size:9px;font-weight:700;color:var(--text3);text-transform:uppercase;letter-spacing:1.5px;margin-bottom:5px;display:block}
        .fi{width:100%;padding:10px 12px;background:var(--surface);border:1px solid var(--border);border-radius:10px;color:var(--text);font-family:'Nunito';font-size:13px;outline:none}
        .fi:focus{border-color:var(--accent)}.fi::placeholder{color:var(--text3)}textarea.fi{resize:none;min-height:60px}
        .cg{display:flex;flex-wrap:wrap;gap:5px}
        .c{padding:6px 12px;border-radius:9px;background:var(--surface);border:1px solid var(--border);color:var(--text2);font-size:11px;font-weight:600;cursor:pointer;font-family:'Nunito'}
        .c.sel{background:rgba(6,214,160,0.1);border-color:var(--accent);color:var(--accent)}
        .sub-btn{width:100%;padding:12px;border-radius:12px;background:linear-gradient(135deg,var(--accent),var(--accent3));border:none;color:var(--bg);font-family:'Nunito';font-size:13px;font-weight:800;cursor:pointer;margin-top:6px}
        .sub-btn:disabled{opacity:0.3;cursor:not-allowed}.sub-btn:active:not(:disabled){transform:scale(0.97)}
        .notif-panel{position:fixed;inset:0;width:100%;max-width:430px;margin:0 auto;background:var(--bg);z-index:200;animation:slideUp 0.3s;display:flex;flex-direction:column}
        .notif-hdr{display:flex;justify-content:space-between;align-items:center;padding:16px 20px;border-bottom:1px solid var(--border)}
        .notif-hdr h2{font-family:'JetBrains Mono';font-size:14px;font-weight:700}
        .n-btn{background:var(--surface);border:1px solid var(--border);color:var(--text2);border-radius:8px;padding:5px 10px;font-size:10px;cursor:pointer;font-family:'Nunito';font-weight:600}
        .n-btn.accent{color:var(--accent);border-color:rgba(6,214,160,0.3)}
        .notif-list{flex:1;overflow-y:auto;padding:10px 20px}
        .notif-item{padding:11px 13px;background:var(--surface);border-radius:11px;margin-bottom:7px;border:1px solid var(--border);animation:slideDown 0.2s ease backwards}
        .notif-item.unread{border-left:3px solid var(--accent);background:var(--surface2)}
        .notif-item p{font-size:12px;line-height:1.5}.notif-item .nt{font-size:9px;color:var(--text3);margin-top:3px;font-family:'JetBrains Mono'}
      `}</style>

      <div className="app">
        <ConfettiBurst show={confetti} />
        <XPFloat floats={xpFloats} />
        <AchievementToast toast={toast} onDone={() => setToast(null)} />
        <SpinWheel visible={showSpin} onClose={() => setShowSpin(false)} onResult={handleSpinResult} />
        <LootBox visible={showLoot} onClose={() => setShowLoot(false)} onOpen={(item) => { if (item.name.includes("XP")) setBonusXP(p => p + 150); if (item.name.includes("Shield")) setShields(p => p + 1); if (item.name.includes("Multiplier")) setMultiplier(3); triggerToast(item.icon, item.name, item.desc); }} />

        {/* HEADER */}
        <div className="hdr">
          <div className="hdr-l">
            <h1>QUESTLOG</h1>
            <p>{new Date().toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric" })}</p>
            <div className="hdr-xp"><div className="bar"><div className="fill" style={{ width: `${(xpInLevel / 200) * 100}%` }} /></div><span className="lbl">LVL {level}</span></div>
          </div>
          <div className="hdr-r">
            {!spinUsed && <button className="ic-btn" onClick={() => setShowSpin(true)} style={{ border: "1px solid rgba(255,190,11,0.3)", animation: "chest-glow 2s ease-in-out infinite" }}><span style={{ fontSize: 15 }}>🎰</span></button>}
            <button className="ic-btn" onClick={() => setShowNotif(true)}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.73 21a2 2 0 01-3.46 0" /></svg>
              {unread > 0 && <span className="nbadge">{unread}</span>}
            </button>
          </div>
        </div>

        {showNotif && <div className="notif-panel"><div className="notif-hdr"><h2>Notifications</h2><div style={{ display: "flex", gap: 6 }}><button className="n-btn accent" onClick={() => setNotifs(p => p.map(n => ({ ...n, read: true })))}>Mark read</button><button className="n-btn" onClick={() => setShowNotif(false)}>✕</button></div></div><div className="notif-list">{notifs.map((n, i) => <div key={n.id} className={`notif-item ${!n.read ? "unread" : ""}`} style={{ animationDelay: `${i * 0.04}s` }}><p>{n.text}</p><div className="nt">{n.time}</div></div>)}</div></div>}

        <div className="page">
          {/* ═══ TASKS ═══ */}
          {tab === "tasks" && <>
            <div className="rank-b">
              <div className="ri">{currentRank.icon}</div>
              <div style={{ flex: 1 }}>
                <div className="rn" style={{ color: currentRank.color }}>{currentRank.name}</div>
                <div className="rp">{nextRank ? `${nextRank.min - totalXP} XP to ${nextRank.name}` : "Max rank!"}</div>
                {nextRank && <div className="rb"><div className="f" style={{ width: `${((totalXP - currentRank.min) / (nextRank.min - currentRank.min)) * 100}%`, background: currentRank.color }} /></div>}
              </div>
            </div>
            <div className="compact-row">
              <div className="cc daily">
                <div className="cc-ring"><svg width="30" height="30" viewBox="0 0 30 30"><circle cx="15" cy="15" r="11" fill="none" stroke="var(--surface3)" strokeWidth="3" /><circle cx="15" cy="15" r="11" fill="none" stroke="var(--accent)" strokeWidth="3" strokeDasharray={`${(Math.min(dailyDone, dailyGoal) / dailyGoal) * 69.1} 69.1`} strokeDashoffset="17.3" strokeLinecap="round" style={{ transition: "stroke-dasharray 0.8s" }} /></svg><div className="cc-num">{dailyDone}/{dailyGoal}</div></div>
                <div><div className="cc-t">Daily Goal</div><div className="cc-s">{dailyDone >= dailyGoal ? "Done! 🎉" : `${dailyGoal - dailyDone} left`}</div></div>
              </div>
              <div className="cc streak">
                <div className="cc-fire">🔥</div>
                <div><div className="cc-t" style={{ color: "var(--warn)" }}>30 Days</div><div className="cc-s">{shields > 0 ? `🛡️ ${shields} shield${shields > 1 ? "s" : ""}` : "Keep going!"}</div></div>
              </div>
            </div>
            <div className="pet-w">
              <div className="pe" style={{ fontSize: pet.size }}>{pet.emoji}</div>
              <div className="pi">
                <div className="pn">{pet.name} <span style={{ fontSize: 8, color: "var(--text3)" }}>— {(() => { const next = PET_STAGES.find(p => p.minTasks > totalLifetimeTasks); return next ? `${next.minTasks - totalLifetimeTasks} to ${next.emoji}` : "Max!"; })()}</span></div>
                <div className="pb"><div className="f" style={{ width: `${(() => { const next = PET_STAGES.find(p => p.minTasks > totalLifetimeTasks); const prevMin = pet.minTasks; const nextMin = next ? next.minTasks : pet.minTasks + 50; return ((totalLifetimeTasks - prevMin) / (nextMin - prevMin)) * 100; })()}%` }} /></div>
              </div>
            </div>
            {combo >= 2 && <div className="combo-b"><div className="cf">🔥</div><div style={{ flex: 1 }}><div className="ct">{combo}× COMBO!</div><div className="cs">Keep going!</div></div><div className="cm">{comboMulti}×</div></div>}
            {multiplier > 1 && <div className="multi-ind"><span>✨</span> {multiplier}× Multiplier Active <span style={{ fontSize: 8, color: "var(--text3)", marginLeft: "auto" }}>Next task</span></div>}
            <div className="chal">
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 6 }}>
                <div className="stitle" style={{ margin: 0 }}>📜 Daily Challenges</div>
                <span style={{ fontFamily: "'JetBrains Mono'", fontSize: 8, color: "var(--accent)", fontWeight: 700 }}>{dailyChallenges.filter(c => c.done).length}/{dailyChallenges.length}</span>
              </div>
              {dailyChallenges.map(ch => <div key={ch.id} className={`ch-c ${ch.done ? "done" : ""}`}><div className="ci">{ch.icon}</div><div style={{ flex: 1 }}><div className="cn">{ch.title}</div><div className="cd">{ch.desc}</div></div><div className="cr">{ch.done ? "✅" : `+${ch.reward}`}</div></div>)}
            </div>
            <div className="boss-c">
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
                <div className="stitle" style={{ margin: 0 }}>⚔️ Weekly Boss</div>
                <span style={{ fontFamily: "'JetBrains Mono'", fontSize: 9, color: "var(--danger)", fontWeight: 700 }}>+{boss.reward} XP</span>
              </div>
              <div className="be" style={{ animation: boss.hp > 0 ? "boss-idle 2s ease-in-out infinite" : "none", filter: boss.hp <= 0 ? "grayscale(1)" : "none", opacity: boss.hp <= 0 ? 0.4 : 1 }}>{boss.emoji}</div>
              <div className="bn">{boss.name}</div>
              {boss.hp <= 0 && <div className="bd">🎉 DEFEATED!</div>}
              <div style={{ margin: "10px 0 6px", display: "flex", justifyContent: "space-between" }}><span style={{ fontSize: 9, fontWeight: 700, color: "var(--text3)" }}>HP</span><span style={{ fontFamily: "'JetBrains Mono'", fontSize: 9, fontWeight: 700, color: bossHpPct > 50 ? "var(--danger)" : bossHpPct > 25 ? "var(--orange)" : "var(--accent)" }}>{Math.max(0, boss.hp)}/{boss.maxHp}</span></div>
              <div style={{ height: 8, background: "var(--surface3)", borderRadius: 5, overflow: "hidden" }}><div style={{ height: "100%", width: `${bossHpPct}%`, background: `linear-gradient(90deg, var(--accent), ${bossHpPct > 50 ? "var(--danger)" : "var(--orange)"})`, borderRadius: 5, transition: "width 0.6s" }} /></div>
              <div style={{ fontSize: 9, color: "var(--text3)", textAlign: "center", marginTop: 6 }}><span style={{ fontFamily: "'JetBrains Mono'", color: "var(--warn)", fontWeight: 700 }}>{boss.tasksDone}</span>/{boss.tasksNeeded} tasks · <span style={{ fontFamily: "'JetBrains Mono'", color: "var(--danger)", fontWeight: 700 }}>{Math.round(boss.maxHp / boss.tasksNeeded)}</span> DMG each</div>
            </div>
            <div className="cnt"><span className="l">{tasks.filter(t => t.done).length}/{tasks.length} DONE</span><span className="r">+<AnimNum value={totalXP} /> XP</span></div>
            <div className="px">
              {tasks.map((task, i) => (
                <div key={task.id} className={`tcard ${task.priority === "high" ? "hi" : task.priority === "medium" ? "md" : "lo"} ${task.done ? "done" : ""}`} style={{ animationDelay: `${i * 0.04}s` }}>
                  <div className="ttop">
                    <div className={`chk ${task.done ? "on" : ""}`} onClick={() => toggleTask(task.id)}><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3" strokeLinecap="round"><polyline points="20 6 9 17 4 12" /></svg></div>
                    <div className="tinfo">
                      <div className="ttitle">{task.title}</div>
                      <div className="tmeta">
                        <span className="chip">🕐 {task.time}</span>
                        <span className="chip pts">⚡ {task.points}{effectiveMulti > 1 && !task.done ? `×${effectiveMulti}` : ""}</span>
                        <span className="chip proj">📁 {task.project}</span>
                        <span className="chip strk">🔥 {task.streak}d</span>
                      </div>
                    </div>
                    <button className="nbtn" onClick={() => setOpenDesc(openDesc === task.id ? null : task.id)}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" /><polyline points="14 2 14 8 20 8" /></svg></button>
                  </div>
                  {openDesc === task.id && <div className="tdesc">{task.desc}</div>}
                </div>
              ))}
            </div>
          </>}

          {/* ═══ STATS ═══ */}
          {tab === "stats" && <div className="px">
            <div className="stabs">{["overview", "heatmap", "trends", "skills"].map(t => <button key={t} className={`stab ${statsTab === t ? "on" : ""}`} onClick={() => setStatsTab(t)}>{t === "overview" ? "Overview" : t === "heatmap" ? "Heatmap" : t === "trends" ? "Trends" : "Skills"}</button>)}</div>
            {statsTab === "overview" && <>
              <div className="scard"><div className="stitle">Completion Rates</div><div style={{ display: "flex", justifyContent: "space-around" }}><Gauge value={78} max={100} label="DAILY" color="var(--accent)" /><Gauge value={85} max={100} label="WEEKLY" color="var(--accent3)" /><Gauge value={62} max={100} label="MONTH" color="var(--accent2)" /></div></div>
              <div className="scard"><div className="stitle">Category Breakdown</div><div style={{ display: "flex", alignItems: "center", gap: 14 }}><DonutChart data={CATEGORY_DATA} /><div style={{ flex: 1 }}>{CATEGORY_DATA.map(c => <div key={c.name} style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 7 }}><div style={{ width: 7, height: 7, borderRadius: 2, background: c.color }} /><span style={{ fontSize: 10, fontWeight: 600, flex: 1 }}>{c.name}</span><span style={{ fontSize: 10, fontFamily: "'JetBrains Mono'", fontWeight: 700, color: c.color }}>{c.value}%</span></div>)}</div></div></div>
              <div className="scard"><div className="stitle">Projects</div><div className="bars">{PROJECT_STATS.map((p, i) => <div className="brow" key={p.name}><div className="blbl">{p.name}</div><div className="btrack"><div className="bfill" style={{ width: `${(p.completed / p.total) * 100}%`, background: p.color, transitionDelay: `${i * 0.1}s` }}>{p.completed}/{p.total}</div></div></div>)}</div></div>
            </>}
            {statsTab === "heatmap" && <>
              <div className="scard"><div className="stitle">Activity — 12 Weeks</div><div style={{ overflowX: "auto" }}><HeatmapGrid data={heatmap} /></div><div style={{ display: "flex", alignItems: "center", gap: 3, marginTop: 6, justifyContent: "flex-end" }}><span style={{ fontSize: 7, color: "var(--text3)", fontFamily: "'JetBrains Mono'" }}>Less</span>{[0.03, 0.15, 0.35, 0.6, 0.9].map((o, i) => <div key={i} style={{ width: 9, height: 9, borderRadius: 2, background: `rgba(6,214,160,${o})` }} />)}<span style={{ fontSize: 7, color: "var(--text3)", fontFamily: "'JetBrains Mono'" }}>More</span></div></div>
              <div className="scard"><div className="stitle">Weekly XP</div><Sparkline data={WEEKLY_XP} /><div style={{ display: "flex", justifyContent: "space-between", marginTop: 4 }}>{WEEKLY_XP.map(d => <span key={d.day} style={{ fontSize: 8, color: "var(--text3)", fontFamily: "'JetBrains Mono'", fontWeight: 600 }}>{d.day}</span>)}</div></div>
            </>}
            {statsTab === "trends" && <>
              <div className="scard"><div className="stitle">Productivity by Hour</div><div style={{ display: "flex", alignItems: "flex-end", gap: 2, height: 65 }}>{HOURLY_DATA.map((h, i) => { const mx = Math.max(...HOURLY_DATA.map(d => d.v)); return <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: 2 }}><div style={{ width: "100%", borderRadius: "3px 3px 1px 1px", background: h.v >= 7 ? "var(--accent)" : h.v >= 4 ? "var(--accent3)" : "var(--surface3)", height: `${(h.v / mx) * 100}%`, transition: `height 0.8s ease ${i * 0.03}s`, minHeight: 2 }} /><div style={{ fontSize: 6, color: "var(--text3)", fontFamily: "'JetBrains Mono'" }}>{h.h}</div></div>; })}</div></div>
              <div className="scard"><div className="stitle">Best Days</div><div className="bars">{[{ d: "Mon", v: 8 }, { d: "Tue", v: 10 }, { d: "Wed", v: 6 }, { d: "Thu", v: 12 }, { d: "Fri", v: 9 }, { d: "Sat", v: 4 }, { d: "Sun", v: 7 }].map((item, i) => <div className="brow" key={item.d}><div className="blbl">{item.d}</div><div className="btrack"><div className="bfill" style={{ width: `${(item.v / 12) * 100}%`, background: item.v >= 10 ? "var(--warn)" : item.v >= 7 ? "var(--accent)" : "var(--surface3)", transitionDelay: `${i * 0.08}s` }}>{item.v}</div></div></div>)}</div></div>
            </>}
            {statsTab === "skills" && <>
              <div className="scard">
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}><div className="stitle" style={{ margin: 0 }}>🌳 Skill Tree</div><div style={{ fontFamily: "'JetBrains Mono'", fontSize: 10, fontWeight: 700, color: "var(--warn)" }}>⭐ {skillPoints} SP</div></div>
                <div className="skill-grid">{skillTree.map(s => <div key={s.id} className={`sk-node ${s.unlocked ? "unlocked" : "locked"}`} onClick={() => !s.unlocked && unlockSkill(s.id)}><div className="sk-ic">{s.icon}</div><div className="sk-nm">{s.name}</div><div className="sk-cost" style={{ color: s.unlocked ? "var(--accent)" : skillPoints >= s.cost ? "var(--warn)" : "var(--text3)" }}>{s.unlocked ? "✓" : `${s.cost} SP`}</div></div>)}</div>
              </div>
              <div className="scard">
                <div className="stitle">Rank Tiers</div>
                <div style={{ display: "flex", gap: 5 }}>{RANK_TIERS.map(r => <div key={r.name} style={{ flex: 1, textAlign: "center", padding: "8px 3px", background: totalXP >= r.min ? "var(--surface2)" : "var(--surface)", borderRadius: 9, border: `1px solid ${totalXP >= r.min ? `${r.color}40` : "var(--border)"}`, opacity: totalXP >= r.min ? 1 : 0.3 }}><div style={{ fontSize: 16 }}>{r.icon}</div><div style={{ fontSize: 7, fontWeight: 700, marginTop: 3, color: totalXP >= r.min ? r.color : "var(--text3)" }}>{r.name}</div><div style={{ fontSize: 6, fontFamily: "'JetBrains Mono'", color: "var(--text3)", marginTop: 1 }}>{r.min}+</div></div>)}</div>
              </div>
            </>}
          </div>}

          {/* ═══ LEADERBOARD ═══ */}
          {tab === "leaderboard" && <div className="px">
            <div className="scard" style={{ marginBottom: 12 }}><div style={{ display: "flex", alignItems: "flex-end", justifyContent: "center", gap: 5, padding: "6px 0 0" }}>{[1, 0, 2].map(idx => { const u = LEADERBOARD[idx]; const h = idx === 0 ? 65 : idx === 1 ? 46 : 32; const c = idx === 0 ? "rgba(255,215,0,0.1)" : idx === 1 ? "rgba(170,170,170,0.1)" : "rgba(205,127,50,0.1)"; return <div key={u.name} style={{ textAlign: "center", flex: 1 }}>{idx === 0 && <div style={{ fontSize: 9 }}>👑</div>}<div style={{ fontSize: idx === 0 ? 30 : 24 }}>{u.avatar}</div><div style={{ fontSize: 9, fontWeight: 800, marginTop: 2 }}>{u.name}</div><div style={{ fontFamily: "'JetBrains Mono'", fontSize: 8, color: "var(--accent)", fontWeight: 700 }}>{u.xp}</div><div style={{ height: h, background: c, borderRadius: "7px 7px 0 0", marginTop: 4, display: "flex", alignItems: "center", justifyContent: "center" }}><span style={{ fontFamily: "'JetBrains Mono'", fontSize: idx === 0 ? 18 : 14, fontWeight: 800, color: idx === 0 ? "var(--warn)" : idx === 1 ? "#aaa" : "#cd7f32" }}>{idx + 1}</span></div></div>; })}</div></div>
            <div className="lb-filters">{["weekly", "monthly", "all-time"].map(f => <button key={f} className={`lb-f ${lbFilter === f ? "on" : ""}`} onClick={() => setLbFilter(f)}>{f === "weekly" ? "Weekly" : f === "monthly" ? "Monthly" : "All Time"}</button>)}</div>
            {LEADERBOARD.map((u, i) => <div key={u.name} className={`lbcard ${u.name === "You" ? "you" : ""}`} style={{ animationDelay: `${i * 0.05}s` }}><div className={`lbrank ${i === 0 ? "g" : i === 1 ? "s" : i === 2 ? "b" : ""}`}>#{i + 1}</div><div className="lbav">{u.avatar}</div><div className="lbinfo"><div className="lbname">{u.name}</div><div className="lbxp">{u.xp.toLocaleString()} XP</div><div className="lbmeta"><span>🔥 {u.streak}d</span><span>📋 {u.tasksWeek}/wk</span></div></div>{u.name !== "You" ? <button className={`ch-btn ${challengeSent === u.name ? "sent" : ""}`} onClick={() => setChallengeSent(u.name)}>{challengeSent === u.name ? "✓" : "⚔️"}</button> : <div style={{ fontFamily: "'JetBrains Mono'", fontSize: 9, color: "var(--accent2)", fontWeight: 700 }}>LV.{u.level}</div>}</div>)}
            <div style={{ marginTop: 12 }}><button className={`inv-btn ${inviteSent ? "sent" : ""}`} onClick={() => setInviteSent(true)}>{inviteSent ? "✓ Link Copied!" : "👋 Invite Friends"}</button></div>
          </div>}

          {/* ═══ PROFILE ═══ */}
          {tab === "profile" && <div className="px">
            <div className="phdr"><div className="aring"><div className="ainner">🧑‍💻</div></div><div className="pname">Alex Chen</div><div className="ptag">{currentRank.icon} {currentRank.name} · @questmaster</div></div>
            <div className="xpbar"><div className="xptop"><span className="xplvl">Level {level}</span><span className="xpnum">{xpInLevel}/200 XP</span></div><div className="xptrack"><div className="xpfill" style={{ width: `${(xpInLevel / 200) * 100}%` }} /></div></div>
            <div className="sgrid">
              <div className="scard2"><div className="sval" style={{ color: "var(--accent)" }}><AnimNum value={totalXP} /></div><div className="slbl">Total XP</div></div>
              <div className="scard2"><div className="sval" style={{ color: "var(--accent3)" }}><AnimNum value={totalLifetimeTasks} /></div><div className="slbl">Tasks</div></div>
              <div className="scard2"><div className="sval" style={{ color: "var(--warn)" }}>30</div><div className="slbl">Streak</div></div>
              <div className="scard2"><div className="sval" style={{ color: "var(--accent2)" }}>#1</div><div className="slbl">Rank</div></div>
            </div>
            <div style={{ textAlign: "center", padding: 14, background: "var(--surface)", borderRadius: 12, border: "1px solid var(--border)", marginBottom: 12 }}>
              <div style={{ fontSize: 44, animation: "pet-bounce 2s ease-in-out infinite" }}>{pet.emoji}</div>
              <div style={{ fontWeight: 800, marginTop: 4, fontSize: 14 }}>{pet.name}</div>
            </div>
            <div className="ptabs">{["activity", "badges", "milestones"].map(t => <button key={t} className={`ptab ${profileTab === t ? "on" : ""}`} onClick={() => setProfileTab(t)}>{t.charAt(0).toUpperCase() + t.slice(1)}</button>)}</div>
            {profileTab === "activity" && activityLog.map((a, i) => <div key={i} className="alog-item" style={{ animationDelay: `${i * 0.03}s` }}><div className="alog-icon">{a.icon}</div><div className="alog-info"><div className="alog-title">{a.task}</div><div className="alog-time">{a.time}</div></div><div className="alog-pts">+{a.points}</div></div>)}
            {profileTab === "badges" && <><div className="stitle">Badges ({BADGES.filter(b => b.unlocked).length}/{BADGES.length})</div><div className="badges-grid">{BADGES.map(b => <div key={b.name} className={`badge-it ${!b.unlocked ? "locked" : ""}`}><div className="badge-ic">{b.icon}</div><div className="badge-nm">{b.name}</div></div>)}</div></>}
            {profileTab === "milestones" && <><div className="stitle">Milestones</div>{[{ t: "First Quest", i: "🌱", d: true, dt: "Jan 5" }, { t: "Week Warrior", i: "⚔️", d: true, dt: "Jan 12" }, { t: "Century Club", i: "💯", d: true, dt: "Feb 3" }, { t: "XP Master", i: "⚡", d: true, dt: "Feb 18" }, { t: "Month Monarch", i: "👑", d: true, dt: "Mar 1" }, { t: "Dragon Tamer", i: "🐲", d: false }, { t: "Legendary", i: "🏰", d: false }].map((m, i) => <div key={m.t} style={{ display: "flex", alignItems: "center", gap: 10, padding: 11, background: "var(--surface)", border: "1px solid var(--border)", borderRadius: 10, marginBottom: 5, opacity: m.d ? 1 : 0.3, animation: "slideDown 0.2s ease backwards", animationDelay: `${i * 0.04}s` }}><div style={{ fontSize: 18 }}>{m.i}</div><div style={{ flex: 1, fontSize: 11, fontWeight: 700 }}>{m.t}</div><div style={{ fontSize: 9, fontFamily: "'JetBrains Mono'", color: m.d ? "var(--accent)" : "var(--text3)", fontWeight: 700 }}>{m.d ? m.dt : "🔒"}</div></div>)}</>}
          </div>}
        </div>

        {/* ADD TASK MODAL */}
        {showAdd && <div className="modal-ov" onClick={e => { if (e.target === e.currentTarget) setShowAdd(false); }}><div className="modal-sh"><div className="modal-h" /><div style={{ fontFamily: "'JetBrains Mono'", fontSize: 14, fontWeight: 700, marginBottom: 16 }}>⚔️ New Quest</div>
          <div className="fg"><label className="fl">Title</label><input className="fi" placeholder="What's the quest?" value={newTask.title} onChange={e => setNewTask(p => ({ ...p, title: e.target.value }))} /></div>
          <div className="fg"><label className="fl">Description</label><textarea className="fi" placeholder="Describe..." value={newTask.desc} onChange={e => setNewTask(p => ({ ...p, desc: e.target.value }))} /></div>
          <div className="fg"><label className="fl">Category</label><div className="cg">{["Work", "Health", "Learning", "Personal"].map(c => <button key={c} className={`c ${newTask.category === c ? "sel" : ""}`} onClick={() => setNewTask(p => ({ ...p, category: c }))}>{c === "Work" ? "💼" : c === "Health" ? "💪" : c === "Learning" ? "📚" : "🏠"} {c}</button>)}</div></div>
          <div className="fg"><label className="fl">Frequency</label><div className="cg">{["Daily", "Weekly", "Monthly", "Once"].map(f => <button key={f} className={`c ${newTask.frequency === f ? "sel" : ""}`} onClick={() => setNewTask(p => ({ ...p, frequency: f }))}>{f}</button>)}</div></div>
          <div className="fg"><label className="fl">Schedule</label><input type="time" className="fi" value={newTask.time} onChange={e => setNewTask(p => ({ ...p, time: e.target.value }))} style={{ colorScheme: "dark" }} /></div>
          <div className="fg"><label className="fl">Priority</label><div className="cg">{[{ v: "high", l: "🔴 High", c: "var(--danger)" }, { v: "medium", l: "🟡 Med", c: "var(--warn)" }, { v: "low", l: "🟢 Low", c: "var(--accent)" }].map(p => <button key={p.v} className={`c ${newTask.priority === p.v ? "sel" : ""}`} onClick={() => setNewTask(pr => ({ ...pr, priority: p.v }))} style={newTask.priority === p.v ? { borderColor: p.c, color: p.c } : {}}>{p.l}</button>)}</div></div>
          <button className="sub-btn" disabled={!newTask.title.trim()} onClick={addTask}>⚡ Create — {newTask.priority === "high" ? 80 : newTask.priority === "medium" ? 50 : 25} XP</button>
        </div></div>}

        {/* BOTTOM NAV */}
        <div className="bnav">
          <button className={`nitem ${tab === "tasks" ? "on" : ""}`} onClick={() => setTab("tasks")}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M9 11l3 3L22 4" /><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11" /></svg><span>Quests</span></button>
          <button className={`nitem ${tab === "stats" ? "on" : ""}`} onClick={() => setTab("stats")}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><line x1="18" y1="20" x2="18" y2="10" /><line x1="12" y1="20" x2="12" y2="4" /><line x1="6" y1="20" x2="6" y2="14" /></svg><span>Stats</span></button>
          <button className="abtn" onClick={() => setShowAdd(true)}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" /></svg></button>
          <button className={`nitem ${tab === "leaderboard" ? "on" : ""}`} onClick={() => setTab("leaderboard")}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><rect x="6" y="6" width="4" height="16" rx="1" /><rect x="14" y="10" width="4" height="12" rx="1" /><rect x="10" y="2" width="4" height="20" rx="1" /></svg><span>Ranks</span></button>
          <button className={`nitem ${tab === "profile" ? "on" : ""}`} onClick={() => setTab("profile")}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" /><circle cx="12" cy="7" r="4" /></svg><span>Profile</span></button>
        </div>
      </div>
    </>
  );
}
