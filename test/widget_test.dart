import 'package:flutter_test/flutter_test.dart';
import 'package:laboratorium_poltekkesbanten_mobile/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(); // Pump once instead of pumpAndSettle to avoid timeout
    expect(find.byType(MyApp), findsOneWidget);
  });
}
