import 'package:flutter_test/flutter_test.dart';

import 'package:smart_home_designer/main.dart';

void main() {
  testWidgets('Home screen renders app title', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHomeApp());
    await tester.pump();

    // The app bar displays the brand name
    expect(find.text('Smart Home'), findsOneWidget);
  });

  testWidgets('Home screen shows room grid', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHomeApp());
    await tester.pump();

    // At least one known room name is present
    expect(find.text('Living Room'), findsOneWidget);
  });
}
