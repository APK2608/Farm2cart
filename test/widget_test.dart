import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_shop/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const FruitShopApp());
    expect(find.byType(FruitShopApp), findsOneWidget);
  });
}
