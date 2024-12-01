import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class EnergyMeterForm extends StatefulWidget {
  const EnergyMeterForm({super.key});

  @override
  State<EnergyMeterForm> createState() => _EnergyMeterFormState();
}

class _EnergyMeterFormState extends State<EnergyMeterForm> {
  // Controllers for each field
  final manufacturerController = TextEditingController();
  final nameController = TextEditingController();
  final elementController = TextEditingController();
  final terminalController = TextEditingController();
  final phasesController = TextEditingController();
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
              'Energy Meter Parameters',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Form fields based on the energy meter schema
            Input(controller: manufacturerController, hintText: 'Manufacturer'),
            const SizedBox(height: 20),

            Input(controller: nameController, hintText: 'Name'),
            const SizedBox(height: 20),

            Input(controller: elementController, hintText: 'Element'),
            const SizedBox(height: 20),

            Input(
                controller: terminalController,
                hintText: 'Terminal',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            Input(
                controller: phasesController,
                hintText: 'Phases',
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
    elementController.dispose();
    terminalController.dispose();
    phasesController.dispose();
    statusController.dispose();
    super.dispose();
  }
}
