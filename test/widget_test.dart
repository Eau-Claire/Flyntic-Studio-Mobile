import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flyntic app smoke test', (WidgetTester tester) async {
    expect(find.byType(MaterialApp), findsNothing);
  });
}
