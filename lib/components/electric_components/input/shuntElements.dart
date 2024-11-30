import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class ShuntElementForm extends StatefulWidget {
  const ShuntElementForm({super.key});

  @override
  State<ShuntElementForm> createState() => _ShuntElementFormState();
}

class _ShuntElementFormState extends State<ShuntElementForm> {
  // Controllers for each field
  final manufacturerController = TextEditingController();
  final nameController = TextEditingController();
  final bus1Controller = TextEditingController();
  final phasesController = TextEditingController();
  final kvController = TextEditingController();
  final kvarController = TextEditingController();
  final statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shunt Element Parameters',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Form fields based on the shunt element schema
            Input(controller: manufacturerController, hintText: 'Manufacturer'),
            const SizedBox(height: 20),

            Input(controller: nameController, hintText: 'Name'),
            const SizedBox(height: 20),

            Input(controller: bus1Controller, hintText: 'Bus 1'),
            const SizedBox(height: 20),

            Input(
                controller: phasesController,
                hintText: 'Phases',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            Input(
                controller: kvController,
                hintText: 'kV',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            Input(
                controller: kvarController,
                hintText: 'kVAR',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            Input(controller: statusController, hintText: 'Status'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    manufacturerController.dispose();
    nameController.dispose();
    bus1Controller.dispose();
    phasesController.dispose();
    kvController.dispose();
    kvarController.dispose();
    statusController.dispose();
    super.dispose();
  }
}