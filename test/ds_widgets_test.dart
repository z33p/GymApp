import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/design_system/ds_theme.dart';
import 'package:gym_app/core/design_system/widgets/ds_card.dart';
import 'package:gym_app/core/design_system/widgets/ds_gap.dart';

void main() {
  testWidgets('DsCard renders properly with DsTheme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [DsTheme.light()]),
        home: Scaffold(
          body: DsCard(
            onTap: () {},
            child: const Text('Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
  });

  testWidgets('DsGap renders correct height/width based on theme spacing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [DsTheme.light()]),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  const Text('Top'),
                  DsGap.m(context),
                  const Text('Bottom'),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Top'), findsOneWidget);
    expect(find.text('Bottom'), findsOneWidget);
  });
}
