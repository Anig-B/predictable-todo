import 'dart:convert';
import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;


import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _supabase = Supabase.instance.client;

  String? _accessToken;
  DateTime? _tokenExpiry;
  String? _projectId;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _setupLocalNotifications();

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    await _getToken();
    _listenForTokenRefresh();
    _listenForForegroundMessages();
    _listenForNotificationTaps();
    _listenForAuthChanges();
  }

  void _listenForAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _saveToken(token);
        }
      }
    });
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  Future<void> _getToken() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      debugPrint('========== FCM TOKEN: $token ==========');
      await _saveToken(token);
    }
  }

  void _listenForTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen(_saveToken);
  }

  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  void _listenForNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    _firebaseMessaging.getInitialMessage().then(_handleNotificationTap);
  }

  Future<void> _saveToken(String token) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('[Notifications] Skipping token save: No current user logged in.');
        return;
      }

      // Clear out any old tokens to prevent duplicate notifications across app reinstalls
      await _supabase.from('device_tokens').delete().eq('user_id', user.id);

      final platform = Platform.isAndroid ? 'android' : 'ios';
      await _supabase.rpc('upsert_device_token', params: {
        'p_fcm_token': token,
        'p_platform': platform,
      });
      debugPrint('[Notifications] Successfully saved device token for user: ${user.id}');
    } catch (e) {
      debugPrint('[Notifications] Error saving device token: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notifications',
      channelDescription: 'QuestLog notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: notif.title.hashCode,
      title: notif.title,
      body: notif.body,
      notificationDetails: details,
      payload: message.data['route'],
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    _handleNavigation(response.payload);
  }

  void _handleNotificationTap(RemoteMessage? message) {
    if (message == null) return;
    _handleNavigation(message.data['route']);
  }

  void _handleNavigation(String? route) {
    if (route == null) return;
    final nav = navigatorKey.currentState;
    if (nav != null && nav.mounted) {
      nav.pushNamed(route);
    }
  }

  Future<void> _ensureAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) return;

    try {
      debugPrint('[Notifications] Loading service account JSON from assets...');
      final json = await rootBundle.loadString('assets/service_account.json');
      final sa = jsonDecode(json) as Map<String, dynamic>;

      _projectId = sa['project_id'] as String;
      debugPrint('[Notifications] Loaded project ID: $_projectId');

      final now = DateTime.now();
      final jwt = JWT({
        'iss': sa['client_email'],
        'scope': 'https://www.googleapis.com/auth/firebase.messaging',
        'aud': 'https://oauth2.googleapis.com/token',
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      });

      debugPrint('[Notifications] Signing JWT...');
      final signed = jwt.sign(
        RSAPrivateKey(sa['private_key'] as String),
        algorithm: JWTAlgorithm.RS256,
      );
      debugPrint('[Notifications] JWT signed successfully');

      debugPrint('[Notifications] Requesting OAuth access token from Google...');
      final res = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': signed,
        },
      );

      debugPrint('[Notifications] OAuth response status: ${res.statusCode}, body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _accessToken = data['access_token'] as String;
        _tokenExpiry = now.add(Duration(seconds: (data['expires_in'] as int) - 60));
        debugPrint('[Notifications] Access token generated successfully');
      } else {
        debugPrint('[Notifications] Failed to obtain access token: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      debugPrint('[Notifications] Error in _ensureAccessToken: $e');
    }
  }

  Future<void> sendPush({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final tokens = await _supabase
          .from('device_tokens')
          .select('fcm_token')
          .eq('user_id', userId);

      if (tokens.isEmpty) {
        debugPrint('[Notifications] sendPush skipped: No device tokens registered for user: $userId');
        return;
      }

      await _ensureAccessToken();
      if (_accessToken == null || _projectId == null) {
        debugPrint('[Notifications] sendPush failed: Could not generate OAuth access token or project ID is missing');
        return;
      }

      for (final t in tokens) {
        final res = await http.post(
          Uri.parse('https://fcm.googleapis.com/v1/projects/$_projectId/messages:send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: jsonEncode({
            'message': {
              'token': t['fcm_token'],
              'notification': {'title': title, 'body': body},
              'data': data ?? {},
            },
          }),
        );
        debugPrint('[Notifications] FCM send response status: ${res.statusCode}, body: ${res.body}');
      }
    } catch (e) {
      debugPrint('[Notifications] Error in sendPush: $e');
    }
  }

}
