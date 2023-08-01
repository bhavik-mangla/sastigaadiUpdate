import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sastigaadi/pages/home_screen_buysell.dart';
import 'package:sastigaadi/pages/home_screen_lostfound.dart';
import 'package:sastigaadi/pages/homecabshare.dart';
import 'package:sastigaadi/pages/profile.dart';
import 'pages/developer.dart';
import '/pages/auth/authenticate.dart';
import '/pages/auth/forgetPassword.dart';
import '/providers/sign.dart';
import '/sidebar_info/agencies.dart';
import 'package:provider/provider.dart';
import 'authentication/auth.dart';
import 'firebase_options.dart';
import '/pages/auth/sign_up.dart';
import '/pages/auth/sign_in.dart';
import '/pages/home_screen.dart';
import '/pages/cab_listings.dart';
import '/listings/makeride.dart';
import 'listings/editride.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: AuthService().userChanges,
          initialData: null,
          updateShouldNotify: (_, __) => true,
        ),
        ChangeNotifierProvider<SignInOrRegister>(
          create: (_) => SignInOrRegister(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        title: 'Sasti Gaadi',
        initialRoute: '/',
        routes: {
          '/': (context) => const Authenticate(),
          'signup': (context) => const SignUp(),
          'signin': (context) => const SignIn(),
          'home': (context) => HomeScreen(),
          'cablistings': (context) =>
              CabListings(location: '', date: '', time: DateTime.now()),
          'makeride': (context) => MakeRide(
              location: "Mangalore Airport to Manipal",
              date: DateTime.now(),
              time: DateTime.now(),
              phone: "",
              college: "Manipal Institute of Technology"),
          'editride': (context) => EditRide(
              location: "Mangalore Airport to Manipal",
              date: DateTime.now(),
              time: DateTime.now(),
              phone: "",
              college: "Manipal Institute of Technology"),
          'dev': (context) => const AboutDeveloper(),
          'forgot': (context) => const ResetPassword(),
          'agencies': (context) => const AgencyList(),
          'homeshare': (context) => const HomeCabScreen(),
          'homeLF': (context) => const HomeScreenLF(),
          'homeBS': (context) => const HomeScreenBS(),
          'profile': (context) => const Profile(),
        },
      ),
    );
  }
}
