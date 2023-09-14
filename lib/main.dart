import 'package:emmapay/dashboard.dart';
import 'package:emmapay/system.dart';
import 'package:emmapay/transactions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'dart:developer' as developer;

import 'service.dart';
import 'appconfig.dart';

void main() async {
  // Initialize the AppConfigSingleton
  await AppConfigSingleton().init();

  // Get the Singleton instance of AppConfig
  final config = AppConfigSingleton().config;

  final service = Service();

  final server = await shelf_io.serve(service.handler, 'localhost', config.port);
  developer.log('Serving at http://${server.address.host}:${server.port}');
  print('Serving at http://${server.address.host}:${server.port}');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();

    state?.setState(() {
      state.locale = newLocale;
    });
  }
}

class _MyAppState extends State<MyApp> {
  Locale locale = const Locale('es');

  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMMA Pay',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'EMMA Pay'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.clickedTime,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.house),
              color: Colors.red[200],
              onPressed: () {},
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      persistentFooterButtons: [
        Visibility(
            visible: true,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(
                children: [
                  IconButton(
                      icon: const FaIcon(FontAwesomeIcons.chartSimple),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Dashboard()),
                        );
                      }),
                  Text(AppLocalizations.of(context)!.dashboard),
                ],
              ),
              Column(
                children: [
                  IconButton(
                      icon: const FaIcon(FontAwesomeIcons.fileLines),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Transactions()),
                        );
                      }),
                  Text(AppLocalizations.of(context)!.transactions),
                ],
              ),
              Column(
                children: [
                  IconButton(
                      icon: const FaIcon(FontAwesomeIcons.microchip),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SystemInfo()),
                        );
                      }),
                  Text(AppLocalizations.of(context)!.systemInfo),
                ],
              ),
              Column(
                children: [
                  IconButton(icon: const FaIcon(FontAwesomeIcons.gear), onPressed: () {}),
                  Text(AppLocalizations.of(context)!.settings),
                ],
              ),
              Column(
                children: [
                  IconButton(icon: const FaIcon(FontAwesomeIcons.rotate), onPressed: () {}),
                  Text(AppLocalizations.of(context)!.reboot),
                ],
              ),
              Column(
                children: [
                  IconButton(
                      icon: const FaIcon(FontAwesomeIcons.circleXmark),
                      color: Colors.red,
                      onPressed: () {
                        MyApp.setLocale(context, const Locale('en'));
                      }),
                  Text(style: const TextStyle(color: Colors.red), AppLocalizations.of(context)!.close),
                ],
              ),
            ]))
      ],
    );
  }
}
