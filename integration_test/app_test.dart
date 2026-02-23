import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:predictable_todo/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Guest Login and Team Creation Flow', (
    WidgetTester tester,
  ) async {
    // Clear shared preferences to reset state between test runs
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    app.main();
    await tester.pumpAndSettle();
    // Wait for local ID generation and Firestore listener to init
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 1. Verify Team Selection Screen
    // "Create a Team" text should typically be visible now since auth is bypassed
    expect(find.text('Create a Team'), findsOneWidget);

    // 2. Create a Team
    await tester.tap(find.text('Create a Team'));
    await tester.pumpAndSettle();

    // Dialog should appear
    expect(find.text('Team Name'), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'Test Pod');
    await tester.pumpAndSettle();

    // Tap Create
    await tester.tap(find.text('Create'));
    await tester.pump();
    
    // Wait for Firestore to process team creation and navigation listener
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    final snackBars = find.byType(SnackBar);
    if (tester.any(snackBars)) {
      final textWidget = tester.widget<Text>(
        find.descendant(of: snackBars, matching: find.byType(Text)).first,
      );
      print('=== SNACKBAR ERROR FOUND ===');
      print(textWidget.data);
      print('============================');
    }

    // 3. Verify Dashboard
    expect(find.text('Create a Team'), findsNothing);

    // 4. Navigate to Task Manager
    await tester.tap(find.text('Tasks'));
    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // 5. Create a Task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify Create Task Screen
    expect(find.text('New Recurring Task'), findsOneWidget);

    // Enter details
    await tester.enterText(
      find.byType(TextFormField).first,
      'Integration Task',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Force unfocus
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Create Task'));
    await tester.pumpAndSettle();
    
    // Explicitly target the ElevatedButton's text
    final createBtnText = find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.text('Create Task'),
    );
    
    await tester.tap(createBtnText);
    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Check if still on CreateTaskScreen
    if (tester.any(find.text('New Recurring Task'))) {
      debugPrint('=== ERROR: CREATE TASK SCREEN DID NOT POP! ===');
      final snackBars = find.byType(SnackBar);
      if (tester.any(snackBars)) {
        final textWidget = tester.widget<Text>(
          find.descendant(of: snackBars, matching: find.byType(Text)).first,
        );
        debugPrint('=== SNACKBAR IN CREATE TASK: ${textWidget.data} ===');
      }
      throw Exception('Screen failed to pop after tapping Create Task');
    }

    // 6. Verify Task in Task Manager
    debugPrint('=== TEST: Verifying Integration Task exists ===');
    expect(find.text('Integration Task'), findsOneWidget);

    // 7. Go to Today Dashboard
    debugPrint('=== TEST: Tapping Today Tab ===');
    expect(find.text('Today'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify Task in Today
    expect(find.text('Integration Task'), findsOneWidget);

    // 8. Complete Task
    await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
    await tester.pump();
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify it is checked
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });
}
