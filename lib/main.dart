import 'dart:convert';

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_one_signal/flutter_one_signal.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:tuberculos/redux/configure_store.dart';
import "package:tuberculos/screens/login_screen.dart";
import "package:tuberculos/screens/register_screen/register_screen.dart";
import "package:tuberculos/screens/splash_screen.dart";

import "env.dart" as env;
import "routes.dart";

final Color backgroundColor = new Color(0xFFEEEEEF);
final Color greenColor = new Color(0xFF008E49);
final Color disabledColor = new Color(0xFFE9E9Ea);

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Persistor<AppState> persistor;
  Store<AppState> store;
  @override
  void initState() {
    super.initState();

    // Create Persistor
    Map<String, dynamic> storeConfig = configureStore();
    persistor = storeConfig["persistor"];
    store = storeConfig["store"];

    // Load state and dispatch LoadAction
    persistor.load(store);

    FlutterOneSignal.startInit(
      appId: env.ONE_SIGNAL_APP_ID,
      inFocusDisplaying: OSInFocusDisplayOption.InAppAlert,
      notificationReceivedHandler: (notification) {
        Map<String, dynamic> parsedJson = json.decode(notification);
        print(parsedJson);
      },
      notificationOpenedHandler: (notification) {
        Map<String, dynamic> parsedJson = json.decode(notification);
        Map<String, dynamic> additionalData = parsedJson["payload"]["additionalData"];
        store.state.navigatorState.pushNamed(Routes.loginScreen.toString());
        print('opened : $notification');
      },
      unsubscribeWhenNotificationsAreDisabled: false,
    );

  }

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        title: "TuberculosApp",
        home: new SplashScreen(store: store),
        theme: new ThemeData(
          backgroundColor: backgroundColor,
          buttonColor: new Color(0xFF008e49),
          primarySwatch: new MaterialColor(0xFF008E49, {
            50: new Color(0xFFe5f5eb),
            100: new Color(0xFFc1e6ce),
            200: new Color(0xFF99d6ae),
            300: new Color(0xFF6dc78f),
            400: new Color(0xFF49bb77),
            500: new Color(0xFF1aaf5f),
            600: new Color(0xFF10a056),
            700: new Color(0xFF008e49),
            800: new Color(0xFF007D3E),
            900: new Color(0xFF005E2A),
          }),
          primaryColorDark: new Color(0xFF005E2A),
          fontFamily: "Gotham Rounded",
        ),
        navigatorObservers: [new CustomNavigatorObserver(store)],
        routes: <String, WidgetBuilder>{
          (Routes.loginScreen.toString()): (BuildContext context) =>
              LoginScreen(),
          Routes.splashScreen.toString(): (BuildContext context) =>
              SplashScreen(),
          Routes.registerScreen.toString(): (BuildContext context) =>
              RegisterScreen(),
        },
      ),
    );
  }
}

// Observer to track navigatorState every push / pop to enable open / receive notification event
class CustomNavigatorObserver extends RouteObserver<PageRoute<dynamic>> {
  final Store<AppState> store;

  CustomNavigatorObserver(this.store);

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    store.dispatch(new ActionNavigate(route.navigator));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    store.dispatch(new ActionNavigate(route.navigator));
  }

}

void main() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(new MyApp());
}
