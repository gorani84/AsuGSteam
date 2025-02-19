import 'package:asugs/components/home_menu.dart';
import 'package:asugs/components/navigation_card.dart';
import 'package:asugs/constants.dart';
import 'package:asugs/screens/bottom_nav_pages/components_page.dart';
import 'package:asugs/screens/bottom_nav_pages/settings_page.dart';
import 'package:asugs/screens/bottom_nav_pages/work_order_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  late final user = Provider.of<User?>(context);

  int selectedBottomNavIndex = 0;

  List<List<String>> navigation = [
    ["Scan QR Code", "assets/icons/qr_code.svg", '/qrcode'],
    ["Manual Entry", "assets/icons/text_file.svg", '/data_entry'],
    ["Equipments", "assets/icons/cable.svg", '/'],
    ["Settings", "assets/icons/settings.svg", '/'],
  ];

  List<Widget> bottomNavPages = [
    ComponentsPage(),
    WorkOrderPage(),
    SettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Grid Scout",
                            style: GoogleFonts.bebasNeue(fontSize: 28, color: kSecondaryColor),
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
                            user?.email ?? "",
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
                      child: bottomNavPages[selectedBottomNavIndex],
                    )
                  ],
                ),
        ),
        bottomNavigationBar: SizedBox(
          height: 100,
          child: BottomNavigationBar(
              onTap: (value) {
                setState(() {
                  selectedBottomNavIndex = value;
                });
              },
              selectedItemColor: kSecondaryColor,
              unselectedItemColor: Colors.black,
              currentIndex: selectedBottomNavIndex,
              selectedFontSize: 16,
              unselectedFontSize: 16,
              items: [
                BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/cable.svg',
                        height: 32,
                        colorFilter: ColorFilter.mode(
                            selectedBottomNavIndex == 0 ? kSecondaryColor : Colors.black, BlendMode.srcIn)),
                    label: "Components"),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/text_file.svg',
                        height: 32,
                        colorFilter: ColorFilter.mode(
                            selectedBottomNavIndex == 1 ? kSecondaryColor : Colors.black, BlendMode.srcIn)),
                    label: "Work order"),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/icons/settings.svg',
                        height: 32,
                        colorFilter: ColorFilter.mode(
                            selectedBottomNavIndex == 2 ? kSecondaryColor : Colors.black, BlendMode.srcIn)),
                    label: "Account")
              ]),
        ));
  }
}
