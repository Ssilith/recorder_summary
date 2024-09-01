// ignore_for_file: use_build_context_synchronously

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:recorder_summary/auth/login_page.dart';
import 'package:recorder_summary/firebase_options.dart';
import 'package:recorder_summary/providers/auth_provider.dart';
import 'package:recorder_summary/recorder/main_recorder.dart';
import 'package:recorder_summary/side_drawer.dart';
import 'package:recorder_summary/summary/main_summary.dart';
import 'package:recorder_summary/recordings/main_recordings.dart';

void main() async {
  // initialize app
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // show splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();

  // remove horizontal orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          // create auth provider
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Recorder Summary',
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
              fontFamily: 'Poppins',
            ),
            darkTheme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFF180e2c),
              dialogBackgroundColor: const Color(0xFF180e2c),
              brightness: Brightness.dark,
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
              fontFamily: 'Poppins',
            ),
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.user != null) {
                  return MyHomePage(authProvider: authProvider);
                } else {
                  return LoginPage(authProvider: authProvider);
                }
              },
            ),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  final AuthProvider authProvider;
  const MyHomePage({super.key, required this.authProvider});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // scaffold global key
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // pages controller
  final _pageController = PageController(initialPage: 0);

  // bottom navigation bar controller
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  // open side drawer
  _openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  // close side drawer
  _closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

  // icons of navigation
  final List<IconData> _icons = [
    FontAwesomeIcons.microphone,
    FontAwesomeIcons.headphones,
    FontAwesomeIcons.inbox,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // main pages
    final List<Widget> bottomBarPages = [
      const MainRecorder(),
      const MainRecordings(),
      const MainSummary(),
    ];

    return Scaffold(
      key: scaffoldKey,
      // app ber
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Recorder summary"),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.alignLeft),
          onPressed: _openDrawer,
        ),
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
      // side drawer
      drawer: SideDrawer(
        authProvider: widget.authProvider,
        onClose: _closeDrawer,
      ),
      // pages
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      // bottom bar
      bottomNavigationBar: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          kBottomRadius: 28.0,
          kIconSize: 24.0,
          onTap: (index) => _pageController.jumpToPage(index),
          bottomBarItems: _icons
              .map((icon) => BottomBarItem(
                    inActiveItem: Icon(icon, color: Colors.blueGrey),
                    activeItem: Icon(icon,
                        color: Theme.of(context).colorScheme.background),
                  ))
              .toList()),
    );
  }
}
