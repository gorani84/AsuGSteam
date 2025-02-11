import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class GeneratorForm extends StatefulWidget {
  const GeneratorForm({super.key});

  @override
  State<GeneratorForm> createState() => _GeneratorFormState();
}

class _GeneratorFormState extends State<GeneratorForm> {
  // Controllers for Generator form fields
  final manufacturerController = TextEditingController();
  final nameController = TextEditingController();
  final bus1Controller = TextEditingController();
  final phasesController = TextEditingController();
  final kvController = TextEditingController();
  final kwController = TextEditingController();
  final pfController = TextEditingController();
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
              'Generator Form',
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
                controller: pfController,
                hintText: 'Power Factor (PF)',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: modelController,
                hintText: 'Model',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(controller: statusController, hintText: 'Status'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
