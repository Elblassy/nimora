import 'package:flutter_test/flutter_test.dart';
import 'package:nimora/main.dart';

void main() {
  testWidgets('App renders landing screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NimoraApp());
    expect(find.text('Nimora'), findsOneWidget);
  });
}
