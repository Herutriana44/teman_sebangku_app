import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_app/main.dart';

void main() {
  testWidgets('Splash menampilkan judul aplikasi', (WidgetTester tester) async {
    await tester.pumpWidget(const TemanSoalApp());
    await tester.pump();
    expect(find.text('Teman Soal'), findsOneWidget);
  });
}
