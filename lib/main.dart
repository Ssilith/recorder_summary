// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:recorder_summary/auth/login_page.dart';
import 'package:recorder_summary/firebase_options.dart';
import 'package:recorder_summary/providers/auth_provider.dart';
import 'package:recorder_summary/side_drawer.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            title: 'Recorder Summary',
            themeMode: ThemeMode.dark,
            theme: ThemeData(
                brightness: Brightness.light,
                useMaterial3: true,
                colorSchemeSeed: Colors.indigo,
                fontFamily: 'Poppins',
                appBarTheme: const AppBarTheme(
                  centerTitle: true,
                  elevation: 0,
                  titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w600),
                )),
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

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class _MyHomePageState extends State<MyHomePage> {
  // open side drawer
  _openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Recorder summary"),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.alignLeft),
          onPressed: _openDrawer,
        ),
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
      drawer: SideDrawer(authProvider: widget.authProvider),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [],
      ),
    );
  }
}
