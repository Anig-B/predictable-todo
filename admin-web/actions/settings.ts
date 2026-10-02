"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export interface DeviceToken {
  fcm_token: string;
  platform: string;
  updated_at: string;
}

export interface Mission {
  id: string;
  name: string;
}

export interface ManagerSettingsResponse {
  userId: string;
  email: string;
  profile: {
    username: string;
    role: string;
    tagline: string;
  };
  devices: DeviceToken[];
  missions: Mission[];
}

/**
 * Fetch manager settings data including profile info, registered devices, and active missions.
 */
export async function getManagerSettingsData(): Promise<{
  success: boolean;
  data?: ManagerSettingsResponse;
  error?: string;
}> {
  try {
    const supabase = await createClient();

    // Verify session
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return { success: false, error: "Unauthorized access." };
    }

    // Fetch user profile
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("username, role, tagline")
      .eq("id", user.id)
      .single();

    if (profileError) {
      return { success: false, error: "Failed to retrieve user profile." };
    }

    // Fetch user registered FCM devices
    const { data: devices, error: devicesError } = await supabase
      .from("user_devices")
      .select("fcm_token, platform, updated_at")
      .eq("user_id", user.id)
      .order("updated_at", { ascending: false });

    if (devicesError) {
      console.error("Device fetch error:", devicesError);
    }

    // Fetch active missions
    const { data: missions, error: missionsError } = await supabase
      .from("missions")
      .select("id, name")
      .order("name", { ascending: true });

    if (missionsError) {
      console.error("Missions fetch error:", missionsError);
    }

    return {
      success: true,
      data: {
        userId: user.id,
        email: user.email || "",
        profile: {
          username: profile?.username || "",
          role: profile?.role || "manager",
          tagline: profile?.tagline || "",
        },
        devices: devices || [],
        missions: missions || [],
      },
    };
  } catch (err: any) {
    return {
      success: false,
      error: err.message || "An unexpected error occurred.",
    };
  }
}

/**
 * Update Manager's Profile details (Username & Tagline).
 */
export async function updateManagerProfile(params: {
  userId: string;
  username: string;
  tagline: string;
}): Promise<{ success: boolean; message?: string; error?: string }> {
  try {
    const supabase = await createClient();

    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user || user.id !== params.userId) {
      return { success: false, error: "Unauthorized." };
    }

    const { error } = await supabase
      .from("profiles")
      .update({
        username: params.username.trim(),
        tagline: params.tagline.trim(),
        updated_at: new Date().toISOString(),
      })
      .eq("id", params.userId);

    if (error) {
      return { success: false, error: error.message };
    }

    revalidatePath("/settings");
    return { success: true, message: "Profile settings updated successfully!" };
  } catch (err: any) {
    return {
      success: false,
      error: err.message || "Failed to update profile.",
    };
  }
}

/**
 * Revoke/delete a registered FCM device token.
 */
export async function revokeDeviceToken(
  fcmToken: string,
): Promise<{ success: boolean; message?: string; error?: string }> {
  try {
    const supabase = await createClient();

    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return { success: false, error: "Unauthorized." };
    }

    const { error } = await supabase
      .from("user_devices")
      .delete()
      .eq("fcm_token", fcmToken)
      .eq("user_id", user.id);

    if (error) {
      return { success: false, error: error.message };
    }

    revalidatePath("/settings");
    return { success: true, message: "Device revoked successfully." };
  } catch (err: any) {
    return { success: false, error: err.message || "Failed to revoke device." };
  }
}

/**
 * Send a notification targeting all members of a specific mission squad.
 */
export async function sendMissionNotification(params: {
  senderId: string;
  missionId: string;
  title: string;
  message: string;
}): Promise<{ success: boolean; message?: string; error?: string }> {
  try {
    const supabase = await createClient();

    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user || user.id !== params.senderId) {
      return { success: false, error: "Unauthorized action." };
    }

    // 1. Fetch member user IDs assigned to the target mission
    const { data: members, error: membersError } = await supabase
      .from("mission_members")
      .select("user_id")
      .eq("mission_id", params.missionId);

    if (membersError) {
      return {
        success: false,
        error: "Failed to fetch mission squad members.",
      };
    }

    if (!members || members.length === 0) {
      return {
        success: false,
        error: "No active members found for this mission squad.",
      };
    }

    const recipientIds = members.map((m) => m.user_id);

    // 2. Queue notifications in the database
    const notificationPayloads = recipientIds.map((recipientId) => ({
      user_id: recipientId,
      sender_id: params.senderId,
      mission_id: params.missionId,
      title: params.title.trim(),
      body: params.message.trim(),
      created_at: new Date().toISOString(),
    }));

    const { error: insertError } = await supabase
      .from("notifications")
      .insert(notificationPayloads);

    if (insertError) {
      return { success: false, error: insertError.message };
    }

    return {
      success: true,
      message: `Notification broadcasted to ${recipientIds.length} squad member(s).`,
    };
  } catch (err: any) {
    return {
      success: false,
      error: err.message || "Failed to send notification.",
    };
  }
}
