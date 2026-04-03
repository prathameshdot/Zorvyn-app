import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zorvyn/widgets/brand_logo.dart';

void main() {
  testWidgets('brand logo renders for light theme', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: BrandLogo(size: 96, useDarkAsset: false),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
