import 'package:asugs/components/navigation_card.dart';
import 'package:flutter/material.dart';

class ComponentsPage extends StatelessWidget {
  List<List<String>> navigation = [
    ["Scan QR Code", "assets/icons/qr_code.svg", '/qrcode'],
    ["Manual Entry", "assets/icons/text_file.svg", '/data_entry'],
    ["Equipments", "assets/icons/cable.svg", '/'],
    ["Settings", "assets/icons/settings.svg", '/'],
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24 - 8),
        itemCount: navigation.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
