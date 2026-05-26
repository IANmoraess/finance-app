import 'package:financeapp/core/di/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeapp/app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    Injector.init();
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceApp());
    expect(find.byType(FinanceApp), findsOneWidget);
  });
}
