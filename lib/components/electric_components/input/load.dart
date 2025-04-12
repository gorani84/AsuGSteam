import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class LoadForm extends StatefulWidget {
  const LoadForm({super.key});

  @override
  State<LoadForm> createState() => _LoadFormState();
}

class _LoadFormState extends State<LoadForm> {
  // Controllers for the form fields
  final nameController = TextEditingController();
  final busController = TextEditingController();
  final phasesController = TextEditingController();
  final kvController = TextEditingController();
  final kwController = TextEditingController();
  final kvarController = TextEditingController();
  final connectionTypeController = TextEditingController();
  final modelController = TextEditingController();
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
              'Load Form',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Input fields
            Input(
              controller: nameController,
              hintText: 'Name',
            ),
            const SizedBox(height: 20),
            Input(
              controller: busController,
              hintText: 'Bus',
            ),
            const SizedBox(height: 20),
            Input(
              controller: phasesController,
              hintText: 'Phases',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Input(
              controller: kvController,
              hintText: 'kV',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            Input(
              controller: kwController,
              hintText: 'kW',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            Input(
              controller: kvarController,
              hintText: 'kVAR',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            Input(
              controller: connectionTypeController,
              hintText: 'Connection Type',
            ),
            const SizedBox(height: 20),
            Input(
              controller: modelController,
              hintText: 'Model',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Input(
              controller: statusController,
              hintText: 'Status',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
