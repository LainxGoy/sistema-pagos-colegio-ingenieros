import 'package:flutter_test/flutter_test.dart';
import 'package:movil/main.dart';
import 'package:movil/routes/app_routes.dart';

void main() {
  testWidgets('App smoke test initializes and loads LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const ColegioIngenierosApp(initialRoute: AppRoutes.login));
    await tester.pumpAndSettle();

    expect(find.text('COLEGIO DE INGENIEROS'), findsOneWidget);
    expect(find.text('INGRESAR'), findsOneWidget);
  });
}
