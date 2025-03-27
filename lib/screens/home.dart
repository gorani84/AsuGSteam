import 'package:asugs/components/home_menu.dart';
import 'package:asugs/components/navigation_card.dart';
import 'package:asugs/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    List<List<String>> navigation = [
      ["Scan QR Code", "assets/icons/qr_code.svg", '/qrcode'],
      ["Work Order", "assets/icons/text_file.svg", '/work_order'],
      ["Manual Entry", "assets/icons/text_file.svg", '/data_entry'],
      ["Equipments", "assets/icons/cable.svg", '/'],
      ["Settings", "assets/icons/settings.svg", '/'],
    ];

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: user == null
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // custom header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Grid Scout",
                          style: GoogleFonts.bebasNeue(
                              fontSize: 28, color: kSecondaryColor),
                        ),
                        const Spacer(),
                        HomeMenu(user: user)
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // home screen
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // "Musheer Gorani",
                          user.email ?? "",
                          style: GoogleFonts.bebasNeue(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  // navigation
                  const SizedBox(
                    height: 44,
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24 - 8),
                      itemCount: navigation.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (ctx, i) {
                        return NavigationCard(
                          title: navigation[i][0],
                          svgPath: navigation[i][1],
                          href: navigation[i][2],
                        );
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
