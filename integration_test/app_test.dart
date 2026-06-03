import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kreator_frame/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end tests', () {
    testWidgets('load app and verify startup flow', (WidgetTester tester) async {
      // Initialize SharedPreferences Mock to avoid MissingPluginException
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(
        const ProviderScope(child: MyApp()),
      );
      
      // Allow animations and async providers to settle
      await tester.pumpAndSettle();

      // Verify that the app rooted widget is mounted
      expect(find.byType(MyApp), findsOneWidget);
      
      // Verify that we are on the Home Screen (implicitly via the Scaffold or App Bar)
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
