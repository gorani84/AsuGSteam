import 'package:asugs/constants.dart';
import 'package:asugs/screens/add_component.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkOrderPage extends StatefulWidget {
  const WorkOrderPage({super.key});

  @override
  State<WorkOrderPage> createState() => _WorkOrderPageState();
}

class _WorkOrderPageState extends State<WorkOrderPage> {
  // Text editing controllers
  final workOrderIDController = TextEditingController();
  final circuitIDController = TextEditingController();
  final schematicIDController = TextEditingController();
  final equipmentIDController = TextEditingController();

  // Store API response data
  String? Bus1;
  String? Bus2;

  Future<void> checkWorkOrder() async {
  final String workOrderID = workOrderIDController.text;

  if (workOrderID.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter work order number.")),
    );
    return;
  }

  final Uri url = Uri.parse(
      'https://asugs-flask-backend.onrender.com/process_work_order/$workOrderID');

  try {
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'}, // Headers are fine
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        Bus1 = data['Bus_1']; // Make sure this matches the API response key
        Bus2 = data['Bus_2'];
      });

      String action = data['action']; //"replace_component" or "add_component"

      // Navigate based on action
      if (action == "replace_component") {
        Navigator.pushNamed(
          context,
          '/replaceComponent',
          arguments: {'Bus1': Bus1, 'Bus2': Bus2},
        );
      } else if (action == "add_component") {
        Navigator.pushNamed(
          context,
          '/addComponent',
          arguments: {'Bus1': Bus1, 'Bus2': Bus2},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unexpected response from server")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error: ${response.statusCode}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

    @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String?>?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        surfaceTintColor: kPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Image.asset(
          'assets/images/banner_logo_maroon.png',
          fit: BoxFit.contain,
          height: 40,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Work Order",
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  // Work Order Number field
                  FloatingLabelTextField(
                    controller: workOrderIDController,
                     labelText: 'Work Order Number',
                  ),
                  const SizedBox(height: 30),

                  // Circuit ID Field
                  FloatingLabelTextField(
                    controller: circuitIDController,
                     labelText: 'Circuit ID',
                  ),
                  const SizedBox(height: 30),

                  // Schematic Component ID field
                  FloatingLabelTextField(
                    controller: schematicIDController,
                     labelText: 'Component Schematic ID',
                  ),
                  const SizedBox(height: 30),

                  // Equipment ID field
                  FloatingLabelTextField(
                    controller: equipmentIDController, 
                      labelText: 'Equipment ID'
                  ),

                  const SizedBox(height: 30),

                  _buildSearchButton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // Custom Search Data Button
  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: checkWorkOrder,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        backgroundColor: kSecondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Search',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

