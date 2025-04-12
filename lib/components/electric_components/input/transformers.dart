import 'package:asugs/components/ui/input.dart';
import 'package:flutter/material.dart';

class TransformersForm extends StatefulWidget {
  const TransformersForm({super.key});

  @override
  State<TransformersForm> createState() => _TransformersFormState();
}

class _TransformersFormState extends State<TransformersForm> {
  // Required parameters controllers
  final manufacturerController = TextEditingController();
  final nameController = TextEditingController();
  final phasesController = TextEditingController();
  final windingsController = TextEditingController();
  final xhlController = TextEditingController();
  final bus1Controller = TextEditingController();
  final conn1Controller = TextEditingController();
  final kv1Controller = TextEditingController();
  final kva1Controller = TextEditingController();
  final r1Controller = TextEditingController();
  final bus2Controller = TextEditingController();
  final conn2Controller = TextEditingController();

  // Optional parameters controllers
  final kv2Controller = TextEditingController();
  final kva2Controller = TextEditingController();
  final r2Controller = TextEditingController();
  final imagController = TextEditingController();
  final rsController = TextEditingController();
  final noloadLossController = TextEditingController();
  final xhtController = TextEditingController();
  final xltController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transformers Form',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Required fields
            const SizedBox(height: 20),
            Input(controller: manufacturerController, hintText: 'Manufacturer'),
            const SizedBox(height: 20),
            Input(controller: nameController, hintText: 'Name'),
            const SizedBox(height: 20),
            Input(
                controller: phasesController,
                hintText: 'Phases',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: windingsController,
                hintText: 'Windings',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: xhlController,
                hintText: 'Xhl',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(controller: bus1Controller, hintText: 'Bus 1'),
            const SizedBox(height: 20),
            Input(controller: conn1Controller, hintText: 'Conn 1'),
            const SizedBox(height: 20),
            Input(
                controller: kv1Controller,
                hintText: 'Kv1',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: kva1Controller,
                hintText: 'Kva1',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: r1Controller,
                hintText: 'R1',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(controller: bus2Controller, hintText: 'Bus 2'),
            const SizedBox(height: 20),
            Input(controller: conn2Controller, hintText: 'Conn 2'),

            const SizedBox(height: 20),
            const Text(
              'Optional Parameters',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Optional fields
            Input(
                controller: kv2Controller,
                hintText: 'Kv2',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: kva2Controller,
                hintText: 'Kva2',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: r2Controller,
                hintText: 'R2',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: imagController,
                hintText: '% Imag',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: rsController,
                hintText: '% Rs',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: noloadLossController,
                hintText: '% No-load Loss',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: xhtController,
                hintText: 'Xht',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Input(
                controller: xltController,
                hintText: 'Xlt',
                keyboardType: TextInputType.number),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
