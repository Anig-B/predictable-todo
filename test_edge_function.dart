import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const url = 'https://bgryhkvorqgjlvmtbcht.supabase.co/functions/v1/process-scheduled-notifications';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJncnloa3ZvcnFnamx2bXRiY2h0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ4NjQ4MDQsImV4cCI6MjA5MDQ0MDgwNH0.vyWYG8EAIG72TYmfAE23hOyomv6PT52P9LgzKWS2hcQ';

  print('Triggering Edge Function...');
  final res = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $anonKey',
    },
    body: jsonEncode({}),
  );

  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');
}
