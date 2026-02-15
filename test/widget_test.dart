import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prodeye/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ProdEyeApp()));

    // Verify that we are on the login screen (initial route)
    expect(find.text('Login Screen (TODO)'), findsOneWidget);
  });
}
