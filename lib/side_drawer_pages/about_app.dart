import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recorder_summary/side_drawer_pages/app_bar_scaffold.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  // current page index
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AppBarScaffold(
      title: "About app",
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              itemCount: _titles.length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) =>
                      Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // icon
                  Icon(_icons[itemIndex], size: 150),
                  const SizedBox(height: 30),
                  // title
                  Text(_titles[itemIndex],
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  // description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(_descriptions[itemIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              options: CarouselOptions(
                  height: size.height,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  }),
            ),
          ),
          // pages dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _titles.map((title) {
                int index = _titles.indexOf(title);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// title of page
final List<String> _titles = [
  'WELCOME',
  'RECORD',
  'LISTEN',
  'UPLOAD',
  'SUMMARIZE',
  'RECEIVE',
  'IDEAL FOR EVERYONE',
];

// description of page
final List<String> _descriptions = [
  'Enhance your productivity and knowledge retention with our innovative application.',
  'Attend meetings, lectures, or conversations and easily record the audio with our built-in dictaphone.',
  'Listen to your recorded content anytime, ensuring you never miss important details.',
  'Upload your recordings directly through the app with just a few taps.',
  'Once submitted, our advanced technology processes your recording and creates a concise summary.',
  'Receive a clear and informative summary directly in your email, ready to review and refer back to whenever needed.',
  'Whether you\'re a professional looking to streamline meeting notes or a student wanting to capture lecture points, our app is your perfect companion.',
];

// icon of page
final List<IconData> _icons = [
  FontAwesomeIcons.handshake,
  FontAwesomeIcons.microphone,
  FontAwesomeIcons.headphones,
  FontAwesomeIcons.upload,
  FontAwesomeIcons.rectangleList,
  FontAwesomeIcons.inbox,
  FontAwesomeIcons.users
];
