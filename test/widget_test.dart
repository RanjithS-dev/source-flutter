import 'package:flutter_test/flutter_test.dart';

import 'package:attendance_flutter/app.dart';

void main() {
  testWidgets('renders login form', (WidgetTester tester) async {
    await tester.pumpWidget(const AttendanceApp());

    expect(find.text('BSZone Coconut ERP'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
