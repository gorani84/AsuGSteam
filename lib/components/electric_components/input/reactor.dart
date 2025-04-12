import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class ReactorForm extends StatefulWidget {
  const ReactorForm({super.key});

  @override
  State<ReactorForm> createState() => _ReactorFormState();
}

class _ReactorFormState extends State<ReactorForm> {
  // Controllers for the form fields
  final manufacturerController = TextEditingController();
  final nameController = TextEditingController();
  final bus1Controller = TextEditingController();
  final bus2Controller = TextEditingController();
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
              'Reactor Form',
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
              controller: kvController,
              hintText: 'kV',
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
