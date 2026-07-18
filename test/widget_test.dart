import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service/app.dart';

void main() {
  testWidgets('Field Service app shows Today shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FieldServiceApp()));
    await tester.pumpAndSettle();

    expect(find.text('ZatGo Field Service'), findsOneWidget);
    expect(find.text('Field day'), findsOneWidget);
    expect(find.textContaining('Central district'), findsWidgets);
  });
}
