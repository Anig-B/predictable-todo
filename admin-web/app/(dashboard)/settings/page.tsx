"use client";

import React, { useEffect, useState, useCallback } from "react";
import { CheckCircle2, AlertCircle } from "lucide-react";
import {
  getManagerSettingsData,
  updateManagerProfile,
  sendMissionNotification,
  Mission,
} from "@/actions/settings";
import SettingsHeader from "@/components/settings/SettingsHeader";
import ProfileSection from "@/components/settings/ProfileSection";
import MissionNotificationSection from "@/components/settings/MissionNotificationSection";

export default function ManagerSettingsPage() {
  const [loading, setLoading] = useState<boolean>(true);
  const [saving, setSaving] = useState<boolean>(false);
  const [sendingNotif, setSendingNotif] = useState<boolean>(false);
  const [message, setMessage] = useState<{
    text: string;
    type: "success" | "error";
  } | null>(null);

  // Profile Form States
  const [userId, setUserId] = useState<string | null>(null);
  const [email, setEmail] = useState<string>("");
  const [username, setUsername] = useState<string>("");
  const [role, setRole] = useState<string>("manager");
  const [tagline, setTagline] = useState<string>("");

  // Missions & Notifications State
  const [missions, setMissions] = useState<Mission[]>([]);
  const [selectedMissionId, setSelectedMissionId] = useState<string>("");
  const [notifTitle, setNotifTitle] = useState<string>("");
  const [notifBody, setNotifBody] = useState<string>("");

  const loadData = useCallback(async () => {
    setLoading(true);
    const res = await getManagerSettingsData();
    if (res.success && res.data) {
      setUserId(res.data.userId);
      setEmail(res.data.email);
      setUsername(res.data.profile.username);
      setRole(res.data.profile.role);
      setTagline(res.data.profile.tagline);
      setMissions(res.data.missions);
    } else {
      setMessage({
        text: res.error || "Failed to load manager settings.",
        type: "error",
      });
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  async function handleSaveProfile(e: React.FormEvent) {
    e.preventDefault();
    if (!userId) return;

    setSaving(true);
    setMessage(null);

    const res = await updateManagerProfile({ userId, username, tagline });
    if (res.success) {
      setMessage({
        text: res.message || "Profile updated successfully!",
        type: "success",
      });
    } else {
      setMessage({
        text: res.error || "Failed to update profile.",
        type: "error",
      });
    }
    setSaving(false);
  }

  async function handleSendMissionNotification(e: React.FormEvent) {
    e.preventDefault();
    if (
      !selectedMissionId ||
      !notifTitle.trim() ||
      !notifBody.trim() ||
      !userId
    )
      return;

    setSendingNotif(true);
    setMessage(null);

    const res = await sendMissionNotification({
      senderId: userId,
      missionId: selectedMissionId,
      title: notifTitle,
      message: notifBody,
    });

    if (res.success) {
      setMessage({
        text: res.message || "Notification sent successfully!",
        type: "success",
      });
      setNotifTitle("");
      setNotifBody("");
      setSelectedMissionId("");
    } else {
      setMessage({
        text: res.error || "Failed to send notification.",
        type: "error",
      });
    }
    setSendingNotif(false);
  }

  // Modern Skeleton Loading State
  if (loading) {
    return (
      <div className="p-8 max-w-4xl mx-auto space-y-8 animate-pulse">
        {/* Settings Header Skeleton */}
        <div className="flex items-center justify-between pb-4 border-b border-[#e8e3db]">
          <div className="space-y-2">
            <div className="h-8 bg-[#e8e3db] rounded w-48"></div>
            <div className="h-4 bg-[#e8e3db] rounded w-80"></div>
          </div>
          <div className="h-9 bg-[#e8e3db] rounded w-28"></div>
        </div>

        {/* Form Sections Skeleton */}
        <div className="space-y-6">
          <div className="h-64 bg-[#e8e3db] rounded-lg border border-[#e8e3db]"></div>
          <div className="h-80 bg-[#e8e3db] rounded-lg border border-[#e8e3db]"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-4xl mx-auto space-y-6 min-h-screen pb-24">
      {/* Header Bar */}
      <SettingsHeader onRefresh={loadData} />

      {/* Status Feedback Message */}
      {message && (
        <div
          className={`p-4 rounded-lg text-sm flex items-start gap-3 border shadow-sm transition-all ${
            message.type === "success"
              ? "bg-emerald-50 text-emerald-900 border-emerald-200"
              : "bg-red-50 text-red-900 border-red-200"
          }`}
        >
          {message.type === "success" ? (
            <CheckCircle2 className="w-5 h-5 shrink-0 text-emerald-600 mt-0.5" />
          ) : (
            <AlertCircle className="w-5 h-5 shrink-0 text-red-600 mt-0.5" />
          )}
          <div className="flex-1">
            <p className="font-medium">
              {message.type === "success" ? "Success" : "Action Required"}
            </p>
            <p className="text-xs opacity-90 mt-0.5">{message.text}</p>
          </div>
        </div>
      )}

      {/* Settings Form Sections */}
      <div className="space-y-6">
        <ProfileSection
          userId={userId}
          email={email}
          username={username}
          role={role}
          tagline={tagline}
          saving={saving}
          setUsername={setUsername}
          setTagline={setTagline}
          onSave={handleSaveProfile}
        />

        <MissionNotificationSection
          missions={missions}
          selectedMissionId={selectedMissionId}
          notifTitle={notifTitle}
          notifBody={notifBody}
          sendingNotif={sendingNotif}
          setSelectedMissionId={setSelectedMissionId}
          setNotifTitle={setNotifTitle}
          setNotifBody={setNotifBody}
          onSend={handleSendMissionNotification}
        />
      </div>
    </div>
  );
}
