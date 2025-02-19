import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NavigationCard extends StatelessWidget {
  const NavigationCard({super.key, required this.title, required this.svgPath, required this.href, this.onTap});

  final String title;
  final String svgPath;
  final String href;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ??
            () {
              Navigator.pushNamed(context, href);
            },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.shade200,
            //     blurRadius: 4,
            //     spreadRadius: 1,
            //     offset: const Offset(0, 2),
            //   )
            // ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  svgPath,
                  width: 60,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
