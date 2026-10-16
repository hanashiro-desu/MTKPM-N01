import 'package:flutter_test/flutter_test.dart';

import 'package:moviego/app/app.dart';

void main() {
  testWidgets('MOVIEGO starts', (tester) async {
    await tester.pumpWidget(const MovieGoApp());
    await tester.pumpAndSettle();
    expect(find.text('MOVIEGO'), findsOneWidget);
  });
}
