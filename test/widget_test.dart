// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:moprog_uts/main.dart';

void main() {
  testWidgets('intro page renders without layout errors', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Learn languages one Quack at a time.'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
