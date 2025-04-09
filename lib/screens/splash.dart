<<<<<<< HEAD
import 'package:gridscout/constants.dart';
import 'package:gridscout/services/auth.dart';
=======
import 'package:asugs/constants.dart';
import 'package:asugs/services/auth.dart';
>>>>>>> 2eb82753615ad9020e69eb297e85e87fbb301350
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3), () {});

    // get the user
    AuthService().getAuth().userChanges().listen((user) {
      if (user == null) {
        Navigator.pushNamed(context, '/login');
      } else {
        Navigator.pushNamed(context, '/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  75), // Half of the width/height for a perfect circle
              child: Image.asset(
                "assets/images/logo_white.png",
                width: 150,
                height: 150,
              ),
            ),
          ),
          const Spacer(),
          Text(
            "Grid Scout",
            style: GoogleFonts.bebasNeue(fontSize: 28, color: kSecondaryColor),
          ),
          const SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }
}
