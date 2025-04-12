import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class CircuitBreakerForm extends StatefulWidget {
  const CircuitBreakerForm({super.key});

  @override
  State<CircuitBreakerForm> createState() => _CircuitBreakerFormState();
}

class _CircuitBreakerFormState extends State<CircuitBreakerForm> {
  // Controllers for each field
  final manufacturerController = TextEditingController();
  final nameController = TextEditingController();
  final bus1Controller = TextEditingController();
  final bus2Controller = TextEditingController();
  final phasesController = TextEditingController();
  final kvController = TextEditingController();
  final ampRatingController = TextEditingController();
  final monitoredObjController = TextEditingController();
  final monitoredTermController = TextEditingController();
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
              'Circuit Breaker Parameters',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Form fields based on the database schema
            Input(controller: manufacturerController, hintText: 'Manufacturer'),
            const SizedBox(height: 20),

            Input(controller: nameController, hintText: 'Name'),
            const SizedBox(height: 20),

            Input(controller: bus1Controller, hintText: 'Bus 1'),
            const SizedBox(height: 20),

            Input(controller: bus2Controller, hintText: 'Bus 2'),
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
                controller: ampRatingController,
                hintText: 'Amp Rating',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            Input(
                controller: monitoredObjController,
                hintText: 'Monitored Object'),
            const SizedBox(height: 20),

            Input(
                controller: monitoredTermController,
                hintText: 'Monitored Terminal',
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
    bus2Controller.dispose();
    phasesController.dispose();
    kvController.dispose();
    ampRatingController.dispose();
    monitoredObjController.dispose();
    monitoredTermController.dispose();
    statusController.dispose();
    super.dispose();
  }
}
