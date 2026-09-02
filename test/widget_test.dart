import 'package:flutter_test/flutter_test.dart';
import 'package:crucigramas/main.dart';

void main() {
  testWidgets('CrucigramasApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CrucigramasApp());
    await tester.pumpAndSettle();
    expect(find.byType(CrucigramasApp), findsOneWidget);
  });
}
