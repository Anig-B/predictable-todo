import { useState, useEffect, useMemo, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";

/* ═══════════════════════════════════════════════════
   GLOBAL STYLES — animations, tokens, utility classes
══════════════════════════════════════════════════════ */
const GLOBAL_CSS = `
  @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600;700;800&family=Nunito:wght@400;600;700;800;900&display=swap');

  /* ── Design Tokens ───────────────────────────────── */
  :root {
    --bg:        #08080e;
    --surface:   #101018;
    --surface2:  #181824;
    --surface3:  #20202e;
    --border:    #252538;
    --text:      #e8e8f0;
    --muted:     #8888a8;
    --subtle:    #555570;
    --accent:    #06d6a0;
    --purple:    #8338ec;
    --blue:      #3a86ff;
    --gold:      #ffbe0b;
    --red:       #ff006e;
    --orange:    #fb5607;
    --mono:      'JetBrains Mono', monospace;
    --sans:      'Nunito', sans-serif;
    --radius-sm: 6px;
    --radius:    11px;
    --radius-lg: 14px;
    --shadow-glow-green: 0 0 18px rgba(6,214,160,0.25);
    --shadow-glow-red:   0 0 18px rgba(255,0,110,0.25);
    --shadow-glow-gold:  0 0 18px rgba(255,190,11,0.25);
  }

  /* ── Reset ───────────────────────────────────────── */
  *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
  body { background: var(--bg); font-family: var(--sans); color: var(--text); }

  /* ── Keyframe Library ────────────────────────────── */
  @keyframes fadeIn           { from { opacity:0 } to { opacity:1 } }
  @keyframes fadeUp           { from { opacity:0; transform:translateY(12px) } to { opacity:1; transform:translateY(0) } }
  @keyframes slideUp          { from { opacity:0; transform:translateY(100%) } to { opacity:1; transform:translateY(0) } }
  @keyframes slideDown        { from { opacity:0; transform:translateY(-12px) } to { opacity:1; transform:translateY(0) } }
  @keyframes scaleIn          { from { opacity:0; transform:scale(0.92) } to { opacity:1; transform:scale(1) } }
  @keyframes scalePop         { 0%{transform:scale(0.4)} 60%{transform:scale(1.22)} 100%{transform:scale(1)} }
  @keyframes float            { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-7px)} }
  @keyframes bobble           { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-4px)} }
  @keyframes pulse-scale      { 0%,100%{transform:scale(1)} 50%{transform:scale(1.04)} }
  @keyframes pulse-badge      { 0%,100%{transform:scale(1)} 50%{transform:scale(1.14)} }
  @keyframes spin-slow        { from{transform:rotate(0deg)} to{transform:rotate(360deg)} }
  @keyframes shimmer          { 0%{background-position:-200% 0} 100%{background-position:200% 0} }
  @keyframes xp-rise          { 0%{opacity:1;transform:translateY(0) scale(1)} 100%{opacity:0;transform:translateY(-80px) scale(1.35)} }
  @keyframes toast-enter      { 0%{opacity:0;transform:translateX(-50%) translateY(-16px) scale(0.9)} 100%{opacity:1;transform:translateX(-50%) translateY(0) scale(1)} }
  @keyframes confetti-pop     { 0%{opacity:1;transform:translate(0,0) rotate(0deg)} 100%{opacity:0;transform:translate(var(--tx),var(--ty)) rotate(var(--tr))} }
  @keyframes boss-idle        { 0%,100%{transform:translateY(0) scale(1)} 50%{transform:translateY(-6px) scale(1.03)} }
  @keyframes chest-glow       { 0%,100%{filter:drop-shadow(0 0 6px rgba(255,190,11,0.3));transform:scale(1)} 50%{filter:drop-shadow(0 0 18px rgba(255,190,11,0.6));transform:scale(1.04)} }
  @keyframes loot-spin        { 0%{opacity:0;transform:scale(0) rotate(-180deg)} 60%{transform:scale(1.18) rotate(8deg)} 100%{opacity:1;transform:scale(1) rotate(0deg)} }
  @keyframes cam-pulse-ring   { 0%,100%{box-shadow:0 0 0 0 rgba(6,214,160,0.5); border-color:rgba(6,214,160,0.25)} 50%{box-shadow:0 0 0 5px rgba(6,214,160,0); border-color:rgba(6,214,160,0.85)} }
  @keyframes glow-border-red  { 0%,100%{border-color:rgba(255,0,110,0.12)} 50%{border-color:rgba(255,0,110,0.3)} }

  /* ── Animation Utility Classes ───────────────────── */
  .anim-fadeIn          { animation: fadeIn 0.3s ease both; }
  .anim-fadeUp          { animation: fadeUp 0.35s ease both; }
  .anim-slideUp         { animation: slideUp 0.3s cubic-bezier(0.32,0.72,0,1) both; }
  .anim-slideDown       { animation: slideDown 0.25s ease both; }
  .anim-scaleIn         { animation: scaleIn 0.25s ease both; }
  .anim-scalePop        { animation: scalePop 0.35s ease both; }
  .anim-float           { animation: float 3s ease-in-out infinite; }
  .anim-bobble          { animation: bobble 2s ease-in-out infinite; }
  .anim-pulse-scale     { animation: pulse-scale 1.6s ease-in-out infinite; }
  .anim-boss-idle       { animation: boss-idle 2s ease-in-out infinite; }
  .anim-chest           { animation: chest-glow 2s ease-in-out infinite; }
  .anim-cam             { animation: cam-pulse-ring 2.5s ease-in-out infinite; }
  .anim-glow-border-red { animation: glow-border-red 2s ease-in-out infinite; }
  .anim-shimmer         { background: linear-gradient(90deg,var(--accent),var(--blue),var(--accent)); background-size:200% 100%; animation: shimmer 3s linear infinite; }

  /* ── Stagger helpers ─────────────────────────────── */
  .stagger > *:nth-child(1) { animation-delay: 0.03s }
  .stagger > *:nth-child(2) { animation-delay: 0.06s }
  .stagger > *:nth-child(3) { animation-delay: 0.09s }
  .stagger > *:nth-child(4) { animation-delay: 0.12s }
  .stagger > *:nth-child(5) { animation-delay: 0.15s }
  .stagger > *:nth-child(6) { animation-delay: 0.18s }
  .stagger > *:nth-child(7) { animation-delay: 0.21s }
  .stagger > *:nth-child(8) { animation-delay: 0.24s }

  /* ── Layout ──────────────────────────────────────── */
  .app              { max-width:430px; min-height:100dvh; margin:0 auto; background:var(--bg); position:relative; overflow-x:hidden; }
  .page-content     { padding: 0 0 130px; }
  .px               { padding: 0 16px; }
  .gap-col          { display:flex; flex-direction:column; gap:8px; }
  .gap-row          { display:flex; align-items:center; gap:8px; }
  .fill             { flex:1; min-width:0; }

  /* ── Header ──────────────────────────────────────── */
  .hdr {
    padding: 14px 16px 8px;
    display: flex; justify-content: space-between; align-items: flex-start;
    position: sticky; top: 0; z-index: 50;
    background: linear-gradient(to bottom, var(--bg) 68%, transparent);
    backdrop-filter: blur(18px);
  }
  .hdr-brand {
    font-family: var(--mono); font-size: 20px; font-weight: 800;
    background: linear-gradient(135deg, var(--accent), var(--blue));
    -webkit-background-clip: text; -webkit-text-fill-color: transparent;
    letter-spacing: -0.5px;
  }
  .hdr-date        { font-size: 10px; color: var(--subtle); margin-top: 1px; font-family: var(--mono); }
  .hdr-lvl-row     { display:flex; align-items:center; gap:6px; margin-top:5px; }
  .hdr-lvl-bar     { width:96px; height:3px; background:var(--surface3); border-radius:4px; overflow:hidden; }
  .hdr-lvl-fill    { height:100%; border-radius:4px; background:linear-gradient(90deg,var(--accent),var(--blue)); transition:width 0.6s ease; }
  .hdr-lvl-lbl     { font-family:var(--mono); font-size:9px; color:var(--accent); font-weight:700; }
  .hdr-actions     { display:flex; gap:7px; align-items:center; }

  /* ── Icon Button ─────────────────────────────────── */
  .icon-btn {
    width:38px; height:38px; border-radius:var(--radius);
    background:var(--surface); border:1px solid var(--border);
    display:flex; align-items:center; justify-content:center;
    cursor:pointer; transition:all 0.2s; position:relative; flex-shrink:0;
  }
  .icon-btn:active  { transform:scale(0.88); }
  .icon-btn svg     { width:16px; height:16px; color:var(--muted); }
  .icon-btn.accent-border { border-color: rgba(131,56,236,0.35); }
  .icon-btn.gold-border   { border-color: rgba(255,190,11,0.35); }

  .notif-dot {
    position:absolute; top:-3px; right:-3px;
    min-width:15px; height:15px; border-radius:8px;
    background:var(--red); color:#fff;
    font-size:8px; font-weight:800; display:flex; align-items:center; justify-content:center;
    padding:0 3px; font-family:var(--mono); animation: pulse-badge 2s infinite;
  }

  /* ── Notification / Challenge Panel ─────────────── */
  .panel {
    position:fixed; inset:0; max-width:430px; margin:0 auto;
    background:var(--bg); z-index:200;
    display:flex; flex-direction:column;
  }
  .panel-hdr {
    display:flex; justify-content:space-between; align-items:center;
    padding:16px; border-bottom:1px solid var(--border);
  }
  .panel-title   { font-family:var(--mono); font-size:14px; font-weight:700; }
  .panel-body    { flex:1; overflow-y:auto; padding:12px 16px; }

  /* ── Notif Items ─────────────────────────────────── */
  .notif-item       { padding:11px 13px; background:var(--surface); border-radius:var(--radius); margin-bottom:6px; border:1px solid var(--border); }
  .notif-item.unread { border-left:3px solid var(--accent); background:var(--surface2); }
  .notif-text       { font-size:12px; line-height:1.55; }
  .notif-time       { font-size:9px; color:var(--subtle); margin-top:3px; font-family:var(--mono); }

  /* ── Task Cards ──────────────────────────────────── */
  .task-card {
    background:var(--surface); border:1px solid var(--border);
    border-radius:13px; padding:11px 11px 11px 15px;
    margin-bottom:7px; transition:all 0.25s;
    position:relative; overflow:hidden;
  }
  .task-card::after {
    content:''; position:absolute; top:6px; left:0;
    width:3px; height:calc(100% - 12px); border-radius:0 3px 3px 0;
  }
  .task-card.pri-high::after   { background: var(--red); }
  .task-card.pri-medium::after { background: var(--gold); }
  .task-card.pri-low::after    { background: var(--accent); }
  .task-card.is-done           { opacity: 0.4; }
  .task-card.is-done .task-title { text-decoration: line-through; color: var(--muted); }

  .task-row      { display:flex; align-items:flex-start; gap:9px; }
  .task-check {
    width:22px; height:22px; border-radius:6px; border:2px solid var(--border);
    display:flex; align-items:center; justify-content:center;
    cursor:pointer; transition:all 0.2s; flex-shrink:0; margin-top:2px;
  }
  .task-check:active               { transform:scale(0.85); }
  .task-check.checked              { background:linear-gradient(135deg,var(--accent),var(--blue)); border-color:transparent; animation:scalePop 0.32s ease; }
  .task-check.checked svg          { opacity:1; }
  .task-check svg                  { opacity:0; transition:opacity 0.15s; }
  .task-title    { font-weight:700; font-size:12px; line-height:1.3; margin-bottom:5px; }
  .task-meta     { display:flex; flex-wrap:wrap; gap:4px; }

  /* ── Chips / Badges ──────────────────────────────── */
  .chip          { display:inline-flex; align-items:center; gap:2px; padding:2px 6px; border-radius:5px; font-size:9px; font-weight:600; white-space:nowrap; }
  .chip-default  { background:var(--surface2); color:var(--muted); }
  .chip-xp       { background:rgba(6,214,160,0.1); color:var(--accent); font-family:var(--mono); font-weight:700; }
  .chip-streak   { background:rgba(255,190,11,0.1); color:var(--gold); }
  .chip-project  { background:rgba(131,56,236,0.1); color:var(--purple); }

  .task-expand-btn {
    width:28px; height:28px; border-radius:7px;
    background:var(--surface2); border:1px solid var(--border);
    display:flex; align-items:center; justify-content:center;
    cursor:pointer; flex-shrink:0;
  }
  .task-expand-btn:active { transform:scale(0.9); }
  .task-expand-btn svg    { width:12px; height:12px; color:var(--subtle); }

  .task-desc {
    margin-top:8px; padding:8px 10px;
    background:var(--surface2); border-radius:8px; border:1px solid var(--border);
    font-size:11px; line-height:1.55; color:var(--muted);
  }

  /* ── Summary Counter Row ──────────────────────────  */
  .task-counter     { display:flex; justify-content:space-between; align-items:center; margin:0 0 8px; }
  .task-counter span { font-family:var(--mono); font-size:10px; }
  .task-counter .done-lbl { color:var(--subtle); }
  .task-counter .xp-lbl   { color:var(--accent); }

  /* ── Boss Card ───────────────────────────────────── */
  .boss-card {
    border-radius:13px; padding:14px; margin-bottom:10px;
    background: linear-gradient(135deg, rgba(255,0,110,0.04), rgba(251,86,7,0.03));
    border: 1px solid rgba(255,0,110,0.15);
  }
  .boss-header   { display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; }
  .boss-emoji    { font-size:44px; text-align:center; margin-bottom:6px; }
  .boss-name     { font-family:var(--mono); font-size:12px; font-weight:800; text-align:center; }
  .boss-defeated { text-align:center; color:var(--accent); font-weight:800; font-size:12px; margin-top:4px; }
  .boss-hp-row   { display:flex; justify-content:space-between; margin:10px 0 5px; }
  .boss-hp-lbl   { font-size:9px; font-weight:700; color:var(--subtle); }
  .boss-stats    { font-size:9px; color:var(--subtle); text-align:center; margin-top:6px; }
  .boss-stats b  { font-family:var(--mono); font-weight:700; }

  /* ── Combo + Multiplier Banners ──────────────────── */
  .combo-banner {
    margin: 0 0 8px; padding:8px 12px; border-radius:var(--radius);
    background:linear-gradient(135deg,rgba(255,0,110,0.08),rgba(251,86,7,0.05));
    border:1px solid rgba(255,0,110,0.12);
    display:flex; align-items:center; gap:10px;
  }
  .combo-label   { font-family:var(--mono); font-size:11px; font-weight:800; color:var(--red); }
  .combo-sub     { font-size:8px; color:var(--subtle); }
  .combo-multi   { font-family:var(--mono); font-size:15px; font-weight:800; color:var(--gold); text-shadow:0 0 10px rgba(255,190,11,0.45); margin-left:auto; }

  .multi-banner {
    margin:0 0 8px; padding:7px 12px; border-radius:var(--radius);
    background:rgba(131,56,236,0.08); border:1px solid rgba(131,56,236,0.15);
    display:flex; align-items:center; gap:8px; font-size:10px; font-weight:700; color:var(--purple);
  }
  .multi-banner .lbl { font-size:8px; color:var(--subtle); margin-left:auto; }

  /* ── XP Float Particles ──────────────────────────── */
  .xp-float-root { position:fixed; inset:0; pointer-events:none; z-index:9998; }
  .xp-float-item {
    position:absolute; font-family:var(--mono); font-weight:800; font-size:20px;
    animation:xp-rise 1.2s ease-out forwards;
    text-shadow:0 0 12px currentColor;
  }

  /* ── Confetti ────────────────────────────────────── */
  .confetti-root { position:fixed; top:50%; left:50%; z-index:9999; pointer-events:none; }
  .confetti-bit  { position:absolute; animation:confetti-pop 0.9s cubic-bezier(.25,.46,.45,.94) forwards; border-radius:var(--radius-sm); }

  /* ── Achievement Toast ───────────────────────────── */
  .toast {
    position:fixed; top:68px; left:50%; transform:translateX(-50%); z-index:9997;
    background:linear-gradient(135deg,#101018,#181824);
    border:1px solid rgba(255,190,11,0.35); border-radius:var(--radius-lg);
    padding:12px 18px; display:flex; align-items:center; gap:10px;
    animation:toast-enter 0.45s ease;
    box-shadow:0 8px 32px rgba(0,0,0,0.55), 0 0 18px rgba(255,190,11,0.12);
    max-width:340px;
  }
  .toast-icon      { font-size:27px; animation: scalePop 0.5s ease; }
  .toast-label     { font-size:9px; color:var(--gold); font-family:var(--mono); font-weight:700; letter-spacing:1.4px; text-transform:uppercase; }
  .toast-title     { font-size:13px; font-weight:800; margin-top:1px; }
  .toast-desc      { font-size:10px; color:var(--muted); margin-top:1px; }

  /* ── Modal Overlay ───────────────────────────────── */
  .modal-overlay {
    position:fixed; inset:0; background:rgba(0,0,0,0.74);
    z-index:150; display:flex; align-items:flex-end; justify-content:center;
    animation:fadeIn 0.18s ease;
  }
  .modal-sheet {
    width:100%; max-width:430px; max-height:92vh;
    background:var(--bg); border-radius:20px 20px 0 0;
    padding:20px 18px 36px; overflow-y:auto;
  }
  .modal-handle {
    width:36px; height:4px; border-radius:4px;
    background:var(--border); margin:0 auto 16px;
  }
  .modal-title { font-family:var(--mono); font-size:14px; font-weight:700; }

  /* ── Form Fields ─────────────────────────────────── */
  .field            { margin-bottom:12px; }
  .field-label {
    font-size:9px; font-weight:700; color:var(--subtle);
    text-transform:uppercase; letter-spacing:1.5px; display:block; margin-bottom:5px;
  }
  .field-label .opt { color:var(--subtle); text-transform:none; letter-spacing:0; font-weight:400; }
  .field-input, .field-textarea {
    width:100%; padding:10px 12px;
    background:var(--surface); border:1px solid var(--border); border-radius:var(--radius);
    color:var(--text); font-family:var(--sans); font-size:13px; outline:none;
    transition:border-color 0.2s;
  }
  .field-input:focus, .field-textarea:focus { border-color:var(--accent); }
  .field-input::placeholder, .field-textarea::placeholder { color:var(--subtle); }
  .field-textarea   { resize:none; min-height:64px; }

  .pill-group       { display:flex; flex-wrap:wrap; gap:5px; }
  .pill {
    padding:6px 12px; border-radius:9px; background:var(--surface);
    border:1px solid var(--border); color:var(--muted);
    font-size:11px; font-weight:600; cursor:pointer;
    font-family:var(--sans); transition:all 0.18s;
  }
  .pill:active      { transform:scale(0.94); }
  .pill.active      { background:rgba(6,214,160,0.1); border-color:var(--accent); color:var(--accent); }

  /* ── Primary Button ──────────────────────────────── */
  .btn-primary {
    width:100%; padding:12px; border-radius:12px;
    background:linear-gradient(135deg,var(--accent),var(--blue));
    border:none; color:var(--bg); font-family:var(--sans);
    font-size:13px; font-weight:800; cursor:pointer; margin-top:6px;
    transition:all 0.2s;
  }
  .btn-primary:disabled { opacity:0.3; cursor:not-allowed; }
  .btn-primary:active:not(:disabled) { transform:scale(0.97); }
  .btn-ghost {
    width:100%; padding:10px; background:transparent; border:none;
    color:var(--subtle); font-size:11px; cursor:pointer;
    font-family:var(--sans); font-weight:600; margin-top:6px; border-radius:8px;
    transition:color 0.2s;
  }
  .btn-ghost:hover { color:var(--muted); }

  /* ── Proof Proof Rating ──────────────────────────── */
  .rating-btn {
    flex:1; padding:8px 4px; border-radius:10px; font-size:19px;
    cursor:pointer; transition:all 0.14s; border:1px solid var(--border);
    background:var(--surface);
  }
  .rating-btn.active { background:var(--surface3); border-color:var(--accent); transform:scale(1.1); }

  .cam-btn {
    width:32px; height:32px; border-radius:9px;
    background:rgba(6,214,160,0.07); border:1px solid rgba(6,214,160,0.25);
    cursor:pointer; display:flex; align-items:center; justify-content:center; flex-shrink:0;
  }

  .proof-bonus {
    display:flex; align-items:center; gap:8px; padding:8px 12px;
    background:rgba(6,214,160,0.06); border:1px solid rgba(6,214,160,0.14);
    border-radius:10px; margin-bottom:12px;
    font-size:11px; color:var(--accent); font-weight:700;
  }

  /* ── Demo Picker ─────────────────────────────────── */
  .demo-picker {
    margin-bottom:14px; border-radius:12px;
    border:1px solid rgba(131,56,236,0.25); overflow:hidden;
  }
  .demo-picker-hdr {
    padding:8px 12px; background:rgba(131,56,236,0.08);
    border-bottom:1px solid rgba(131,56,236,0.15);
    font-size:9px; font-family:var(--mono); font-weight:700;
    color:var(--purple); letter-spacing:1.5px; text-transform:uppercase;
  }
  .demo-row {
    width:100%; display:flex; align-items:center; gap:12px;
    padding:12px 14px; background:var(--surface); border:none;
    cursor:pointer; text-align:left; transition:background 0.15s;
  }
  .demo-row:hover { background:var(--surface2); }
  .demo-icon-box {
    width:38px; height:38px; border-radius:10px; flex-shrink:0;
    display:flex; align-items:center; justify-content:center; font-size:18px;
  }
  .demo-name    { font-weight:800; font-size:12px; color:var(--text); }
  .demo-desc    { font-size:9px; color:var(--subtle); margin-top:2px; }
  .demo-count   { font-family:var(--mono); font-size:9px; font-weight:700; padding:3px 7px; border-radius:6px; flex-shrink:0; }

  /* ── Import Trigger ──────────────────────────────── */
  .import-btn {
    display:flex; align-items:center; gap:5px; padding:5px 10px;
    border-radius:8px; cursor:pointer; transition:all 0.2s;
    font-size:10px; font-weight:700; font-family:var(--sans);
    border:1px solid var(--border); background:var(--surface); color:var(--muted);
  }
  .import-btn.open {
    background:rgba(131,56,236,0.15); border-color:rgba(131,56,236,0.5); color:var(--purple);
  }
  .import-btn svg { transition:stroke 0.2s; }

  /* ── Rank Bar ────────────────────────────────────── */
  .rank-bar {
    display:flex; align-items:center; gap:8px; padding:9px 12px;
    border-radius:var(--radius); background:var(--surface); border:1px solid var(--border);
    margin-bottom:10px;
  }
  .rank-icon     { font-size:18px; }
  .rank-name     { font-family:var(--mono); font-size:10px; font-weight:800; }
  .rank-to-next  { font-size:8px; color:var(--subtle); margin-top:1px; }
  .rank-prog     { height:3px; background:var(--surface3); border-radius:3px; overflow:hidden; margin-top:3px; }
  .rank-prog-fill { height:100%; border-radius:3px; transition:width 0.8s ease; }

  /* ── Daily Stats Row ─────────────────────────────── */
  .daily-row     { display:flex; gap:8px; margin-bottom:10px; }
  .daily-card    { flex:1; display:flex; align-items:center; gap:8px; padding:9px 10px; border-radius:var(--radius); }
  .daily-card.goal   { background:rgba(6,214,160,0.06); border:1px solid rgba(6,214,160,0.1); }
  .daily-card.streak { background:rgba(255,190,11,0.06); border:1px solid rgba(255,190,11,0.1); }
  .daily-label   { font-size:10px; font-weight:800; }
  .daily-sub     { font-size:8px; color:var(--subtle); font-weight:600; margin-top:1px; }

  /* ── Ring Progress ───────────────────────────────── */
  .ring-wrap     { position:relative; width:30px; height:30px; flex-shrink:0; }
  .ring-wrap svg { transform:rotate(-90deg); }
  .ring-num      { position:absolute; inset:0; display:flex; align-items:center; justify-content:center; font-family:var(--mono); font-size:8px; font-weight:800; color:var(--accent); }

  /* ── Pet Widget ──────────────────────────────────── */
  .pet-card      { display:flex; align-items:center; gap:10px; padding:9px 12px; border-radius:var(--radius); background:var(--surface); border:1px solid var(--border); margin-bottom:10px; }
  .pet-emoji     { font-size:inherit; }
  .pet-name      { font-size:10px; font-weight:800; }
  .pet-progress  { height:3px; background:var(--surface3); border-radius:3px; overflow:hidden; margin-top:4px; }
  .pet-fill      { height:100%; background:linear-gradient(90deg,var(--gold),var(--orange)); border-radius:3px; transition:width 0.6s ease; }

  /* ── Challenge Cards ─────────────────────────────── */
  .chal-card {
    display:flex; align-items:center; gap:12px; padding:13px 14px;
    border-radius:13px; margin-bottom:8px; border:1px solid var(--border);
    background:var(--surface); transition:all 0.2s;
  }
  .chal-card.done { opacity:0.55; background:rgba(6,214,160,0.03); border-color:rgba(6,214,160,0.18); }
  .chal-icon-box  { width:42px; height:42px; border-radius:11px; background:var(--surface2); display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0; border:1px solid var(--border); }
  .chal-card.done .chal-icon-box { background:rgba(6,214,160,0.08); border-color:rgba(6,214,160,0.2); }
  .chal-title    { font-weight:800; font-size:12px; display:flex; align-items:center; gap:5px; }
  .chal-desc     { font-size:10px; color:var(--subtle); margin-top:2px; }
  .chal-xp       { font-family:var(--mono); font-weight:800; font-size:14px; }
  .chal-xp-lbl   { font-size:8px; color:var(--subtle); margin-top:1px; }
  .done-pill     { font-size:9px; background:rgba(6,214,160,0.14); color:var(--accent); padding:1px 5px; border-radius:4px; font-family:var(--mono); font-weight:700; }

  /* ── Challenge Header Ring ───────────────────────── */
  .chal-ring-wrap { position:relative; width:52px; height:52px; flex-shrink:0; }
  .chal-ring-num  { position:absolute; inset:0; display:flex; align-items:center; justify-content:center; font-family:var(--mono); font-size:13px; font-weight:800; color:var(--purple); }

  /* ── Loot Banner ─────────────────────────────────── */
  .loot-banner {
    padding:12px 14px; border-radius:13px; margin-bottom:4px;
    background:linear-gradient(135deg,rgba(255,190,11,0.06),rgba(251,86,7,0.04));
    border:1px solid rgba(255,190,11,0.14);
    display:flex; align-items:center; gap:12px;
  }
  .loot-banner-title { font-weight:800; font-size:11px; }
  .loot-banner-sub   { font-size:9px; color:var(--subtle); margin-top:1px; }
  .loot-status {
    font-family:var(--mono); font-size:10px; font-weight:700;
    padding:4px 8px; border-radius:7px;
  }

  /* ── Bottom Nav ──────────────────────────────────── */
  .bottom-nav {
    position:fixed; bottom:0; left:50%; transform:translateX(-50%);
    width:100%; max-width:430px;
    background:rgba(16,16,24,0.94); backdrop-filter:blur(22px);
    border-top:1px solid var(--border);
    display:flex; align-items:center; justify-content:space-around;
    padding:4px 2px 22px; z-index:100;
  }
  .nav-item {
    display:flex; flex-direction:column; align-items:center; gap:2px;
    cursor:pointer; padding:5px 8px; border-radius:10px;
    background:none; border:none; font-family:var(--sans);
  }
  .nav-item svg     { width:18px; height:18px; color:var(--subtle); transition:color 0.2s; }
  .nav-item span    { font-size:8px; font-weight:700; color:var(--subtle); transition:color 0.2s; }
  .nav-item.active svg   { color:var(--accent); }
  .nav-item.active span  { color:var(--accent); }
  .nav-add {
    width:48px; height:48px; border-radius:14px; margin-top:-20px;
    background:linear-gradient(135deg,var(--accent),var(--blue));
    border:none; display:flex; align-items:center; justify-content:center;
    cursor:pointer; box-shadow:0 4px 20px rgba(6,214,160,0.28); transition:all 0.25s;
  }
  .nav-add:active  { transform:scale(0.88); }
  .nav-add svg     { width:22px; height:22px; color:var(--bg); }

  /* ── Stats / Profile Tabs ────────────────────────── */
  .stats-section   { margin-bottom:12px; }
  .section-label   { font-family:var(--mono); font-size:9px; font-weight:700; color:var(--subtle); text-transform:uppercase; letter-spacing:2px; margin-bottom:10px; }

  /* ── Chart Bars ──────────────────────────────────── */
  .bar-row         { display:flex; align-items:center; gap:8px; margin-bottom:8px; }
  .bar-label       { width:50px; font-size:9px; font-weight:600; color:var(--muted); text-align:right; }
  .bar-track       { flex:1; height:20px; background:var(--surface2); border-radius:6px; overflow:hidden; }
  .bar-fill        { height:100%; border-radius:6px; display:flex; align-items:center; justify-content:flex-end; padding-right:6px; font-family:var(--mono); font-size:8px; font-weight:700; color:rgba(0,0,0,0.65); transition:width 1s ease; }

  /* ── Leaderboard ─────────────────────────────────── */
  .lb-card         { display:flex; align-items:center; gap:10px; padding:11px; background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); margin-bottom:6px; }
  .lb-card.you     { border-color:rgba(6,214,160,0.28); background:rgba(6,214,160,0.04); }
  .lb-rank         { font-family:var(--mono); font-size:12px; font-weight:800; color:var(--subtle); width:22px; text-align:center; }
  .lb-rank.g { color:var(--gold); } .lb-rank.s { color:#aaa; } .lb-rank.b { color:#cd7f32; }
  .lb-av           { font-size:22px; }
  .lb-name         { font-size:11px; font-weight:700; }
  .lb-xp           { font-family:var(--mono); font-size:9px; color:var(--accent); font-weight:600; }
  .lb-meta         { display:flex; gap:6px; margin-top:2px; }
  .lb-meta span    { font-size:8px; color:var(--subtle); }
  .lb-level        { font-family:var(--mono); font-size:9px; color:var(--purple); font-weight:700; }
  .challenge-btn   { padding:4px 8px; border-radius:6px; background:rgba(131,56,236,0.14); border:1px solid rgba(131,56,236,0.28); color:var(--purple); font-size:9px; font-weight:700; cursor:pointer; font-family:var(--sans); transition:all 0.2s; }
  .challenge-btn.sent { background:rgba(6,214,160,0.1); border-color:rgba(6,214,160,0.28); color:var(--accent); }
  .invite-btn      { width:100%; padding:12px; border-radius:12px; background:linear-gradient(135deg,var(--accent),var(--blue)); border:none; color:var(--bg); font-family:var(--sans); font-size:12px; font-weight:800; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px; transition:all 0.2s; margin-top:12px; }
  .invite-btn:active { transform:scale(0.96); }
  .invite-btn.sent { background:var(--surface2); color:var(--accent); border:1px solid rgba(6,214,160,0.28); }

  /* ── Profile ─────────────────────────────────────── */
  .profile-hdr     { text-align:center; padding:8px 0 18px; }
  .avatar-ring     { width:72px; height:72px; border-radius:50%; background:linear-gradient(135deg,var(--accent),var(--blue)); padding:3px; margin:0 auto 10px; }
  .avatar-inner    { width:100%; height:100%; border-radius:50%; background:var(--surface); display:flex; align-items:center; justify-content:center; font-size:30px; }
  .profile-name    { font-size:17px; font-weight:800; }
  .profile-tag     { font-family:var(--mono); font-size:9px; color:var(--accent); margin-top:2px; font-weight:600; }
  .xp-bar-card     { background:var(--surface); border-radius:12px; padding:12px; border:1px solid var(--border); margin-bottom:12px; }
  .xp-bar-top      { display:flex; justify-content:space-between; align-items:baseline; margin-bottom:6px; }
  .xp-level        { font-family:var(--mono); font-size:15px; font-weight:800; color:var(--accent); }
  .xp-num          { font-family:var(--mono); font-size:10px; color:var(--subtle); }
  .stat-grid       { display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:12px; }
  .stat-box        { background:var(--surface); border:1px solid var(--border); border-radius:12px; padding:12px; text-align:center; }
  .stat-val        { font-family:var(--mono); font-size:20px; font-weight:800; }
  .stat-lbl        { font-size:9px; color:var(--subtle); margin-top:2px; font-weight:600; }
  .activity-item   { display:flex; align-items:center; gap:10px; padding:9px 11px; background:var(--surface); border:1px solid var(--border); border-radius:10px; margin-bottom:5px; }
  .activity-icon   { width:30px; height:30px; border-radius:8px; background:var(--surface2); display:flex; align-items:center; justify-content:center; font-size:13px; flex-shrink:0; }
  .activity-title  { font-size:11px; font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .activity-time   { font-size:8px; color:var(--subtle); margin-top:1px; font-family:var(--mono); }
  .activity-pts    { font-family:var(--mono); font-size:10px; font-weight:700; color:var(--accent); }
  .badges-grid     { display:grid; grid-template-columns:repeat(5,1fr); gap:6px; }
  .badge-box       { text-align:center; padding:10px 3px; background:var(--surface); border:1px solid var(--border); border-radius:11px; }
  .badge-box.locked { opacity:0.22; filter:grayscale(1); }
  .badge-icon      { font-size:20px; margin-bottom:2px; }
  .badge-name      { font-size:7px; color:var(--subtle); font-weight:700; }
  .milestone-row   { display:flex; align-items:center; gap:10px; padding:11px; background:var(--surface); border:1px solid var(--border); border-radius:10px; margin-bottom:5px; }
  .milestone-icon  { font-size:18px; }
  .milestone-title { flex:1; font-size:11px; font-weight:700; }
  .milestone-date  { font-size:9px; font-family:var(--mono); font-weight:700; }

  /* ── Skill Tree ──────────────────────────────────── */
  .skill-grid      { display:grid; grid-template-columns:1fr 1fr 1fr; gap:7px; }
  .skill-node      { text-align:center; padding:10px 4px; background:var(--surface); border:1px solid var(--border); border-radius:11px; cursor:pointer; transition:all 0.22s; }
  .skill-node.unlocked { border-color:rgba(6,214,160,0.28); background:rgba(6,214,160,0.04); }
  .skill-node.locked   { opacity:0.34; }
  .skill-node:active   { transform:scale(0.94); }
  .skill-icon      { font-size:20px; margin-bottom:3px; }
  .skill-name      { font-size:8px; font-weight:700; }
  .skill-cost      { font-family:var(--mono); font-size:7px; margin-top:2px; }

  /* ── Danger Zone ─────────────────────────────────── */
  .danger-zone {
    border-radius:13px; padding:14px 16px;
    background: rgba(255,0,110,0.04);
    border: 1px solid rgba(255,0,110,0.18);
    margin-top:14px; margin-bottom:4px;
  }
  .danger-zone-title {
    font-family:var(--mono); font-size:9px; font-weight:700;
    color:var(--red); text-transform:uppercase; letter-spacing:1.8px; margin-bottom:10px;
    display:flex; align-items:center; gap:5px;
  }
  .danger-zone-row  { display:flex; align-items:center; gap:12px; }
  .dz-label { font-weight:800; font-size:12px; }
  .dz-sub   { font-size:10px; color:var(--muted); margin-top:2px; }
  .btn-danger {
    padding:8px 14px; border-radius:9px; flex-shrink:0;
    background:rgba(255,0,110,0.1); border:1px solid rgba(255,0,110,0.3);
    color:var(--red); font-family:var(--sans); font-size:11px; font-weight:800;
    cursor:pointer; transition:all 0.2s; white-space:nowrap;
  }
  .btn-danger:hover  { background:rgba(255,0,110,0.18); border-color:rgba(255,0,110,0.5); }
  .btn-danger:active { transform:scale(0.94); }

  /* ── Clear Confirm Dialog ────────────────────────── */
  .confirm-overlay {
    position:fixed; inset:0; background:rgba(0,0,0,0.8);
    z-index:300; display:flex; align-items:center; justify-content:center;
    padding:24px; animation:fadeIn 0.18s ease;
  }
  .confirm-dialog {
    width:100%; max-width:360px;
    background:var(--surface2); border:1px solid rgba(255,0,110,0.25);
    border-radius:18px; padding:26px 22px; text-align:center;
    animation:scaleIn 0.22s ease both;
    box-shadow: 0 24px 64px rgba(0,0,0,0.7), 0 0 0 1px rgba(255,0,110,0.1);
  }
  .confirm-dialog .cd-icon  { font-size:48px; margin-bottom:12px; }
  .confirm-dialog .cd-title { font-family:var(--mono); font-size:16px; font-weight:800; margin-bottom:8px; }
  .confirm-dialog .cd-body  { font-size:12px; color:var(--muted); line-height:1.65; margin-bottom:22px; }
  .confirm-dialog .cd-count { color:var(--red); font-family:var(--mono); font-weight:700; }
  .btn-danger-confirm {
    width:100%; padding:13px; border-radius:12px;
    background:linear-gradient(135deg,#ff006e,#fb5607);
    border:none; color:white; font-family:var(--sans);
    font-size:13px; font-weight:800; cursor:pointer; margin-bottom:9px;
    transition:all 0.2s; box-shadow:0 4px 18px rgba(255,0,110,0.3);
  }
  .btn-danger-confirm:active { transform:scale(0.97); }

  /* ── Rank Tier Chips ─────────────────────────────── */
  .rank-tiers      { display:flex; gap:5px; }
  .rank-tier-box   { flex:1; text-align:center; padding:8px 3px; border-radius:9px; background:var(--surface); border:1px solid var(--border); transition:all 0.3s; }
  .rank-tier-box.earned { background:var(--surface2); }
  .rank-tier-icon  { font-size:16px; }
  .rank-tier-name  { font-size:7px; font-weight:700; margin-top:3px; }
  .rank-tier-min   { font-size:6px; font-family:var(--mono); color:var(--subtle); margin-top:1px; }

  /* ── Spin Wheel ──────────────────────────────────── */
  .wheel-result {
    padding:14px; background:var(--surface2); border-radius:12px;
    margin-bottom:14px; text-align:center;
  }
  .wheel-result-icon  { font-size:24px; margin-bottom:4px; }
  .wheel-result-label { font-family:var(--mono); font-size:16px; font-weight:800; }
  .wheel-result-desc  { font-size:10px; color:var(--muted); margin-top:3px; }

  /* ── Shadcn Overrides ────────────────────────────── */
  [data-radix-popper-content-wrapper] { z-index:300; }
`;

/* ═══════════════════════════════════════════════════
   DATA
══════════════════════════════════════════════════════ */
const TASKS_INIT = [
  { id:1, title:"Morning Meditation", desc:"10 minutes of mindfulness breathing exercises.", time:"6:30 AM", points:50, project:"Wellness", streak:12, done:false, priority:"high", category:"Health" },
  { id:2, title:"Review Pull Requests", desc:"Check and approve pending PRs on the main repo.", time:"9:00 AM", points:80, project:"DevOps", streak:5, done:true, priority:"high", category:"Work" },
  { id:3, title:"Read 20 Pages", desc:"Continue reading 'Atomic Habits' — Chapter 7.", time:"12:30 PM", points:30, project:"Growth", streak:21, done:false, priority:"medium", category:"Learning" },
  { id:4, title:"Gym Session", desc:"Upper body: bench, OHP, rows, curls.", time:"5:00 PM", points:100, project:"Wellness", streak:8, done:false, priority:"high", category:"Health" },
  { id:5, title:"Update Design System", desc:"Sync Figma tokens with codebase.", time:"3:00 PM", points:60, project:"UI Kit", streak:3, done:false, priority:"medium", category:"Work" },
  { id:6, title:"Journal Entry", desc:"Wins, lessons, and gratitude list.", time:"9:30 PM", points:40, project:"Growth", streak:30, done:false, priority:"low", category:"Personal" },
  { id:7, title:"Team Standup Notes", desc:"Prepare blockers and progress update.", time:"8:45 AM", points:25, project:"DevOps", streak:15, done:true, priority:"low", category:"Work" },
  { id:8, title:"Drink 2L Water", desc:"Track water intake throughout the day.", time:"All day", points:20, project:"Wellness", streak:45, done:true, priority:"low", category:"Health" },
];

const LEADERBOARD = [
  { name:"You",       xp:2480, avatar:"🧑‍💻", level:14, streak:30, tasksWeek:42 },
  { name:"Priya S.",  xp:2350, avatar:"👩‍🎨", level:13, streak:18, tasksWeek:38 },
  { name:"Marcus W.", xp:2100, avatar:"🧔",   level:12, streak:25, tasksWeek:35 },
  { name:"Luna K.",   xp:1890, avatar:"👩‍🔬", level:11, streak:10, tasksWeek:31 },
  { name:"Jake T.",   xp:1650, avatar:"🧑‍🚀", level:10, streak:7,  tasksWeek:28 },
  { name:"Ava M.",    xp:1520, avatar:"👩‍🏫", level:9,  streak:14, tasksWeek:24 },
];

const PROJECT_STATS = [
  { name:"Wellness", completed:24, total:30, color:"#06d6a0" },
  { name:"DevOps",   completed:18, total:25, color:"#8338ec" },
  { name:"Growth",   completed:31, total:35, color:"#ffbe0b" },
  { name:"UI Kit",   completed:8,  total:15, color:"#fb5607" },
  { name:"Personal", completed:12, total:20, color:"#ff006e" },
];

const NOTIFS = [
  { id:1, text:"🔥 12-day streak for Meditation!", time:"2m ago", read:false },
  { id:2, text:"🏆 Priya passed your weekly score!", time:"15m ago", read:false },
  { id:3, text:"⭐ 'Consistency King' badge earned!", time:"1h ago", read:false },
  { id:4, text:"📈 Productivity up 23% this week.", time:"3h ago", read:true },
];

const ACTIVITY_LOG_INIT = [
  { task:"Review Pull Requests", points:80, time:"Today, 9:14 AM", icon:"💼" },
  { task:"Team Standup Notes",   points:25, time:"Today, 8:52 AM", icon:"💼" },
  { task:"Drink 2L Water",       points:20, time:"Today, 6:00 PM", icon:"💪" },
  { task:"Morning Meditation",   points:50, time:"Yesterday, 6:35 AM", icon:"💪" },
  { task:"Gym Session",          points:100, time:"Yesterday, 5:22 PM", icon:"💪" },
  { task:"Read 20 Pages",        points:30, time:"Yesterday, 12:45 PM", icon:"📚" },
  { task:"Journal Entry",        points:40, time:"Yesterday, 9:40 PM", icon:"🏠" },
];

const HOURLY_DATA = [
  {h:"6a",v:3},{h:"7a",v:2},{h:"8a",v:5},{h:"9a",v:8},{h:"10a",v:7},
  {h:"11a",v:6},{h:"12p",v:4},{h:"1p",v:3},{h:"2p",v:5},{h:"3p",v:7},
  {h:"4p",v:6},{h:"5p",v:8},{h:"6p",v:4},{h:"7p",v:3},{h:"8p",v:2},
  {h:"9p",v:4},{h:"10p",v:1},
];

const WEEKLY_XP  = [{day:"Mon",xp:320},{day:"Tue",xp:480},{day:"Wed",xp:250},{day:"Thu",xp:560},{day:"Fri",xp:410},{day:"Sat",xp:180},{day:"Sun",xp:340}];
const CATEGORY_DATA = [{name:"Work",value:35,color:"#8338ec"},{name:"Health",value:28,color:"#06d6a0"},{name:"Learning",value:20,color:"#ffbe0b"},{name:"Personal",value:17,color:"#ff006e"}];

const BADGES = [
  {icon:"🔥",name:"Streak Lord",unlocked:true},{icon:"⚡",name:"Speed Demon",unlocked:true},
  {icon:"🎯",name:"Perfectionist",unlocked:true},{icon:"🏆",name:"Champion",unlocked:true},
  {icon:"🌟",name:"Rising Star",unlocked:true},{icon:"💎",name:"Diamond",unlocked:true},
  {icon:"🦁",name:"Brave Heart",unlocked:false},{icon:"🌙",name:"Night Owl",unlocked:false},
  {icon:"🌅",name:"Early Bird",unlocked:true},{icon:"🤝",name:"Team Player",unlocked:false},
];

const RANK_TIERS = [
  {name:"Bronze",min:0,   icon:"🥉",color:"#cd7f32"},
  {name:"Silver",min:500, icon:"🥈",color:"#c0c0c0"},
  {name:"Gold",  min:1500,icon:"🥇",color:"#ffd700"},
  {name:"Diamond",min:3000,icon:"💎",color:"#00d4ff"},
  {name:"Legend",min:5000,icon:"👑",color:"#ff006e"},
];

const WHEEL_SEGMENTS = [
  {label:"+50 XP",value:50,type:"xp",color:"#06d6a0"},{label:"2× Next",value:2,type:"multi",color:"#8338ec"},
  {label:"+20 XP",value:20,type:"xp",color:"#3a86ff"},{label:"🛡️ Shield",value:1,type:"shield",color:"#ffbe0b"},
  {label:"+100 XP",value:100,type:"xp",color:"#ff006e"},{label:"+30 XP",value:30,type:"xp",color:"#fb5607"},
  {label:"3× Next",value:3,type:"multi",color:"#06d6a0"},{label:"+75 XP",value:75,type:"xp",color:"#8338ec"},
];

const BOSS_INIT = {name:"Procrastination Dragon",emoji:"🐉",hp:500,maxHp:500,reward:300,tasksDone:0,tasksNeeded:15};

const SKILL_TREE = [
  {id:"focus1",name:"Focus I",desc:"+5% Work XP",icon:"🎯",cost:100,unlocked:true},
  {id:"focus2",name:"Focus II",desc:"+10% Work XP",icon:"🎯",cost:250,unlocked:true},
  {id:"focus3",name:"Focus III",desc:"+20% Work XP",icon:"🎯",cost:500,unlocked:false},
  {id:"vitality1",name:"Vitality I",desc:"+5% Health XP",icon:"❤️",cost:100,unlocked:true},
  {id:"vitality2",name:"Vitality II",desc:"+10% Health XP",icon:"❤️",cost:250,unlocked:false},
  {id:"wisdom1",name:"Wisdom I",desc:"+5% Learn XP",icon:"📖",cost:100,unlocked:true},
  {id:"wisdom2",name:"Wisdom II",desc:"+10% Learn XP",icon:"📖",cost:250,unlocked:false},
  {id:"combo",name:"Combo+",desc:"Slower combo decay",icon:"🔥",cost:400,unlocked:false},
];

const DAILY_CHALLENGES_INIT = [
  {id:1,title:"Early Bird",desc:"Complete a task before 8 AM",reward:75,icon:"🌅",done:false},
  {id:2,title:"Triple Threat",desc:"Complete 3 tasks in a row",reward:100,icon:"⚡",done:false},
  {id:3,title:"Health Hero",desc:"Complete 2 Health tasks",reward:60,icon:"💪",done:false},
];

const PET_STAGES = [
  {name:"Egg",emoji:"🥚",minTasks:0,size:28},
  {name:"Baby Slime",emoji:"🫧",minTasks:3,size:32},
  {name:"Fox Cub",emoji:"🦊",minTasks:10,size:36},
  {name:"Phoenix",emoji:"🦅",minTasks:25,size:40},
  {name:"Dragon",emoji:"🐲",minTasks:50,size:44},
];

const DEMO_SETS = [{
  id:"rebuzz", name:"Rebuzz POS Demo", icon:"🏪",
  desc:"10 marketing tasks to build a predictable sales pipeline", color:"#8338ec",
  tasks:[
    {title:"Map Primary & Secondary ICPs",desc:"Identify exact criteria for best Rebuzz POS customers.",time:"9:00 AM",points:80,project:"Strategy",priority:"high",category:"Work"},
    {title:"Segment Database by Niche",desc:"Break TAM into sub-niches: cafes automating loyalty vs. retailers.",time:"10:00 AM",points:60,project:"Strategy",priority:"high",category:"Work"},
    {title:"Build Targeted Outbound Lists",desc:"Scrape or build 100–200 high-quality ICP-matched contacts per week.",time:"11:00 AM",points:80,project:"Outbound",priority:"high",category:"Work"},
    {title:"Draft Referral Email Sequences",desc:"Write 3-step plain-text sequences aimed at getting POS referrals.",time:"2:00 PM",points:60,project:"Outbound",priority:"medium",category:"Work"},
    {title:"Create Sales Enablement 1-Pagers",desc:"Develop collateral highlighting cost-saving benefits for SDRs.",time:"3:00 PM",points:50,project:"Outbound",priority:"medium",category:"Work"},
    {title:"Develop Gated Lead Magnets",desc:"Create the 2026 Guide eBook and a POS ROI Calculator.",time:"9:00 AM",points:80,project:"Inbound",priority:"high",category:"Work"},
    {title:"Setup Inbound Qualification Funnel",desc:"Build automated email workflows to nurture content downloaders.",time:"11:00 AM",points:80,project:"Inbound",priority:"high",category:"Work"},
    {title:"Launch Educational Webinar",desc:"Host a 20-min monthly webinar on integrated POS ops.",time:"1:00 PM",points:50,project:"Inbound",priority:"medium",category:"Work"},
    {title:"Build Case Study Library",desc:"Interview top 5 Rebuzz POS clients. Publish with hard metrics.",time:"10:00 AM",points:60,project:"Customer",priority:"medium",category:"Work"},
    {title:"Launch Client Referral Program",desc:"Create formalized affiliate/referral campaign incentivizing POS users.",time:"2:00 PM",points:50,project:"Customer",priority:"low",category:"Work"},
  ]
}];

const generateHeatmap = () => {
  const d = [];
  for (let w=0;w<12;w++){const wk=[];for(let i=0;i<7;i++)wk.push(Math.min(Math.floor(Math.random()*7)+(w>8?3:1),8));d.push(wk);}
  return d;
};

/* ═══════════════════════════════════════════════════
   SHARED MICRO-COMPONENTS
══════════════════════════════════════════════════════ */
function AnimNum({ value }) {
  const [d, setD] = useState(0);
  useEffect(() => {
    let s = 0; const step = value / 42;
    const id = setInterval(() => { s += step; if (s >= value) { setD(value); clearInterval(id); } else setD(Math.floor(s)); }, 16);
    return () => clearInterval(id);
  }, [value]);
  return <span>{d.toLocaleString()}</span>;
}

function ConfettiBurst({ show }) {
  if (!show) return null;
  return (
    <div className="confetti-root">
      {Array.from({length:28},(_,i) => (
        <div key={i} className="confetti-bit" style={{
          width: Math.random()*7+3, height: Math.random()*7+3,
          borderRadius: Math.random()>0.5?"50%":"2px",
          background:["#06d6a0","#8338ec","#ffbe0b","#fb5607","#ff006e","#3a86ff"][i%6],
          animationDelay:`${Math.random()*0.3}s`,
          "--tx":`${Math.random()*260-130}px`,
          "--ty":`${Math.random()*-200-40}px`,
          "--tr":`${Math.random()*540}deg`,
        }} />
      ))}
    </div>
  );
}

function XPFloat({ floats }) {
  return (
    <div className="xp-float-root">
      {floats.map(f => (
        <div key={f.id} className="xp-float-item" style={{ left:f.x, top:f.y, color:f.multi>1?"#ff006e":"#06d6a0" }}>
          +{f.value}{f.multi>1?` ×${f.multi}`:""}
        </div>
      ))}
    </div>
  );
}

function Toast({ toast, onDone }) {
  useEffect(() => { if (toast) { const t = setTimeout(onDone, 3200); return () => clearTimeout(t); } }, [toast]);
  if (!toast) return null;
  return (
    <div className="toast">
      <div className="toast-icon">{toast.icon}</div>
      <div>
        <div className="toast-label">Achievement Unlocked!</div>
        <div className="toast-title">{toast.title}</div>
        <div className="toast-desc">{toast.desc}</div>
      </div>
    </div>
  );
}

function DonutChart({ data, size=126 }) {
  const total = data.reduce((s,d)=>s+d.value,0);
  let cum=0; const r=46,cx=63,cy=63,circ=2*Math.PI*r;
  return (
    <svg width={size} height={size} viewBox="0 0 126 126">
      {data.map((seg,i)=>{ const pct=seg.value/total,dl=pct*circ,off=-cum*circ; cum+=pct; return <circle key={i} cx={cx} cy={cy} r={r} fill="none" stroke={seg.color} strokeWidth={18} strokeDasharray={`${dl} ${circ-dl}`} strokeDashoffset={off} strokeLinecap="round" style={{transition:"stroke-dasharray 1s ease",transform:"rotate(-90deg)",transformOrigin:"center"}} />; })}
      <text x={cx} y={cy-3} textAnchor="middle" fill="#e8e8f0" fontSize="18" fontWeight="800" fontFamily="'JetBrains Mono'">{total}</text>
      <text x={cx} y={cy+11} textAnchor="middle" fill="#555570" fontSize="8" fontWeight="600">TASKS</text>
    </svg>
  );
}

function HeatmapGrid({ data }) {
  const days=["M","T","W","T","F","S","S"];
  const gc=v=>v===0?"rgba(255,255,255,0.03)":v<=2?"rgba(6,214,160,0.15)":v<=4?"rgba(6,214,160,0.35)":v<=6?"rgba(6,214,160,0.6)":"rgba(6,214,160,0.9)";
  return (
    <div style={{display:"flex",gap:3}}>
      <div style={{display:"flex",flexDirection:"column",gap:3,marginRight:2}}>
        {days.map((d,i)=><div key={i} style={{width:12,height:14,fontSize:8,color:"#555570",display:"flex",alignItems:"center",justifyContent:"center",fontFamily:"'JetBrains Mono'"}}>{d}</div>)}
      </div>
      {data.map((week,wi)=>(
        <div key={wi} style={{display:"flex",flexDirection:"column",gap:3}}>
          {week.map((val,di)=><div key={di} style={{width:14,height:14,borderRadius:3,background:gc(val),transition:`background 0.3s ease ${(wi*7+di)*0.006}s`}} />)}
        </div>
      ))}
    </div>
  );
}

function Sparkline({ data, color="#06d6a0", height=52 }) {
  const max=Math.max(...data.map(d=>d.xp)); const w=280,h=height;
  const pts=data.map((d,i)=>`${(i/(data.length-1))*w},${h-(d.xp/max)*(h-10)-5}`).join(" ");
  return (
    <svg width="100%" height={h} viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none">
      <defs><linearGradient id="sf" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor={color} stopOpacity="0.3"/><stop offset="100%" stopColor={color} stopOpacity="0"/></linearGradient></defs>
      <polygon points={`0,${h} ${pts} ${w},${h}`} fill="url(#sf)"/>
      <polyline points={pts} fill="none" stroke={color} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function Gauge({ value, max, label, color }) {
  const pct=(value/max)*100, r=32, circ=2*Math.PI*r;
  return (
    <div style={{textAlign:"center"}}>
      <svg width="76" height="76" viewBox="0 0 76 76">
        <circle cx="38" cy="38" r={r} fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth="5"/>
        <circle cx="38" cy="38" r={r} fill="none" stroke={color} strokeWidth="5" strokeDasharray={`${(pct/100)*circ} ${circ-(pct/100)*circ}`} strokeDashoffset={circ*0.25} strokeLinecap="round" style={{transition:"stroke-dasharray 1.2s ease"}}/>
        <text x="38" y="36" textAnchor="middle" fill="#e8e8f0" fontSize="13" fontWeight="800" fontFamily="'JetBrains Mono'">{Math.round(pct)}%</text>
        <text x="38" y="48" textAnchor="middle" fill="#555570" fontSize="7" fontWeight="600">{label}</text>
      </svg>
    </div>
  );
}

/* ── Spin Wheel ─────────────────────────────────────── */
function SpinWheel({ visible, onClose, onResult }) {
  const [spinning, setSpinning] = useState(false);
  const [rotation, setRotation] = useState(0);
  const [result, setResult] = useState(null);
  const spin = () => {
    if (spinning) return; setSpinning(true); setResult(null);
    const segAngle=360/WHEEL_SEGMENTS.length;
    const winIdx=Math.floor(Math.random()*WHEEL_SEGMENTS.length);
    setRotation(p=>p+360*5+(360-winIdx*segAngle-segAngle/2));
    setTimeout(()=>{ setSpinning(false); setResult(WHEEL_SEGMENTS[winIdx]); onResult(WHEEL_SEGMENTS[winIdx]); },3500);
  };
  if (!visible) return null;
  return (
    <div className="modal-overlay anim-fadeIn" onClick={e=>{ if(e.target===e.currentTarget&&!spinning) onClose(); }}>
      <div className="modal-sheet anim-slideUp" style={{textAlign:"center",paddingTop:24}}>
        <div className="modal-handle"/>
        <div className="modal-title" style={{marginBottom:18}}>🎰 Daily Spin</div>
        <div style={{position:"relative",width:220,height:220,margin:"0 auto 18px"}}>
          <div style={{position:"absolute",top:-8,left:"50%",transform:"translateX(-50%)",zIndex:2,fontSize:18,color:"var(--gold)"}}>▼</div>
          <svg width="220" height="220" viewBox="0 0 220 220" style={{transition:spinning?"transform 3.5s cubic-bezier(0.17,0.67,0.12,0.99)":"none",transform:`rotate(${rotation}deg)`}}>
            {WHEEL_SEGMENTS.map((seg,i)=>{
              const angle=(2*Math.PI)/WHEEL_SEGMENTS.length;
              const startA=i*angle-Math.PI/2, endA=startA+angle;
              const x1=110+100*Math.cos(startA),y1=110+100*Math.sin(startA);
              const x2=110+100*Math.cos(endA),y2=110+100*Math.sin(endA);
              const midA=startA+angle/2;
              const tx=110+65*Math.cos(midA),ty=110+65*Math.sin(midA);
              return (
                <g key={i}>
                  <path d={`M110,110 L${x1},${y1} A100,100 0 0,1 ${x2},${y2} Z`} fill={seg.color} opacity="0.8" stroke="var(--bg)" strokeWidth="2"/>
                  <text x={tx} y={ty} textAnchor="middle" dominantBaseline="middle" fill="white" fontSize="9" fontWeight="700" fontFamily="'JetBrains Mono'" transform={`rotate(${i*360/WHEEL_SEGMENTS.length+360/WHEEL_SEGMENTS.length/2},${tx},${ty})`}>{seg.label}</text>
                </g>
              );
            })}
            <circle cx="110" cy="110" r="20" fill="var(--bg)" stroke="var(--border)" strokeWidth="2"/>
            <text x="110" y="114" textAnchor="middle" fill="var(--accent)" fontSize="16">🎰</text>
          </svg>
        </div>
        {result && (
          <div className="wheel-result anim-scaleIn" style={{border:`1px solid ${result.color}40`}}>
            <div className="wheel-result-icon">{result.type==="shield"?"🛡️":result.type==="multi"?"✨":"⚡"}</div>
            <div className="wheel-result-label" style={{color:result.color}}>{result.label}</div>
            <div className="wheel-result-desc">{result.type==="shield"?"Streak Shield — protects one missed day":result.type==="multi"?`${result.value}× multiplier on your next task!`:"Bonus XP added!"}</div>
          </div>
        )}
        <button className="btn-primary" onClick={spinning?undefined:(result?onClose:spin)} disabled={spinning}>
          {spinning?"Spinning...":result?"Collect & Close":"🎰 SPIN!"}
        </button>
      </div>
    </div>
  );
}

/* ── Loot Box ────────────────────────────────────────── */
function LootBox({ visible, onClose, onOpen }) {
  const [opened, setOpened] = useState(false);
  const [loot, setLoot] = useState(null);
  const loots = [
    {icon:"⚡",name:"+150 Bonus XP",desc:"A surge of energy!",rarity:"Rare",color:"#06d6a0"},
    {icon:"🛡️",name:"Streak Shield",desc:"Protect your streak",rarity:"Epic",color:"#8338ec"},
    {icon:"✨",name:"3× Multiplier",desc:"Triple XP next task",rarity:"Legendary",color:"#ffbe0b"},
    {icon:"🎨",name:"Neon Theme",desc:"Unlock neon glow",rarity:"Rare",color:"#ff006e"},
    {icon:"🐲",name:"Dragon Egg",desc:"Pet evolution boost",rarity:"Legendary",color:"#fb5607"},
  ];
  const open = () => { const item=loots[Math.floor(Math.random()*loots.length)]; setLoot(item); setOpened(true); onOpen(item); };
  const close = () => { setOpened(false); setLoot(null); onClose(); };
  if (!visible) return null;
  return (
    <div className="modal-overlay anim-fadeIn" onClick={e=>{ if(e.target===e.currentTarget) close(); }}>
      <div className="modal-sheet anim-slideUp" style={{textAlign:"center",paddingTop:24}}>
        <div className="modal-handle"/>
        {!opened ? (
          <>
            <div className="anim-chest" style={{fontSize:64,marginBottom:14}}>🎁</div>
            <div className="modal-title" style={{marginBottom:6}}>Treasure Chest!</div>
            <p style={{fontSize:11,color:"var(--muted)",marginBottom:20}}>Earned by completing a task set.</p>
            <button className="btn-primary" onClick={open}>🔓 Open Chest</button>
          </>
        ) : (
          <>
            <div style={{fontSize:52,marginBottom:10,animation:"loot-spin 0.6s ease both"}}>{loot.icon}</div>
            <div style={{fontSize:9,fontWeight:700,color:loot.color,letterSpacing:2,textTransform:"uppercase",marginBottom:3,fontFamily:"var(--mono)"}}>{loot.rarity}</div>
            <div style={{fontSize:16,fontWeight:800,marginBottom:3}}>{loot.name}</div>
            <div style={{fontSize:11,color:"var(--muted)",marginBottom:20}}>{loot.desc}</div>
            <button className="btn-primary" onClick={close}>✨ Collect</button>
          </>
        )}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════
   MAIN APP
══════════════════════════════════════════════════════ */
export default function QuestLog() {
  /* ── State ────────────────────────────────────────── */
  const [tab, setTab] = useState("tasks");
  const [tasks, setTasks] = useState(TASKS_INIT);
  const [showAdd, setShowAdd] = useState(false);
  const [showDemoSelect, setShowDemoSelect] = useState(false);
  const [showNotif, setShowNotif] = useState(false);
  const [showSpin, setShowSpin] = useState(false);
  const [showLoot, setShowLoot] = useState(false);
  const [showChallenges, setShowChallenges] = useState(false);
  const [openDesc, setOpenDesc] = useState(null);
  const [confetti, setConfetti] = useState(false);
  const [notifs, setNotifs] = useState(NOTIFS);
  const [lbFilter, setLbFilter] = useState("weekly");
  const [profileTab, setProfileTab] = useState("activity");
  const [statsTab, setStatsTab] = useState("overview");
  const [activityLog, setActivityLog] = useState(ACTIVITY_LOG_INIT);
  const [inviteSent, setInviteSent] = useState(false);
  const [challengeSent, setChallengeSent] = useState(null);
  const [newTask, setNewTask] = useState({title:"",desc:"",category:"Work",frequency:"Daily",time:"09:00",priority:"medium"});
  const [spinUsed, setSpinUsed] = useState(false);
  const [proofModal, setProofModal] = useState(null);
  const [proofText, setProofText] = useState("");
  const [proofRating, setProofRating] = useState(0);
  const [proofHover, setProofHover] = useState(0);
  const [proofPhoto, setProofPhoto] = useState(null);
  const proofCamRef = useRef(null);
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
  const [showClearConfirm, setShowClearConfirm] = useState(false);

  const heatmap = useMemo(() => generateHeatmap(), []);

  /* ── Derived ────────────────────────────────────────── */
  const totalXP = tasks.filter(t=>t.done).reduce((s,t)=>s+t.points,0) + bonusXP;
  const level = Math.floor(totalXP/200)+1;
  const xpInLevel = totalXP%200;
  const unread = notifs.filter(n=>!n.read).length;
  const dailyDone = tasks.filter(t=>t.done).length;
  const currentRank = [...RANK_TIERS].reverse().find(r=>totalXP>=r.min)||RANK_TIERS[0];
  const nextRank = RANK_TIERS[RANK_TIERS.indexOf(currentRank)+1];
  const pet = [...PET_STAGES].reverse().find(p=>totalLifetimeTasks>=p.minTasks)||PET_STAGES[0];
  const comboMulti = combo>=5?4:combo>=3?3:combo>=2?2:1;
  const effectiveMulti = Math.max(multiplier,comboMulti);
  const bossHpPct = Math.max(0,(boss.hp/boss.maxHp)*100);

  /* ── Helpers ─────────────────────────────────────────── */
  const spawnFloat = (val,multi) => {
    const id=Date.now()+Math.random();
    setXpFloats(p=>[...p,{id,x:80+Math.random()*220,y:280+Math.random()*120,value:val,multi}]);
    setTimeout(()=>setXpFloats(p=>p.filter(f=>f.id!==id)),1300);
  };
  const triggerToast = (icon,title,desc) => setToast({icon,title,desc});

  const completeTask = (id) => {
    setTasks(prev=>prev.map(t=>{
      if (t.id!==id||t.done) return t;
      setConfetti(true); setTimeout(()=>setConfetti(false),1100);
      setCombo(c=>c+1);
      if (comboTimer) clearTimeout(comboTimer);
      setComboTimer(setTimeout(()=>setCombo(0),60000));
      const earnedBonus = effectiveMulti>1?t.points*(effectiveMulti-1):0;
      const earnedXP = t.points+earnedBonus;
      spawnFloat(earnedXP,effectiveMulti);
      if (earnedBonus>0) setBonusXP(p=>p+earnedBonus);
      if (multiplier>1) setMultiplier(1);
      setBoss(b=>{ const dmg=Math.round(b.maxHp/b.tasksNeeded); const newHp=Math.max(0,b.hp-dmg); if(newHp<=0&&b.hp>0){triggerToast("🐉","Boss Defeated!",`+${b.reward} XP earned!`);setBonusXP(p=>p+b.reward);} return {...b,hp:newHp,tasksDone:b.tasksDone+1}; });
      setTotalLifetimeTasks(p=>p+1);
      setLootCount(p=>{ if((p+1)%5===0) setTimeout(()=>setShowLoot(true),800); return p+1; });
      const nc=combo+1;
      if(nc===3) triggerToast("🔥","3× Combo!","You're on fire!");
      if(nc===5) triggerToast("⚡","ULTRA COMBO!","4× XP multiplier!");
      setDailyChallenges(p=>p.map(ch=>{ if(ch.done)return ch; if(ch.id===3&&t.category==="Health")return{...ch,done:true}; return ch; }));
      const now=new Date();
      setActivityLog(p=>[{task:t.title,points:earnedXP,time:`Today, ${now.toLocaleTimeString([],{hour:"numeric",minute:"2-digit"})}`,icon:t.category==="Work"?"💼":t.category==="Health"?"💪":t.category==="Learning"?"📚":"🏠"},...p]);
      return{...t,done:true,bonusEarned:earnedBonus};
    }));
  };

  const toggleTask = (id) => {
    const task=tasks.find(t=>t.id===id); if(!task) return;
    if (!task.done) {
      setProofText(""); setProofRating(0); setProofHover(0); setProofPhoto(null);
      setProofModal({task,pendingId:id});
    } else {
      setTasks(prev=>prev.map(t=>{ if(t.id!==id)return t; if(t.bonusEarned>0)setBonusXP(p=>Math.max(0,p-t.bonusEarned)); setBoss(b=>{const dmg=Math.round(b.maxHp/b.tasksNeeded);return{...b,hp:Math.min(b.maxHp,b.hp+dmg),tasksDone:Math.max(0,b.tasksDone-1)};}); setTotalLifetimeTasks(p=>Math.max(0,p-1)); setActivityLog(p=>p.filter(a=>a.task!==t.title||!a.time.startsWith("Today"))); return{...t,done:false,bonusEarned:0}; }));
    }
  };

  const addTask = () => {
    if (!newTask.title.trim()) return;
    setTasks(p=>[...p,{id:Date.now(),title:newTask.title,desc:newTask.desc,time:new Date(`2025-01-01T${newTask.time}`).toLocaleTimeString([],{hour:"numeric",minute:"2-digit"}),points:newTask.priority==="high"?80:newTask.priority==="medium"?50:25,project:newTask.category,streak:0,done:false,priority:newTask.priority,category:newTask.category}]);
    setNewTask({title:"",desc:"",category:"Work",frequency:"Daily",time:"09:00",priority:"medium"}); setShowAdd(false);
  };

  const handleSpinResult = (seg) => { setSpinUsed(true); if(seg.type==="xp")setBonusXP(p=>p+seg.value); if(seg.type==="multi")setMultiplier(seg.value); if(seg.type==="shield")setShields(p=>p+1); };

  const unlockSkill = (id) => { setSkillTree(p=>p.map(s=>{ if(s.id!==id||s.unlocked||skillPoints<s.cost)return s; setSkillPoints(p=>p-s.cost); triggerToast(s.icon,`${s.name} Unlocked!`,s.desc); return{...s,unlocked:true}; })); };

  const clearAllTasks = () => {
    setTasks([]);
    setActivityLog([]);
    setBonusXP(0);
    setCombo(0);
    setMultiplier(1);
    setBoss(BOSS_INIT);
    setTotalLifetimeTasks(0);
    setLootCount(0);
    setShowClearConfirm(false);
    triggerToast("🗑️", "Fresh Start!", "All quests cleared. Import or create new ones.");
  };

  /* ─────────────────────────── RENDER ──────────────── */
  return (
    <>
      <style>{GLOBAL_CSS}</style>

      <div className="app">
        <ConfettiBurst show={confetti}/>
        <XPFloat floats={xpFloats}/>
        <Toast toast={toast} onDone={()=>setToast(null)}/>
        <SpinWheel visible={showSpin} onClose={()=>setShowSpin(false)} onResult={handleSpinResult}/>
        <LootBox visible={showLoot} onClose={()=>setShowLoot(false)} onOpen={(item)=>{ if(item.name.includes("XP"))setBonusXP(p=>p+150); if(item.name.includes("Shield"))setShields(p=>p+1); if(item.name.includes("Multiplier"))setMultiplier(3); triggerToast(item.icon,item.name,item.desc); }}/>

        {/* ════ HEADER ════ */}
        <header className="hdr">
          <div>
            <div className="hdr-brand">QUESTLOG</div>
            <div className="hdr-date">{new Date().toLocaleDateString("en-US",{weekday:"short",month:"short",day:"numeric"})}</div>
            <div className="hdr-lvl-row">
              <div className="hdr-lvl-bar"><div className="hdr-lvl-fill" style={{width:`${(xpInLevel/200)*100}%`}}/></div>
              <span className="hdr-lvl-lbl">LVL {level}</span>
            </div>
          </div>
          <div className="hdr-actions">
            {!spinUsed && (
              <button className="icon-btn gold-border anim-chest" onClick={()=>setShowSpin(true)}>
                <span style={{fontSize:15}}>🎰</span>
              </button>
            )}
            <button className="icon-btn accent-border" onClick={()=>setShowChallenges(true)}>
              <span style={{fontSize:15}}>📜</span>
              {dailyChallenges.filter(c=>!c.done).length>0 && (
                <span className="notif-dot" style={{background:"var(--purple)"}}>{dailyChallenges.filter(c=>!c.done).length}</span>
              )}
            </button>
            <button className="icon-btn" onClick={()=>setShowNotif(true)}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
              {unread>0 && <span className="notif-dot">{unread}</span>}
            </button>
          </div>
        </header>

        {/* ════ NOTIFICATION PANEL ════ */}
        {showNotif && (
          <div className="panel anim-slideUp">
            <div className="panel-hdr">
              <span className="panel-title">Notifications</span>
              <div className="gap-row">
                <Button variant="outline" size="sm" className="h-7 text-[10px] text-[var(--accent)] border-[rgba(6,214,160,0.3)]" onClick={()=>setNotifs(p=>p.map(n=>({...n,read:true})))}>Mark read</Button>
                <Button variant="ghost" size="sm" className="h-7 text-[10px]" onClick={()=>setShowNotif(false)}>✕</Button>
              </div>
            </div>
            <div className="panel-body stagger">
              {notifs.map((n,i)=>(
                <div key={n.id} className={`notif-item anim-slideDown ${!n.read?"unread":""}`}>
                  <div className="notif-text">{n.text}</div>
                  <div className="notif-time">{n.time}</div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* ════ DAILY OFFERS PANEL ════ */}
        {showChallenges && (
          <div className="panel anim-slideUp">
            <div className="panel-hdr">
              <span className="panel-title">📜 Daily Offers</span>
              <div className="gap-row">
                <span style={{fontFamily:"var(--mono)",fontSize:10,fontWeight:700,color:"var(--accent)"}}>{dailyChallenges.filter(c=>c.done).length}/{dailyChallenges.length} done</span>
                <Button variant="ghost" size="sm" className="h-7 text-[10px]" onClick={()=>setShowChallenges(false)}>✕</Button>
              </div>
            </div>
            <div className="panel-body">
              {/* Rank bar */}
              <div className="rank-bar">
                <div className="rank-icon">{currentRank.icon}</div>
                <div className="fill">
                  <div className="rank-name" style={{color:currentRank.color}}>{currentRank.name}</div>
                  <div className="rank-to-next">{nextRank?`${nextRank.min-totalXP} XP to ${nextRank.name}`:"Max rank!"}</div>
                  {nextRank&&<div className="rank-prog"><div className="rank-prog-fill" style={{width:`${((totalXP-currentRank.min)/(nextRank.min-currentRank.min))*100}%`,background:currentRank.color}}/></div>}
                </div>
              </div>

              {/* Daily goal + streak */}
              <div className="daily-row">
                <div className="daily-card goal">
                  <div className="ring-wrap">
                    <svg width="30" height="30" viewBox="0 0 30 30"><circle cx="15" cy="15" r="11" fill="none" stroke="var(--surface3)" strokeWidth="3"/><circle cx="15" cy="15" r="11" fill="none" stroke="var(--accent)" strokeWidth="3" strokeDasharray={`${(Math.min(dailyDone,5)/5)*69.1} 69.1`} strokeDashoffset="17.3" strokeLinecap="round" style={{transition:"stroke-dasharray 0.8s"}}/></svg>
                    <div className="ring-num">{dailyDone}/5</div>
                  </div>
                  <div><div className="daily-label">Daily Goal</div><div className="daily-sub">{dailyDone>=5?"Done! 🎉":`${5-dailyDone} left`}</div></div>
                </div>
                <div className="daily-card streak">
                  <div style={{fontSize:18}}>🔥</div>
                  <div><div className="daily-label" style={{color:"var(--gold)"}}>30 Days</div><div className="daily-sub">{shields>0?`🛡️ ${shields} shield${shields>1?"s":""}`:""}</div></div>
                </div>
              </div>

              {/* Pet */}
              <div className="pet-card">
                <div className="anim-bobble" style={{fontSize:pet.size}}>{pet.emoji}</div>
                <div className="fill">
                  <div className="pet-name">{pet.name} <span style={{fontSize:8,color:"var(--subtle)"}}>{(()=>{ const next=PET_STAGES.find(p=>p.minTasks>totalLifetimeTasks); return next?`— ${next.minTasks-totalLifetimeTasks} to ${next.emoji}`:"— Max!"; })()}</span></div>
                  <div className="pet-progress"><div className="pet-fill" style={{width:`${(()=>{ const next=PET_STAGES.find(p=>p.minTasks>totalLifetimeTasks); const prevMin=pet.minTasks; const nextMin=next?next.minTasks:pet.minTasks+50; return((totalLifetimeTasks-prevMin)/(nextMin-prevMin))*100; })()}%`}}/></div>
                </div>
              </div>

              {/* Challenge progress ring */}
              <Card className="mb-3 bg-[rgba(131,56,236,0.06)] border-[rgba(131,56,236,0.18)]">
                <CardContent className="p-4 flex items-center gap-4">
                  <div className="chal-ring-wrap">
                    <svg width="52" height="52" viewBox="0 0 52 52"><circle cx="26" cy="26" r="21" fill="none" stroke="var(--surface3)" strokeWidth="4"/><circle cx="26" cy="26" r="21" fill="none" stroke="var(--purple)" strokeWidth="4" strokeDasharray={`${(dailyChallenges.filter(c=>c.done).length/dailyChallenges.length)*131.9} 131.9`} strokeDashoffset="33" strokeLinecap="round" style={{transition:"stroke-dasharray 0.8s",transform:"rotate(-90deg)",transformOrigin:"center"}}/></svg>
                    <div className="chal-ring-num">{dailyChallenges.filter(c=>c.done).length}/{dailyChallenges.length}</div>
                  </div>
                  <div>
                    <div style={{fontWeight:800,fontSize:13}}>Daily Challenges</div>
                    <div style={{fontSize:10,color:"var(--subtle)",marginTop:2}}>Resets in <span style={{color:"var(--gold)",fontFamily:"var(--mono)",fontWeight:700}}>08:14:32</span></div>
                    <div style={{fontSize:9,color:"var(--subtle)",marginTop:4}}>Complete all 3 for a bonus 🎁</div>
                  </div>
                </CardContent>
              </Card>

              {/* Challenge list */}
              {dailyChallenges.map((ch,i)=>(
                <div key={ch.id} className={`chal-card anim-slideDown ${ch.done?"done":""}`} style={{animationDelay:`${i*0.05}s`}}>
                  <div className="chal-icon-box">{ch.icon}</div>
                  <div className="fill">
                    <div className="chal-title">{ch.title}{ch.done&&<span className="done-pill">DONE</span>}</div>
                    <div className="chal-desc">{ch.desc}</div>
                  </div>
                  <div style={{textAlign:"center"}}>
                    <div className="chal-xp" style={{color:ch.done?"var(--accent)":"var(--gold)"}}>{ch.done?"✓":`+${ch.reward}`}</div>
                    <div className="chal-xp-lbl">XP</div>
                  </div>
                </div>
              ))}

              <div className="loot-banner">
                <div style={{fontSize:26}}>🎁</div>
                <div className="fill"><div className="loot-banner-title">Complete All Challenges</div><div className="loot-banner-sub">Earn a mystery loot box</div></div>
                <div className="loot-status" style={{color:dailyChallenges.every(c=>c.done)?"var(--accent)":"var(--gold)",background:dailyChallenges.every(c=>c.done)?"rgba(6,214,160,0.1)":"rgba(255,190,11,0.1)"}}>{dailyChallenges.every(c=>c.done)?"✓ Claim":"🔒 Locked"}</div>
              </div>
            </div>
          </div>
        )}

        {/* ════ MAIN PAGES ════ */}
        <main className="page-content">

          {/* ── TASKS TAB ── */}
          {tab==="tasks" && (
            <div className="px gap-col">
              {combo>=2 && (
                <div className="combo-banner anim-pulse-scale">
                  <div style={{fontSize:16}}>🔥</div>
                  <div className="fill"><div className="combo-label">{combo}× COMBO!</div><div className="combo-sub">Keep going!</div></div>
                  <div className="combo-multi">{comboMulti}×</div>
                </div>
              )}
              {multiplier>1 && (
                <div className="multi-banner">
                  <span>✨</span>
                  <span>{multiplier}× Multiplier Active</span>
                  <span className="lbl">Next task</span>
                </div>
              )}

              {/* Boss card */}
              <div className={`boss-card ${boss.hp>0?"anim-glow-border-red":""}`}>
                <div className="boss-header">
                  <span className="section-label" style={{margin:0}}>⚔️ Weekly Boss</span>
                  <Badge variant="outline" className="text-[var(--red)] border-[var(--red)] font-mono text-[9px]">+{boss.reward} XP</Badge>
                </div>
                <div className={`boss-emoji ${boss.hp>0?"anim-boss-idle":""}`} style={{filter:boss.hp<=0?"grayscale(1)":"none",opacity:boss.hp<=0?0.4:1}}>{boss.emoji}</div>
                <div className="boss-name">{boss.name}</div>
                {boss.hp<=0&&<div className="boss-defeated">🎉 DEFEATED!</div>}
                <div className="boss-hp-row">
                  <span className="boss-hp-lbl">HP</span>
                  <span style={{fontFamily:"var(--mono)",fontSize:9,fontWeight:700,color:bossHpPct>50?"var(--red)":bossHpPct>25?"var(--orange)":"var(--accent)"}}>{Math.max(0,boss.hp)}/{boss.maxHp}</span>
                </div>
                <Progress value={bossHpPct} className="h-2" style={{"--progress-bg":"var(--surface3)"}}/>
                <div className="boss-stats"><b style={{color:"var(--gold)"}}>{boss.tasksDone}</b>/{boss.tasksNeeded} tasks · <b style={{color:"var(--red)"}}>{Math.round(boss.maxHp/boss.tasksNeeded)}</b> DMG each</div>
              </div>

              <div className="task-counter">
                <span className="done-lbl">{tasks.filter(t=>t.done).length}/{tasks.length} DONE</span>
                <span className="xp-lbl">+<AnimNum value={totalXP}/> XP</span>
              </div>

              <div className="stagger">
                {tasks.map((task,i)=>(
                  <div key={task.id} className={`task-card anim-slideDown pri-${task.priority} ${task.done?"is-done":""}`} style={{animationDelay:`${i*0.04}s`}}>
                    <div className="task-row">
                      <div className={`task-check ${task.done?"checked":""}`} onClick={()=>toggleTask(task.id)}>
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3" strokeLinecap="round"><polyline points="20 6 9 17 4 12"/></svg>
                      </div>
                      <div className="fill">
                        <div className="task-title">{task.title}</div>
                        <div className="task-meta">
                          <span className="chip chip-default">🕐 {task.time}</span>
                          <span className="chip chip-xp">⚡ {task.points}{effectiveMulti>1&&!task.done?`×${effectiveMulti}`:""}</span>
                          <span className="chip chip-project">📁 {task.project}</span>
                          <span className="chip chip-streak">🔥 {task.streak}d</span>
                        </div>
                      </div>
                      <button className="task-expand-btn" onClick={()=>setOpenDesc(openDesc===task.id?null:task.id)}>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                      </button>
                    </div>
                    {openDesc===task.id&&<div className="task-desc anim-scaleIn">{task.desc}</div>}
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* ── STATS TAB ── */}
          {tab==="stats" && (
            <div className="px">
              <Tabs value={statsTab} onValueChange={setStatsTab} className="w-full">
                <TabsList className="w-full mb-4 bg-[var(--surface)] border border-[var(--border)]">
                  {["overview","heatmap","trends","skills"].map(t=>(
                    <TabsTrigger key={t} value={t} className="flex-1 text-[10px] data-[state=active]:bg-[var(--surface3)] data-[state=active]:text-[var(--text)]">
                      {t.charAt(0).toUpperCase()+t.slice(1)}
                    </TabsTrigger>
                  ))}
                </TabsList>

                <TabsContent value="overview">
                  <Card className="bg-[var(--surface)] border-[var(--border)] mb-3"><CardContent className="p-4"><div className="section-label">Completion Rates</div><div style={{display:"flex",justifyContent:"space-around"}}><Gauge value={78} max={100} label="DAILY" color="var(--accent)"/><Gauge value={85} max={100} label="WEEKLY" color="var(--blue)"/><Gauge value={62} max={100} label="MONTH" color="var(--purple)"/></div></CardContent></Card>
                  <Card className="bg-[var(--surface)] border-[var(--border)] mb-3"><CardContent className="p-4"><div className="section-label">Category Breakdown</div><div style={{display:"flex",alignItems:"center",gap:14}}><DonutChart data={CATEGORY_DATA}/><div style={{flex:1}}>{CATEGORY_DATA.map(c=><div key={c.name} style={{display:"flex",alignItems:"center",gap:6,marginBottom:7}}><div style={{width:7,height:7,borderRadius:2,background:c.color}}/><span style={{fontSize:10,fontWeight:600,flex:1}}>{c.name}</span><span style={{fontSize:10,fontFamily:"var(--mono)",fontWeight:700,color:c.color}}>{c.value}%</span></div>)}</div></div></CardContent></Card>
                  <Card className="bg-[var(--surface)] border-[var(--border)]"><CardContent className="p-4"><div className="section-label">Projects</div>{PROJECT_STATS.map((p,i)=><div className="bar-row" key={p.name}><div className="bar-label">{p.name}</div><div className="bar-track"><div className="bar-fill" style={{width:`${(p.completed/p.total)*100}%`,background:p.color,transitionDelay:`${i*0.1}s`}}>{p.completed}/{p.total}</div></div></div>)}</CardContent></Card>
                </TabsContent>

                <TabsContent value="heatmap">
                  <Card className="bg-[var(--surface)] border-[var(--border)] mb-3"><CardContent className="p-4"><div className="section-label">Activity — 12 Weeks</div><div style={{overflowX:"auto"}}><HeatmapGrid data={heatmap}/></div><div style={{display:"flex",alignItems:"center",gap:3,marginTop:6,justifyContent:"flex-end"}}><span style={{fontSize:7,color:"var(--subtle)",fontFamily:"var(--mono)"}}>Less</span>{[0.03,0.15,0.35,0.6,0.9].map((o,i)=><div key={i} style={{width:9,height:9,borderRadius:2,background:`rgba(6,214,160,${o})`}}/>)}<span style={{fontSize:7,color:"var(--subtle)",fontFamily:"var(--mono)"}}>More</span></div></CardContent></Card>
                  <Card className="bg-[var(--surface)] border-[var(--border)]"><CardContent className="p-4"><div className="section-label">Weekly XP</div><Sparkline data={WEEKLY_XP}/><div style={{display:"flex",justifyContent:"space-between",marginTop:4}}>{WEEKLY_XP.map(d=><span key={d.day} style={{fontSize:8,color:"var(--subtle)",fontFamily:"var(--mono)",fontWeight:600}}>{d.day}</span>)}</div></CardContent></Card>
                </TabsContent>

                <TabsContent value="trends">
                  <Card className="bg-[var(--surface)] border-[var(--border)] mb-3"><CardContent className="p-4"><div className="section-label">Productivity by Hour</div><div style={{display:"flex",alignItems:"flex-end",gap:2,height:65}}>{HOURLY_DATA.map((h,i)=>{ const mx=Math.max(...HOURLY_DATA.map(d=>d.v)); return <div key={i} style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",gap:2}}><div style={{width:"100%",borderRadius:"3px 3px 1px 1px",background:h.v>=7?"var(--accent)":h.v>=4?"var(--blue)":"var(--surface3)",height:`${(h.v/mx)*100}%`,transition:`height 0.8s ease ${i*0.03}s`,minHeight:2}}/><div style={{fontSize:6,color:"var(--subtle)",fontFamily:"var(--mono)"}}>{h.h}</div></div>; })}</div></CardContent></Card>
                  <Card className="bg-[var(--surface)] border-[var(--border)]"><CardContent className="p-4"><div className="section-label">Best Days</div>{[{d:"Mon",v:8},{d:"Tue",v:10},{d:"Wed",v:6},{d:"Thu",v:12},{d:"Fri",v:9},{d:"Sat",v:4},{d:"Sun",v:7}].map((item,i)=><div className="bar-row" key={item.d}><div className="bar-label">{item.d}</div><div className="bar-track"><div className="bar-fill" style={{width:`${(item.v/12)*100}%`,background:item.v>=10?"var(--gold)":item.v>=7?"var(--accent)":"var(--surface3)",transitionDelay:`${i*0.08}s`}}>{item.v}</div></div></div>)}</CardContent></Card>
                </TabsContent>

                <TabsContent value="skills">
                  <Card className="bg-[var(--surface)] border-[var(--border)] mb-3">
                    <CardContent className="p-4">
                      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:12}}>
                        <div className="section-label" style={{margin:0}}>🌳 Skill Tree</div>
                        <Badge variant="outline" className="text-[var(--gold)] border-[rgba(255,190,11,0.4)] font-mono">⭐ {skillPoints} SP</Badge>
                      </div>
                      <div className="skill-grid">
                        {skillTree.map(s=>(
                          <div key={s.id} className={`skill-node ${s.unlocked?"unlocked":"locked"}`} onClick={()=>!s.unlocked&&unlockSkill(s.id)}>
                            <div className="skill-icon">{s.icon}</div>
                            <div className="skill-name">{s.name}</div>
                            <div className="skill-cost" style={{color:s.unlocked?"var(--accent)":skillPoints>=s.cost?"var(--gold)":"var(--subtle)"}}>{s.unlocked?"✓":`${s.cost} SP`}</div>
                          </div>
                        ))}
                      </div>
                    </CardContent>
                  </Card>
                  <Card className="bg-[var(--surface)] border-[var(--border)]">
                    <CardContent className="p-4">
                      <div className="section-label">Rank Tiers</div>
                      <div className="rank-tiers">
                        {RANK_TIERS.map(r=>(
                          <div key={r.name} className={`rank-tier-box ${totalXP>=r.min?"earned":""}`} style={{borderColor:totalXP>=r.min?`${r.color}40`:"var(--border)",opacity:totalXP>=r.min?1:0.28}}>
                            <div className="rank-tier-icon">{r.icon}</div>
                            <div className="rank-tier-name" style={{color:totalXP>=r.min?r.color:"var(--subtle)"}}>{r.name}</div>
                            <div className="rank-tier-min">{r.min}+</div>
                          </div>
                        ))}
                      </div>
                    </CardContent>
                  </Card>
                </TabsContent>
              </Tabs>
            </div>
          )}

          {/* ── LEADERBOARD TAB ── */}
          {tab==="leaderboard" && (
            <div className="px">
              <Card className="bg-[var(--surface)] border-[var(--border)] mb-3">
                <CardContent className="p-4">
                  <div style={{display:"flex",alignItems:"flex-end",justifyContent:"center",gap:5,paddingTop:6}}>
                    {[1,0,2].map(idx=>{ const u=LEADERBOARD[idx]; const h=idx===0?65:idx===1?46:32; const c=idx===0?"rgba(255,215,0,0.1)":idx===1?"rgba(170,170,170,0.1)":"rgba(205,127,50,0.1)"; return <div key={u.name} style={{textAlign:"center",flex:1}}>{idx===0&&<div style={{fontSize:9}}>👑</div>}<div style={{fontSize:idx===0?30:24}}>{u.avatar}</div><div style={{fontSize:9,fontWeight:800,marginTop:2}}>{u.name}</div><div style={{fontFamily:"var(--mono)",fontSize:8,color:"var(--accent)",fontWeight:700}}>{u.xp}</div><div style={{height:h,background:c,borderRadius:"7px 7px 0 0",marginTop:4,display:"flex",alignItems:"center",justifyContent:"center"}}><span style={{fontFamily:"var(--mono)",fontSize:idx===0?18:14,fontWeight:800,color:idx===0?"var(--gold)":idx===1?"#aaa":"#cd7f32"}}>{idx+1}</span></div></div>; })}
                  </div>
                </CardContent>
              </Card>

              <Tabs value={lbFilter} onValueChange={setLbFilter} className="w-full mb-3">
                <TabsList className="w-full bg-[var(--surface)] border border-[var(--border)]">
                  {["weekly","monthly","all-time"].map(f=><TabsTrigger key={f} value={f} className="flex-1 text-[10px] data-[state=active]:bg-[var(--purple)] data-[state=active]:text-white">{f==="weekly"?"Weekly":f==="monthly"?"Monthly":"All Time"}</TabsTrigger>)}
                </TabsList>
              </Tabs>

              <div className="stagger">
                {LEADERBOARD.map((u,i)=>(
                  <div key={u.name} className={`lb-card anim-slideDown ${u.name==="You"?"you":""}`} style={{animationDelay:`${i*0.05}s`}}>
                    <div className={`lb-rank ${i===0?"g":i===1?"s":i===2?"b":""}`}>#{i+1}</div>
                    <div className="lb-av">{u.avatar}</div>
                    <div className="fill">
                      <div className="lb-name">{u.name}</div>
                      <div className="lb-xp">{u.xp.toLocaleString()} XP</div>
                      <div className="lb-meta"><span>🔥 {u.streak}d</span><span>📋 {u.tasksWeek}/wk</span></div>
                    </div>
                    {u.name!=="You"
                      ? <button className={`challenge-btn ${challengeSent===u.name?"sent":""}`} onClick={()=>setChallengeSent(u.name)}>{challengeSent===u.name?"✓":"⚔️"}</button>
                      : <div className="lb-level">LV.{u.level}</div>
                    }
                  </div>
                ))}
              </div>
              <button className={`invite-btn ${inviteSent?"sent":""}`} onClick={()=>setInviteSent(true)}>{inviteSent?"✓ Link Copied!":"👋 Invite Friends"}</button>
            </div>
          )}

          {/* ── PROFILE TAB ── */}
          {tab==="profile" && (
            <div className="px">
              <div className="profile-hdr">
                <div className="avatar-ring anim-float"><div className="avatar-inner">🧑‍💻</div></div>
                <div className="profile-name">Alex Chen</div>
                <div className="profile-tag">{currentRank.icon} {currentRank.name} · @questmaster</div>
              </div>
              <div className="xp-bar-card">
                <div className="xp-bar-top"><span className="xp-level">Level {level}</span><span className="xp-num">{xpInLevel}/200 XP</span></div>
                <Progress value={(xpInLevel/200)*100} className="h-1.5 anim-shimmer"/>
              </div>
              <div className="stat-grid">
                <Card className="bg-[var(--surface)] border-[var(--border)]"><CardContent className="p-3 text-center"><div className="stat-val" style={{color:"var(--accent)"}}><AnimNum value={totalXP}/></div><div className="stat-lbl">Total XP</div></CardContent></Card>
                <Card className="bg-[var(--surface)] border-[var(--border)]"><CardContent className="p-3 text-center"><div className="stat-val" style={{color:"var(--blue)"}}><AnimNum value={totalLifetimeTasks}/></div><div className="stat-lbl">Tasks</div></CardContent></Card>
                <Card className="bg-[var(--surface)] border-[var(--border)]"><CardContent className="p-3 text-center"><div className="stat-val" style={{color:"var(--gold)"}}>30</div><div className="stat-lbl">Streak</div></CardContent></Card>
                <Card className="bg-[var(--surface)] border-[var(--border)]"><CardContent className="p-3 text-center"><div className="stat-val" style={{color:"var(--purple)"}}>#1</div><div className="stat-lbl">Rank</div></CardContent></Card>
              </div>
              <Card className="bg-[var(--surface)] border-[var(--border)] mb-3"><CardContent className="p-4 text-center"><div className="anim-bobble" style={{fontSize:44,marginBottom:6}}>{pet.emoji}</div><div style={{fontWeight:800,fontSize:14}}>{pet.name}</div></CardContent></Card>

              <Tabs value={profileTab} onValueChange={setProfileTab} className="w-full">
                <TabsList className="w-full mb-3 bg-[var(--surface)] border border-[var(--border)]">
                  {["activity","badges","milestones"].map(t=><TabsTrigger key={t} value={t} className="flex-1 text-[10px] data-[state=active]:bg-[var(--surface3)] data-[state=active]:text-[var(--text)]">{t.charAt(0).toUpperCase()+t.slice(1)}</TabsTrigger>)}
                </TabsList>
                <TabsContent value="activity" className="stagger">
                  {activityLog.map((a,i)=>(
                    <div key={i} className="activity-item anim-slideDown" style={{animationDelay:`${i*0.03}s`}}>
                      <div className="activity-icon">{a.icon}</div>
                      <div className="fill"><div className="activity-title">{a.task}</div><div className="activity-time">{a.time}</div></div>
                      <div className="activity-pts">+{a.points}</div>
                    </div>
                  ))}
                </TabsContent>
                <TabsContent value="badges">
                  <div className="section-label">Badges ({BADGES.filter(b=>b.unlocked).length}/{BADGES.length})</div>
                  <div className="badges-grid">
                    {BADGES.map(b=><div key={b.name} className={`badge-box ${!b.unlocked?"locked":""}`}><div className="badge-icon">{b.icon}</div><div className="badge-name">{b.name}</div></div>)}
                  </div>
                </TabsContent>
                <TabsContent value="milestones" className="stagger">
                  {[{t:"First Quest",i:"🌱",d:true,dt:"Jan 5"},{t:"Week Warrior",i:"⚔️",d:true,dt:"Jan 12"},{t:"Century Club",i:"💯",d:true,dt:"Feb 3"},{t:"XP Master",i:"⚡",d:true,dt:"Feb 18"},{t:"Month Monarch",i:"👑",d:true,dt:"Mar 1"},{t:"Dragon Tamer",i:"🐲",d:false},{t:"Legendary",i:"🏰",d:false}].map((m,i)=>(
                    <div key={m.t} className="milestone-row anim-slideDown" style={{animationDelay:`${i*0.04}s`,opacity:m.d?1:0.28}}>
                      <div className="milestone-icon">{m.i}</div>
                      <div className="milestone-title">{m.t}</div>
                      <div className="milestone-date" style={{color:m.d?"var(--accent)":"var(--subtle)"}}>{m.d?m.dt:"🔒"}</div>
                    </div>
                  ))}
                </TabsContent>
              </Tabs>

              {/* Danger Zone */}
              <div className="danger-zone anim-fadeUp">
                <div className="danger-zone-title">⚠ Danger Zone</div>
                <div className="danger-zone-row">
                  <div className="fill">
                    <div className="dz-label">Clear All Quests</div>
                    <div className="dz-sub">Wipe the board for a fresh start — import or create new tasks after.</div>
                  </div>
                  <button className="btn-danger" onClick={()=>setShowClearConfirm(true)}>
                    🗑️ Clear All
                  </button>
                </div>
              </div>
            </div>
          )}
        </main>

        {/* ════ CLEAR CONFIRM DIALOG ════ */}
        {showClearConfirm && (
          <div className="confirm-overlay" onClick={e=>{ if(e.target===e.currentTarget) setShowClearConfirm(false); }}>
            <div className="confirm-dialog">
              <div className="cd-icon">🗑️</div>
              <div className="cd-title">Clear Everything?</div>
              <div className="cd-body">
                This will permanently remove all <span className="cd-count">{tasks.length} quest{tasks.length!==1?"s":""}</span>, activity history, and reset your progress.<br/><br/>
                Use the <strong style={{color:"var(--text)"}}>+ button</strong> or <strong style={{color:"var(--text)"}}>Import</strong> after to start fresh.
              </div>
              <button className="btn-danger-confirm" onClick={clearAllTasks}>
                🗑️ Yes, Clear All Quests
              </button>
              <button className="btn-ghost" style={{marginTop:0}} onClick={()=>setShowClearConfirm(false)}>
                Cancel
              </button>
            </div>
          </div>
        )}
        {proofModal && (
          <div className="modal-overlay anim-fadeIn" onClick={e=>{ if(e.target===e.currentTarget) setProofModal(null); }}>
            <div className="modal-sheet anim-slideUp">
              <div className="modal-handle"/>
              <Card className="bg-[var(--surface2)] border-[var(--border)] mb-5">
                <CardContent className="p-3 flex items-center gap-3">
                  <div style={{fontSize:22}}>{proofModal.task.category==="Work"?"💼":proofModal.task.category==="Health"?"💪":proofModal.task.category==="Learning"?"📚":"🏠"}</div>
                  <div className="fill">
                    <div style={{fontWeight:800,fontSize:13}}>{proofModal.task.title}</div>
                    <div style={{fontSize:9,color:"var(--subtle)",marginTop:1,fontFamily:"var(--mono)"}}>+{proofModal.task.points} XP · {proofModal.task.project}</div>
                  </div>
                  <div style={{fontSize:18}}>⚡</div>
                </CardContent>
              </Card>

              <div className="modal-title" style={{marginBottom:3}}>🔍 Quest Complete!</div>
              <p style={{fontSize:11,color:"var(--muted)",marginBottom:18}}>Drop a quick proof — what did you actually do?</p>

              <div className="field">
                <label className="field-label">How hard was it?</label>
                <div style={{display:"flex",gap:6}}>
                  {["😴","🙂","😤","🔥","💀"].map((emoji,i)=>(
                    <button key={i} className={`rating-btn ${(proofHover||proofRating)>i?"active":""}`}
                      onClick={()=>setProofRating(i+1)}
                      onMouseEnter={()=>setProofHover(i+1)}
                      onMouseLeave={()=>setProofHover(0)}>
                      {emoji}
                    </button>
                  ))}
                </div>
                {proofRating>0&&<div style={{fontSize:9,color:"var(--accent)",marginTop:5,fontFamily:"var(--mono)",fontWeight:700,textAlign:"center"}}>{["Easy peasy","Not bad","Worked hard","Crushed it 🔥","Absolute beast 💀"][proofRating-1]}</div>}
              </div>

              <div className="field">
                <label className="field-label">Quick note <span className="opt">(optional)</span></label>
                <textarea className="field-textarea" rows={3} placeholder={`What did you actually do for "${proofModal.task.title}"?`} value={proofText} onChange={e=>setProofText(e.target.value)}/>
                <input ref={proofCamRef} type="file" accept="image/*" capture="environment" style={{display:"none"}} onChange={e=>{ const f=e.target.files?.[0]; if(f) setProofPhoto(URL.createObjectURL(f)); }}/>
                <div style={{display:"flex",justifyContent:"flex-end",paddingTop:8}}>
                  {!proofPhoto
                    ? <button className="cam-btn anim-cam" onClick={()=>proofCamRef.current?.click()} title="+20 XP for photo proof">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/><circle cx="12" cy="13" r="4"/></svg>
                      </button>
                    : <div style={{position:"relative",width:32,height:32}}>
                        <img src={proofPhoto} alt="proof" style={{width:32,height:32,borderRadius:9,objectFit:"cover",border:"1.5px solid var(--accent)",display:"block"}}/>
                        <button onClick={()=>{ setProofPhoto(null); if(proofCamRef.current) proofCamRef.current.value=""; }} style={{position:"absolute",top:-5,right:-5,width:14,height:14,borderRadius:"50%",background:"var(--red)",border:"none",color:"white",fontSize:8,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center"}}>✕</button>
                      </div>
                  }
                </div>
              </div>

              {(proofRating>0||proofText.trim().length>0||proofPhoto)&&(
                <div className="proof-bonus anim-scaleIn">
                  <span>✨</span>
                  <span>+{(proofRating>0?10:0)+(proofText.trim().length>10?15:0)+(proofPhoto?20:0)} Proof Bonus XP</span>
                </div>
              )}

              <button className="btn-primary" onClick={()=>{ const b=(proofRating>0?10:0)+(proofText.trim().length>10?15:0)+(proofPhoto?20:0); if(b>0)setBonusXP(p=>p+b); completeTask(proofModal.pendingId); setProofModal(null); }}>
                ⚡ Submit & Claim XP
              </button>
              <button className="btn-ghost" onClick={()=>{ completeTask(proofModal.pendingId); setProofModal(null); }}>Skip for now</button>
            </div>
          </div>
        )}

        {/* ════ ADD TASK MODAL ════ */}
        {showAdd && (
          <div className="modal-overlay anim-fadeIn" onClick={e=>{ if(e.target===e.currentTarget){setShowAdd(false);setShowDemoSelect(false);} }}>
            <div className="modal-sheet anim-slideUp">
              <div className="modal-handle"/>
              <div className="gap-row" style={{marginBottom:16}}>
                <span className="modal-title fill">⚔️ New Quest</span>
                <button className={`import-btn ${showDemoSelect?"open":""}`} onClick={()=>setShowDemoSelect(v=>!v)}>
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                  Import
                </button>
              </div>

              {showDemoSelect&&(
                <div className="demo-picker anim-scaleIn">
                  <div className="demo-picker-hdr">Select a Demo</div>
                  {DEMO_SETS.map(demo=>(
                    <button key={demo.id} className="demo-row" onClick={()=>{ const t=demo.tasks.map((t,i)=>({...t,id:Date.now()+i,streak:0,done:false,bonusEarned:0})); setTasks(p=>[...p,...t]); triggerToast(demo.icon,`${demo.name} Imported!`,`${demo.tasks.length} quests added`); setShowAdd(false); setShowDemoSelect(false); }}>
                      <div className="demo-icon-box" style={{background:`${demo.color}18`,border:`1px solid ${demo.color}40`}}>{demo.icon}</div>
                      <div className="fill"><div className="demo-name">{demo.name}</div><div className="demo-desc">{demo.desc}</div></div>
                      <div className="demo-count" style={{color:demo.color,background:`${demo.color}18`}}>{demo.tasks.length} tasks</div>
                    </button>
                  ))}
                </div>
              )}

              <div className="field"><label className="field-label">Title</label><input className="field-input" placeholder="What's the quest?" value={newTask.title} onChange={e=>setNewTask(p=>({...p,title:e.target.value}))}/></div>
              <div className="field"><label className="field-label">Description</label><textarea className="field-textarea" placeholder="Describe..." value={newTask.desc} onChange={e=>setNewTask(p=>({...p,desc:e.target.value}))}/></div>
              <div className="field"><label className="field-label">Category</label><div className="pill-group">{["Work","Health","Learning","Personal"].map(c=><button key={c} className={`pill ${newTask.category===c?"active":""}`} onClick={()=>setNewTask(p=>({...p,category:c}))}>{c==="Work"?"💼":c==="Health"?"💪":c==="Learning"?"📚":"🏠"} {c}</button>)}</div></div>
              <div className="field"><label className="field-label">Frequency</label><div className="pill-group">{["Daily","Weekly","Monthly","Once"].map(f=><button key={f} className={`pill ${newTask.frequency===f?"active":""}`} onClick={()=>setNewTask(p=>({...p,frequency:f}))}>{f}</button>)}</div></div>
              <div className="field"><label className="field-label">Schedule</label><input type="time" className="field-input" value={newTask.time} onChange={e=>setNewTask(p=>({...p,time:e.target.value}))} style={{colorScheme:"dark"}}/></div>
              <div className="field"><label className="field-label">Priority</label><div className="pill-group">{[{v:"high",l:"🔴 High",c:"var(--red)"},{v:"medium",l:"🟡 Med",c:"var(--gold)"},{v:"low",l:"🟢 Low",c:"var(--accent)"}].map(p=><button key={p.v} className={`pill ${newTask.priority===p.v?"active":""}`} onClick={()=>setNewTask(pr=>({...pr,priority:p.v}))} style={newTask.priority===p.v?{borderColor:p.c,color:p.c}:{}}>{p.l}</button>)}</div></div>
              <button className="btn-primary" disabled={!newTask.title.trim()} onClick={addTask}>⚡ Create — {newTask.priority==="high"?80:newTask.priority==="medium"?50:25} XP</button>
            </div>
          </div>
        )}

        {/* ════ BOTTOM NAV ════ */}
        <nav className="bottom-nav">
          <button className={`nav-item ${tab==="tasks"?"active":""}`} onClick={()=>setTab("tasks")}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>
            <span>Quests</span>
          </button>
          <button className={`nav-item ${tab==="stats"?"active":""}`} onClick={()=>setTab("stats")}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
            <span>Stats</span>
          </button>
          <button className="nav-add" onClick={()=>setShowAdd(true)}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          </button>
          <button className={`nav-item ${tab==="leaderboard"?"active":""}`} onClick={()=>setTab("leaderboard")}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><rect x="6" y="6" width="4" height="16" rx="1"/><rect x="14" y="10" width="4" height="12" rx="1"/><rect x="10" y="2" width="4" height="20" rx="1"/></svg>
            <span>Ranks</span>
          </button>
          <button className={`nav-item ${tab==="profile"?"active":""}`} onClick={()=>setTab("profile")}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            <span>Profile</span>
          </button>
        </nav>
      </div>
    </>
  );
}
