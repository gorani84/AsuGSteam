<<<<<<< HEAD
import 'package:gridscout/services/auth.dart';
=======
import 'package:asugs/services/auth.dart';
>>>>>>> 2eb82753615ad9020e69eb297e85e87fbb301350
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({
    super.key,
    required this.user,
  });

  final User? user;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: CircleAvatar(
          maxRadius: 24,
          backgroundImage: Image.asset("assets/images/logo_gold.png").image,
        ),
        items: [
          ...MenuItems.firstItems.map(
            (item) => DropdownMenuItem<MenuItem>(
              value: item,
              child: MenuItems.buildItem(item),
            ),
          ),
        ],
        onChanged: (value) {
          MenuItems.onChanged(context, value! as MenuItem);
        },
        // icon: const Icon(Icons.arrow_drop_down), // Dropdown icon
        // iconSize: 24,
        isExpanded: true,
        dropdownStyleData: DropdownStyleData(
          width: 120,
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.redAccent,
          ),
          offset: const Offset(-(120 / 1.3), -6),
        ),
        menuItemStyleData: MenuItemStyleData(
          customHeights: [
            ...List<double>.filled(MenuItems.firstItems.length, 48),
          ],
          padding: const EdgeInsets.only(left: 16, right: 16),
        ),
      ),
    );
  }
}

class MenuItem {
  const MenuItem({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;
}

abstract class MenuItems {
  // static const home = MenuItem(text: 'Home', icon: Icons.home);
  // static const share = MenuItem(text: 'Share', icon: Icons.share);
  // static const settings = MenuItem(text: 'Settings', icon: Icons.settings);
  static const logout = MenuItem(text: 'Log Out', icon: Icons.logout);
  static const List<MenuItem> firstItems = [logout];

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 16),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            item.text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  static void onChanged(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.logout:
        //Do something
        AuthService().signOut().then((_) {
          Navigator.pushNamed(context, '/login');
        });
        break;
    }
  }
}

//
// Appendix:
//  - https://pub.dev/packages/dropdown_button2#6-dropdownbutton2-as-popup-menu-button-using-custombutton-parameter
