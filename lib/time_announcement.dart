import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HindiTimeAnnouncementFormatter {
  static const Map<int, String> _numbers = {
    1: 'एक',
    2: 'दो',
    3: 'तीन',
    4: 'चार',
    5: 'पांच',
    6: 'छह',
    7: 'सात',
    8: 'आठ',
    9: 'नौ',
    10: 'दस',
    11: 'ग्यारह',
    12: 'बारह',
    13: 'तेरह',
    14: 'चौदह',
    15: 'पंद्रह',
    16: 'सोलह',
    17: 'सत्रह',
    18: 'अठारह',
    19: 'उन्नीस',
    20: 'बीस',
    21: 'इक्कीस',
    22: 'बाईस',
    23: 'तेईस',
    24: 'चौबीस',
    25: 'पच्चीस',
    26: 'छब्बीस',
    27: 'सत्ताईस',
    28: 'अट्ठाईस',
    29: 'उनतीस',
    30: 'तीस',
    31: 'इकतीस',
    32: 'बत्तीस',
    33: 'तैंतीस',
    34: 'चौंतीस',
    35: 'पैंतीस',
    36: 'छत्तीस',
    37: 'सैंतीस',
    38: 'अड़तीस',
    39: 'उनतालीस',
    40: 'चालीस',
    41: 'इकतालीस',
    42: 'बयालीस',
    43: 'तैंतालीस',
    44: 'चवालीस',
    45: 'पैंतालीस',
    46: 'छियालीस',
    47: 'सैंतालीस',
    48: 'अड़तालीस',
    49: 'उनचास',
    50: 'पचास',
    51: 'इक्यावन',
    52: 'बावन',
    53: 'तिरपन',
    54: 'चौवन',
    55: 'पचपन',
    56: 'छप्पन',
    57: 'सत्तावन',
    58: 'अट्ठावन',
    59: 'उनसठ',
  };

  static String format(DateTime time) {
    final hour = _clockHour(time.hour);
    final minute = time.minute;

    if (minute == 0) {
      return 'अभी ${_number(hour)} बज रहे हैं';
    }

    if (minute == 15) {
      return 'अभी सवा ${_number(hour)} बज रहे हैं';
    }

    if (minute == 30) {
      return switch (hour) {
        1 => 'अभी डेढ़ बज रहे हैं',
        2 => 'अभी ढाई बज रहे हैं',
        _ => 'अभी साढ़े ${_number(hour)} बज रहे हैं',
      };
    }

    if (minute == 45) {
      return 'अभी पौने ${_number(_nextClockHour(hour))} बज रहे हैं';
    }

    return 'अभी ${_number(hour)} बजकर ${_number(minute)} मिनट हो रहे हैं';
  }

  static int _clockHour(int hour24) {
    final hour = hour24 % 12;
    return hour == 0 ? 12 : hour;
  }

  static int _nextClockHour(int hour) => hour == 12 ? 1 : hour + 1;

  static String _number(int value) => _numbers[value] ?? value.toString();
}

class TimeAnnouncementSpeaker {
  TimeAnnouncementSpeaker({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  bool _isConfigured = false;
  bool _canSpeakHindi = false;
  int _stopGeneration = 0;

  Future<void> speakCurrentTime() async {
    final generation = _stopGeneration;
    if (!await _configure()) return;
    if (generation != _stopGeneration) return;

    final announcement = HindiTimeAnnouncementFormatter.format(DateTime.now());
    await _safeStop();
    if (generation != _stopGeneration) return;

    try {
      await _flutterTts.speak(announcement, focus: false);
    } catch (_) {
      // TTS should never make app launch fail.
    }
  }

  Future<void> stop() {
    _stopGeneration++;
    return _safeStop();
  }

  Future<bool> _configure() async {
    if (_isConfigured) return _canSpeakHindi;

    try {
      await _flutterTts.awaitSpeakCompletion(false);
      await _flutterTts.setSpeechRate(0.42);
      await _flutterTts.setPitch(1.0);

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          const [],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      final language = await _bestHindiLanguage();
      if (language == null) {
        _canSpeakHindi = false;
        return false;
      }

      await _flutterTts.setLanguage(language);
      _canSpeakHindi = true;
      return true;
    } catch (_) {
      _canSpeakHindi = false;
      return false;
    } finally {
      _isConfigured = true;
    }
  }

  Future<String?> _bestHindiLanguage() async {
    for (final language in const ['hi-IN', 'hi']) {
      if (await _isLanguageReady(language)) return language;
    }

    return null;
  }

  Future<bool> _isLanguageReady(String language) async {
    try {
      final isInstalled =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android
              ? await _flutterTts.isLanguageInstalled(language)
              : true;
      if (isInstalled == false) return false;

      final isAvailable = await _flutterTts.isLanguageAvailable(language);
      return isAvailable == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _safeStop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {
      // Ignore platform TTS failures during lifecycle cancellation.
    }
  }
}
