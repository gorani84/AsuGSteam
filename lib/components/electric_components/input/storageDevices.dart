import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class StorageDevicesForm extends StatefulWidget {
  const StorageDevicesForm({super.key});

  @override
  State<StorageDevicesForm> createState() => _StorageDevicesFormState();
}

class _StorageDevicesFormState extends State<StorageDevicesForm> {
  // Controllers for each field
  final manufacturerController = TextEditingController();
  final nameController = TextEditingController();
  final busController = TextEditingController();
  final phasesController = TextEditingController();
  final kvController = TextEditingController();
  final kwController = TextEditingController();
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
              'Storage Devices Parameters',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Form fields based on the storage device schema
            Input(controller: manufacturerController, hintText: 'Manufacturer'),
            const SizedBox(height: 20),

            Input(controller: nameController, hintText: 'Name'),
            const SizedBox(height: 20),

            Input(controller: busController, hintText: 'Bus'),
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
                controller: kwController,
                hintText: 'kW',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            Input(
                controller: kvarController,
                hintText: 'kvar',
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
    busController.dispose();
    phasesController.dispose();
    kvController.dispose();
    kwController.dispose();
    kvarController.dispose();
    statusController.dispose();
    super.dispose();
  }
}
