import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart' show MyApp;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    return dotenv.testLoad(fileInput: 'MICROSOFT_TENANT_ID=\nMICROSOFT_CLIENT_ID=\n');
  });

  testWidgets('Login page shows Microsoft sign-in', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump();

    expect(find.text('Continue with Microsoft'), findsOneWidget);
  });
}
