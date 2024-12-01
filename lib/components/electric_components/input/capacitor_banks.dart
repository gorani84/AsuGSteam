import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class CapacitorBanksForm extends StatefulWidget {
  const CapacitorBanksForm({super.key});

  @override
  State<CapacitorBanksForm> createState() => _CapacitorBanksFormState();
}

class _CapacitorBanksFormState extends State<CapacitorBanksForm> {
  // Controllers for CapacitorBanks form
  final manufacturerController = TextEditingController();
  final nameController = TextEditingController();
  final bus1Controller = TextEditingController();
  final kvController = TextEditingController();
  final kvarController = TextEditingController();
  final phasesController = TextEditingController();
  final connectionTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capacitor Banks Form',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Input fields
            Input(controller: manufacturerController, hintText: 'Manufacturer'),
            const SizedBox(height: 20),
            Input(controller: nameController, hintText: 'Name'),
            const SizedBox(height: 20),
            Input(controller: bus1Controller, hintText: 'Bus 1'),
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
            Input(
                controller: phasesController,
                hintText: 'Phases',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: connectionTypeController,
                hintText: 'Connection Type'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
