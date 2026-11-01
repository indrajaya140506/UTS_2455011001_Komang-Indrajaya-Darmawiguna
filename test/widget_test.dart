import 'package:flutter_test/flutter_test.dart';
import 'package:vclub/main.dart';

void main() {
  testWidgets('VCLUB app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VClubApp());

    expect(find.byType(VClubApp), findsOneWidget);
  });
}
