import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class SwitchesForm extends StatefulWidget {
  const SwitchesForm({super.key});

  @override
  State<SwitchesForm> createState() => _SwitchesFormState();
}

class _SwitchesFormState extends State<SwitchesForm> {
  // Controllers for the form fields
  final manufacturerController = TextEditingController();
  final nameController = TextEditingController();
  final bus1Controller = TextEditingController();
  final bus2Controller = TextEditingController();
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
              'Switches Form',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Input fields
            Input(
              controller: manufacturerController,
              hintText: 'Manufacturer',
            ),
            const SizedBox(height: 20),
            Input(
              controller: nameController,
              hintText: 'Name',
            ),
            const SizedBox(height: 20),
            Input(
              controller: bus1Controller,
              hintText: 'Bus1',
            ),
            const SizedBox(height: 20),
            Input(
              controller: bus2Controller,
              hintText: 'Bus2',
            ),
            const SizedBox(height: 20),
            Input(
              controller: phasesController,
              hintText: 'Phases',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Input(
              controller: statusController,
              hintText: 'Status',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle form submission
                final switchData = {
                  'Manufacturer': manufacturerController.text,
                  'Name': nameController.text,
                  'Bus1': bus1Controller.text,
                  'Bus2': bus2Controller.text,
                  'Phases': int.tryParse(phasesController.text) ?? 0,
                  'Status': statusController.text,
                };
                print('Switch Data: $switchData');
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
