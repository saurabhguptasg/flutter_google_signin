import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;

void main() {
  runApp(const MyApp());
}
GoogleSignInAccount? _currentUser;

const List<String> scopes = <String>[
  'email',
  'profile',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
  clientId: "INSERT WEB CLIENT ID HERE",
);

/// The route configuration.
final GoRouter _router = GoRouter(
  initialLocation: "/",
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },

    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    if(_currentUser != null) {
      return null;
    }
    else {
      return "/login";
    }
  }
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("home screen"),
        actions: [
          (GoogleSignInPlatform.instance as web.GoogleSignInPlugin).renderButton(),
          SizedBox(width: 16,),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      // In mobile, being authenticated means being authorized...
      bool isAuthorized = account != null;
      // However, in the web...
      // if (kIsWeb && account != null) {
      //   isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      // }

      setState(() {
        print(">> >> state is set");
        _currentUser = account;
      });

    });

    // In the web, _googleSignIn.signInSilently() triggers the One Tap UX.
    //
    // It is recommended by Google Identity Services to render both the One Tap UX
    // and the Google Sign In button together to "reduce friction and improve
    // sign-in rates" ([docs](https://developers.google.com/identity/gsi/web/guides/display-button#html)).
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    if(_currentUser != null) {
      print(">> >> valid user ${_currentUser!.displayName}, going home");
      context.go("/");
    }
    print(">> >> rerendering ...");
    return Scaffold(
      appBar: AppBar(
        title: Text("login screen"),
        actions: [
          (GoogleSignInPlatform.instance as web.GoogleSignInPlugin).renderButton(),
          SizedBox(width: 16,),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Please Login ..."),
          ],
        ),
      ),
    );
  }
}