import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final TextInputType keyboardType;

  const Input({
    Key? key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[200], // Fill color
        hintStyle: TextStyle(
          color: enabled ? Colors.black45 : Colors.black26, // Hint text color
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border by default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Colors.grey, width: 1.0), // Enabled border
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Colors.grey, width: 1.0), // Disabled border
        ),
      ),
      style: const TextStyle(
        color: Colors.black, // Text color
      ),
    );
  }
}
