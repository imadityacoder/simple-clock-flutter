import 'dart:async';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:one_clock/one_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'time_announcement.dart';

class MyClock extends StatefulWidget {
  const MyClock({super.key});

  @override
  State<MyClock> createState() => _MyClockState();
}

class _MyClockState extends State<MyClock> with WidgetsBindingObserver {
  static const _selectedClockIndexKey = 'selected_clock_index';
  static const _speakTimeOnLaunchKey = 'speak_time_on_launch';
  static const _launchSpeechDelay = Duration(milliseconds: 1250);

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final TimeAnnouncementSpeaker _timeAnnouncementSpeaker =
      TimeAnnouncementSpeaker();

  int _currentIndex = 0;
  bool _speakTimeOnLaunch = true;
  bool _launchSpeechAttempted = false;
  Timer? _launchSpeechTimer;

  final List<Map<String, dynamic>> clockConfigs = [
    {
      'color': Colors.yellow.shade100,
      'showAllNumbers': true,
      'showDigitalClock': false,
      'border': Border.all(width: 2, color: Colors.black),
      'hourColor': Colors.black,
      'minuteColor': Colors.black,
      'numberColor': Colors.black,
    },
    {
      'color': Colors.cyan.shade100,
      'showAllNumbers': false,
      'showDigitalClock': true,
      'border': Border.all(width: 3, color: Colors.white),
      'hourColor': Colors.black,
      'minuteColor': Colors.black,
      'numberColor': Colors.black,
    },
    {
      'color': Colors.white,
      'showAllNumbers': true,
      'showDigitalClock': true,
      'border': Border.all(width: 1.5, color: Colors.deepPurple),
      'hourColor': Colors.black,
      'minuteColor': Colors.black,
      'numberColor': Colors.black,
    },
    {
      'color': Colors.greenAccent.shade100,
      'showAllNumbers': false,
      'showDigitalClock': false,
      'border': Border.all(width: 4, color: Colors.teal),
      'hourColor': Colors.black,
      'minuteColor': Colors.black,
      'numberColor': Colors.black,
    },
    {
      'color': Colors.red.shade100,
      'showAllNumbers': true,
      'showDigitalClock': true,
      'border': Border.all(width: 2, color: Colors.black87),
      'hourColor': Colors.black,
      'minuteColor': Colors.black,
      'numberColor': Colors.black,
    },
    {
      'color': Colors.black,
      'showAllNumbers': true,
      'showDigitalClock': true,
      'border': Border.all(width: 2, color: Colors.white),
      'hourColor': Colors.white,
      'minuteColor': Colors.white,
      'numberColor': Colors.white,
    },
    {
      'color': Colors.deepPurple,
      'showAllNumbers': false,
      'showDigitalClock': false,
      'border': Border.all(width: 2, color: Colors.white),
      'hourColor': Colors.yellow,
      'minuteColor': Colors.yellow,
      'numberColor': Colors.yellow,
    },
    {
      'color': Colors.blueGrey.shade900,
      'showAllNumbers': true,
      'showDigitalClock': false,
      'border': Border.all(width: 2.5, color: Colors.cyan),
      'hourColor': Colors.cyanAccent,
      'minuteColor': Colors.cyanAccent,
      'numberColor': Colors.cyanAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSelectedIndex();
    _loadSpeechPreferenceAndSchedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelLaunchSpeech();
    _timeAnnouncementSpeaker.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _cancelLaunchSpeech();
      _timeAnnouncementSpeaker.stop();
    }
  }

  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_selectedClockIndexKey) ?? 0;

    if (!mounted) return;

    setState(() {
      _currentIndex = savedIndex.clamp(0, clockConfigs.length - 1);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carouselController.jumpToPage(_currentIndex);
    });
  }

  Future<void> _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedClockIndexKey, index);
  }

  Future<void> _loadSpeechPreferenceAndSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final speakTimeOnLaunch = prefs.getBool(_speakTimeOnLaunchKey) ?? true;

    if (!mounted) return;

    setState(() => _speakTimeOnLaunch = speakTimeOnLaunch);

    if (speakTimeOnLaunch) {
      _scheduleLaunchSpeech();
    }
  }

  void _scheduleLaunchSpeech() {
    if (_launchSpeechAttempted ||
        _launchSpeechTimer != null ||
        !_speakTimeOnLaunch) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_speakTimeOnLaunch) return;

      _launchSpeechTimer = Timer(_launchSpeechDelay, () {
        _launchSpeechTimer = null;
        _launchSpeechAttempted = true;

        if (!mounted || !_speakTimeOnLaunch) return;
        _timeAnnouncementSpeaker.speakCurrentTime();
      });
    });
  }

  void _cancelLaunchSpeech() {
    _launchSpeechTimer?.cancel();
    _launchSpeechTimer = null;
  }

  Future<void> _saveSpeechPreference(bool enabled) async {
    setState(() => _speakTimeOnLaunch = enabled);

    if (!enabled) {
      _cancelLaunchSpeech();
      await _timeAnnouncementSpeaker.stop();
    } else {
      _scheduleLaunchSpeech();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_speakTimeOnLaunchKey, enabled);
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Speak time on launch'),
                      subtitle: Text(_speakTimeOnLaunch ? 'हाँ' : 'नहीं'),
                      value: _speakTimeOnLaunch,
                      onChanged: (value) {
                        setSheetState(() => _speakTimeOnLaunch = value);
                        _saveSpeechPreference(value);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Simple Analog Clock',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        width: screenWidth,
        child: CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: clockConfigs.length,
          itemBuilder: (context, index, _) {
            final config = clockConfigs[index];

            return Center(
              child: AnalogClock(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: config['color'],
                  border: config['border'],
                ),
                width: screenWidth * 0.75,
                isLive: true,
                hourHandColor: config['hourColor'],
                minuteHandColor: config['minuteColor'],
                secondHandColor: Colors.redAccent,
                numberColor: config['numberColor'],
                showSecondHand: true,
                showNumbers: true,
                showAllNumbers: config['showAllNumbers'],
                showTicks: true,
                showDigitalClock: config['showDigitalClock'],
                textScaleFactor: 1.4,
                datetime: DateTime.now(),
              ),
            );
          },
          options: CarouselOptions(
            height: screenWidth * 0.9,
            enlargeCenterPage: true,
            viewportFraction: 1,
            initialPage: 0,
            onPageChanged: (index, _) {
              setState(() => _currentIndex = index);
              _saveSelectedIndex(index);
            },
          ),
        ),
      ),
    );
  }
}
