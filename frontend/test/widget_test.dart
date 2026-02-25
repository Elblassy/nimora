import 'package:flutter_test/flutter_test.dart';
import 'package:qissati/main.dart';

void main() {
  testWidgets('App renders landing screen', (WidgetTester tester) async {
    await tester.pumpWidget(const QissatiApp());
    expect(find.text('Qissati'), findsOneWidget);
  });
}
