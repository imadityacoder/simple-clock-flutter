import 'package:analog_clock_app/main.dart';
import 'package:analog_clock_app/time_announcement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HindiTimeAnnouncementFormatter', () {
    test('formats top of the hour', () {
      expect(
        HindiTimeAnnouncementFormatter.format(DateTime(2026, 1, 1, 9)),
        'अभी नौ बज रहे हैं',
      );
    });

    test('formats standard minute time', () {
      expect(
        HindiTimeAnnouncementFormatter.format(DateTime(2026, 1, 1, 14, 7)),
        'अभी दो बजकर सात मिनट हो रहे हैं',
      );
    });

    test('formats colloquial quarter past, half past, and quarter to', () {
      expect(
        HindiTimeAnnouncementFormatter.format(DateTime(2026, 1, 1, 1, 15)),
        'अभी सवा एक बज रहे हैं',
      );
      expect(
        HindiTimeAnnouncementFormatter.format(DateTime(2026, 1, 1, 1, 30)),
        'अभी डेढ़ बज रहे हैं',
      );
      expect(
        HindiTimeAnnouncementFormatter.format(DateTime(2026, 1, 1, 2, 30)),
        'अभी ढाई बज रहे हैं',
      );
      expect(
        HindiTimeAnnouncementFormatter.format(DateTime(2026, 1, 1, 12, 45)),
        'अभी पौने एक बज रहे हैं',
      );
    });
  });

  testWidgets('clock app exposes settings toggle', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'speak_time_on_launch': false});

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Speak time on launch'), findsOneWidget);
    expect(find.text('नहीं'), findsOneWidget);
  });
}
