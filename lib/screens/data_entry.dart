import 'package:asugs/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  State<DataEntryPage> createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  // Text editing controllers
  final componentIDController = TextEditingController();
  final componentTypeController = TextEditingController();
  final electricalSpecController = TextEditingController();
  final connectionPointsController = TextEditingController();
  final geoLocationController =
  TextEditingController(); // Geolocation controller
  final installationDateController = TextEditingController();
  final operationStatusController = TextEditingController();
  final derController = TextEditingController(); // Optional DER input

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Get geolocation when the page loads

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var args =
      ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
      if (args != null && args['qr'] != null) {
        setState(() {
          componentIDController.text = args['qr']!;
        });
      }
    });
  }

  // Method to determine the current position
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // Location services are not enabled, do nothing
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return; // Permissions are denied, do nothing
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return; // Permissions are permanently denied, do nothing
    }

    // Get the current position and update the controller
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      geoLocationController.text =
      "${position.latitude}, ${position.longitude}";
    });
  }

  // Send data method
  void sendData() async {
    final url = Uri.parse('http://10.130.1.143:5000/send-data');
    final body = jsonEncode({
      'component_id': componentIDController.text,
      'component_type': componentTypeController.text,
      'electrical_specifications': electricalSpecController.text,
      'connection_points': connectionPointsController.text,
      'geolocation': geoLocationController.text,
      'installation_date': installationDateController.text,
      'operation_status': operationStatusController.text,
      'der': derController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Data sent successfully!');
      } else {
        print('Failed to send data. Error: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
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
                    "Add New Component",
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  // Component ID field
                  _buildTextField(
                    controller: componentIDController,
                    hintText: 'Component ID',
                    enabled: true,
                  ),
                  const SizedBox(height: 30),

                  // Component Type field
                  _buildTextField(
                    controller: componentTypeController,
                    hintText: 'Component Type',
                  ),
                  const SizedBox(height: 30),

                  // Electrical Specifications field
                  _buildTextField(
                    controller: electricalSpecController,
                    hintText: 'Electrical Specifications',
                  ),
                  const SizedBox(height: 30),

                  // Connection Points field
                  _buildTextField(
                    controller: connectionPointsController,
                    hintText: 'Connection Points',
                  ),
                  const SizedBox(height: 30),

                  // Geolocation field (read-only)
                  _buildTextField(
                    controller: geoLocationController,
                    hintText: 'Geo Location (Latitude, Longitude)',
                    enabled: true, // Read-only
                  ),
                  const SizedBox(height: 30),

                  // Installation Date field with Date Picker
                  _buildInstallationDateField(),
                  const SizedBox(height: 30),

                  // Operation Status field
                  _buildTextField(
                    controller: operationStatusController,
                    hintText: 'Operation Status (active/inactive/maintenance)',
                  ),
                  const SizedBox(height: 30),

                  // Optional DER field
                  _buildTextField(
                    controller: derController,
                    hintText: 'Distributed Energy Resource (Optional)',
                  ),
                  const SizedBox(height: 30),

                  // Send data button
                  _buildSendButton(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom TextField builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: enabled
            ? Colors.grey[100]
            : Colors.grey[200], // Different color when disabled
        hintStyle: TextStyle(
          color: enabled
              ? Colors.black45
              : Colors.black26, // Lighter hint color when disabled
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border by default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.grey, width: 1.0), // Customize enabled border
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.grey, width: 1.0), // Customize disabled border
        ),
      ),
      style: TextStyle(
        color: Colors.black, // Text color stays black even when disabled
      ),
    );
  }

  // Custom Installation Date Field with Date Picker
  Widget _buildInstallationDateField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000), // Date picker starts from the year 2000
          lastDate: DateTime(2100), // Date picker ends in the year 2100
        );

        if (pickedDate != null) {
          // Format the selected date as MM-DD-YYYY
          String formattedDate =
              "${pickedDate.month}-${pickedDate.day}-${pickedDate.year}";
          setState(() {
            installationDateController.text =
                formattedDate; // Set the selected date in the controller
          });
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(
          controller: installationDateController,
          hintText: 'Installation Date (MM-DD-YYYY)',
          keyboardType: TextInputType.datetime, // Set keyboard type to date
        ),
      ),
    );
  }

  // Custom Send Data Button
  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: sendData,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        backgroundColor: kSecondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Send Data',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}