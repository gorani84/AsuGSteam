import 'package:asugs/constants.dart';
import 'package:asugs/screens/data_entry.dart';
import 'package:asugs/screens/data_entry_work_order.dart';
import 'package:asugs/screens/forget_password.dart';
import 'package:asugs/screens/home.dart';
import 'package:asugs/screens/login.dart';
import 'package:asugs/screens/qrcode.dart';
import 'package:asugs/screens/signup.dart';
import 'package:asugs/screens/splash.dart';
import 'package:asugs/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [StreamProvider<User?>(create: (ctx) => AuthService().getAuth().userChanges(), initialData: null)],
      child: MaterialApp(
        title: 'Grid Scout',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: kPrimaryColor,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: kPrimaryColor),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.white, // Border color when enabled (not focused)
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: kErrorColor, // Border color when enabled (not focused)
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: const BorderSide(
                color: kSecondaryColor, // Border color when focused
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10), // Rounded border radius
            ),
            floatingLabelStyle: const TextStyle(
              color: kSecondaryColor,
            ),
            floatingLabelAlignment: FloatingLabelAlignment.start,
            errorStyle: const TextStyle(
              color: kErrorColor,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (ctx) => SplashScreen(),
          '/login': (ctx) => const LoginScreen(),
          '/signup': (ctx) => const SignupScreen(),
          '/forget': (ctx) => const ForgotPasswordScreen(),
          '/': (ctx) => const HomeScreen(),
          '/qrcode': (ctx) => const QrCode(),
          '/data_entry': (ctx) => const DataEntryPage(),
          '/data_entry_work_order': (ctx) => const WorkOrderDataEntryPage(),
        },
        // home: HomePage(),
      ),
    );
  }
}
