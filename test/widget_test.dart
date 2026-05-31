import 'package:arif_quiz/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders an app button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Start',
            icon: Icons.play_arrow_rounded,
          ),
        ),
      ),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });
}
