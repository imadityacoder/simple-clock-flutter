import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:one_clock/one_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyClock extends StatefulWidget {
  const MyClock({super.key});

  @override
  State<MyClock> createState() => _MyClockState();
}

class _MyClockState extends State<MyClock> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

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
    _loadSelectedIndex();
  }

  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('selected_clock_index') ?? 0;

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
    await prefs.setInt('selected_clock_index', index);
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
