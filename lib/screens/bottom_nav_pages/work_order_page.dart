import 'package:asugs/components/navigation_card.dart';
import 'package:flutter/material.dart';

class WorkOrderPage extends StatelessWidget {
  List<List<String>> navigation = [
    ["Scan QR Code", "assets/icons/qr_code.svg", '/qrcode'],
    ["Manual Entry", "assets/icons/text_file.svg", '/data_entry_work_order'],
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
            onTap: i == 0
                ? () {
                    Navigator.pushNamed(context, navigation[i][2], arguments: {
                      'navigate_to': '/data_entry_work_order',
                    });
                  }
                : null,
          );
        },
      ),
    );
  }
}
