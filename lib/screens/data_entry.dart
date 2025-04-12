import 'package:asugs/components/electric_components/input/capacitor_banks.dart';
import 'package:asugs/components/electric_components/input/circuitBreakers.dart';
import 'package:asugs/components/electric_components/input/energyMeters.dart';
import 'package:asugs/components/electric_components/input/fuses.dart';
import 'package:asugs/components/electric_components/input/generator.dart';
import 'package:asugs/components/electric_components/input/inverters.dart';
import 'package:asugs/components/electric_components/input/load.dart';
import 'package:asugs/components/electric_components/input/reactor.dart';
import 'package:asugs/components/electric_components/input/shuntElements.dart';
import 'package:asugs/components/electric_components/input/storageDevices.dart';
import 'package:asugs/components/electric_components/input/switches.dart';
import 'package:asugs/components/electric_components/input/transformers.dart';
import 'package:asugs/components/electric_components/input/voltageRegulators.dart';
import 'package:asugs/components/ui/input.dart';
import 'package:asugs/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class FloatingLabelTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const FloatingLabelTextField({
    required this.controller,
    required this.labelText,
    Key? key,
  }) : super(key: key);

  @override
  _FloatingLabelTextFieldState createState() => _FloatingLabelTextFieldState();
}

class _FloatingLabelTextFieldState extends State<FloatingLabelTextField> {
  late FocusNode _focusNode;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool hasText = widget.controller.text.isNotEmpty;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                  top: widget.controller.text.isEmpty ? 24 : 24,
                  bottom: widget.controller.text.isEmpty ? 12 : 12,
                  left: 12,
                  right: 12),
              border: OutlineInputBorder(),
            ),
          ),
          Positioned(
            left: 12,
            top: hasText || isFocused
                ? 4
                : 14, // Adjust label position based on text input
            child: Text(
              widget.labelText,
              style: TextStyle(
                fontSize: hasText || isFocused ? 12 : 16,
                color: kPrimaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ComponentType {
  transformers,
  capacitorBanks,
  generator,
  load,
  reactor,
  voltageRegulators,
  switches,
  fuses,
  circuitBreakers,
  energyMeters,
  storageDevices,
  inverters,
  shuntElements
}

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  State<DataEntryPage> createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  // Text editing controllers
  final componentIDController = TextEditingController();
  final electricalSpecController = TextEditingController();
  final connectionPointsController = TextEditingController();
  final geoLocationController =
      TextEditingController(); // Geolocation controller
  final installationDateController = TextEditingController();
  final operationStatusController = TextEditingController();
  final derController = TextEditingController(); // Optional DER input

  ComponentType selectedComponentType = ComponentType.transformers;

  // Dynamic parameter controllers
  final Map<String, TextEditingController> parameterControllers = {};

  String selectedComponentTypeString = '';
  List<String> parameterFields = [];

  // Define Parameter fields for each component type
  final Map<String, List<String>> componentParameters = {
    'Transformer': [
      'Name', // Component schematic name in openDSS
      'Conn1', // connection type for winding 1
      'Conn2', // connection type for winding 2
      'Kv1', //kV rating for winding 1
      'Kv2', // kV rating for winding 2
      'Kva1', // kVA rating for winding 1
      'Kva2', // kVA rating for winding 2
      'R1',
      'R2',
    ],
    'Fuse': [
      'Name', // Component schematic name in openDSS
      'Monitored Object',
      'Monitored Terminal',
      'Status',
    ],
    'Reactor': [
      'Name',
      'Bus1',
      'Bus2',
      'Phases',
      'R',
      'X',
    ],
    'Capacitor Bank': [
      'Name',
      'Bus1',
      'kV',
      'kVAR',
      'Phases',
    ],
  };

  @override
  void dispose() {
    componentIDController.dispose();
    electricalSpecController.dispose();
    connectionPointsController.dispose();
    geoLocationController.dispose();
    installationDateController.dispose();
    operationStatusController.dispose();
    derController.dispose();
    parameterControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void updateParameterFields(String componentType) {
    setState(() {
      selectedComponentTypeString = componentType;
      parameterFields = componentParameters[componentType] ?? [];
      parameterControllers.clear();
      for (var field in parameterFields) {
        parameterControllers[field] = TextEditingController();
      }
    });
  }

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
    final url = Uri.parse('https://asugs-flask-backend.onrender.com/send-data');
    final body = jsonEncode({
      'component_id': componentIDController.text,
      'component_type': selectedComponentType?.name,
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

      if (response.statusCode == 201) {
        print('Data sent successfully!');
      } else {
        print('Failed to send data. Error: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  //get data from table by referencing component id
  Future<void> fetchDataByComponentId() async {
    // Get the component ID from the text field
    final componentId = componentIDController.text;
    final url = Uri.parse(
        'https://asugs-flask-backend.onrender.com/get-data/$componentId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data fetched successfully: $data');

        // Populate the text fields with fetched data
        setState(() {
          selectedComponentType = ComponentType.values.firstWhere(
            (e) => e.name == data['component_type'],
            orElse: () => ComponentType.transformers,
          );
          electricalSpecController.text =
              data['electrical_specifications'] ?? '';
          connectionPointsController.text = data['connection_points'] ?? '';
          geoLocationController.text = data['geolocation'] ?? '';
          installationDateController.text = data['installation_date'] ?? '';
          operationStatusController.text = data['operation_status'] ?? '';
          derController.text = data['der'] ?? '';
        });
      } else {
        print('Failed to fetch data. Error: ${response.body}');
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
                    "Component Parameters",
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  // Component ID field
                  Input(
                    controller: componentIDController,
                    hintText: 'Component ID',
                    enabled: true,
                  ),
                  const SizedBox(height: 30),

                  // Component Type field
                  _buildDropdownField(),
                  const SizedBox(height: 30),

                  // Electrical Specifications field
                  Input(
                    controller: electricalSpecController,
                    hintText: 'Electrical Specifications',
                  ),
                  const SizedBox(height: 30),

                  // Connection Points field
                  Input(
                    controller: connectionPointsController,
                    hintText: 'Connection Points',
                  ),
                  const SizedBox(height: 30),

                  // Geolocation field (read-only)
                  Input(
                    controller: geoLocationController,
                    hintText: 'Geo Location (Latitude, Longitude)',
                    enabled: true, // Read-only
                  ),
                  const SizedBox(height: 30),

                  // Installation Date field with Date Picker
                  _buildInstallationDateField(),
                  const SizedBox(height: 30),

                  // Operation Status field
                  Input(
                    controller: operationStatusController,
                    hintText: 'Operation Status (active/inactive/maintenance)',
                  ),
                  const SizedBox(height: 30),

                  // Optional DER field
                  Input(
                    controller: derController,
                    hintText: 'Distributed Energy Resource (Optional)',
                  ),
                  const SizedBox(height: 30),

                  // component input types
                  _componentInputWidget(),

                  // Send data button
                  _buildSendButton(),

                  const SizedBox(height: 30),

                  //get data button
                  _buildFetchButton(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _componentInputWidget() {
    switch (selectedComponentType) {
      case ComponentType.transformers:
        return TransformersForm();
      case ComponentType.capacitorBanks:
        return CapacitorBanksForm();
      case ComponentType.generator:
        return GeneratorForm();
      case ComponentType.load:
        return LoadForm();
      case ComponentType.reactor:
        return ReactorForm();
      case ComponentType.voltageRegulators:
        return VoltageRegulatorsForm();
      case ComponentType.switches:
        return SwitchesForm();
      case ComponentType.fuses:
        return FusesForm();
      case ComponentType.circuitBreakers:
        return CircuitBreakerForm();
      case ComponentType.energyMeters:
        return EnergyMeterForm();
      case ComponentType.storageDevices:
        return StorageDevicesForm();
      case ComponentType.inverters:
        return InvertersForm();
      case ComponentType.shuntElements:
        return ShuntElementForm();
      default:
        return Container();
    }
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<ComponentType>(
      value: selectedComponentType,
      hint: const Text('Component Type'),
      items: ComponentType.values.map((ComponentType type) {
        return DropdownMenuItem<ComponentType>(
          value: type,
          child: Text(type.name),
        );
      }).toList(),
      onChanged: (ComponentType? value) {
        setState(() {
          if (value != null) {
            selectedComponentType = value;
          }
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border by default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.grey, width: 1.0), // Customize enabled border
        ),
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
          firstDate: DateTime(2000), // Earliest selectable date
          lastDate: DateTime(2100), // Latest selectable date
        );

        if (pickedDate != null) {
          // Format the selected date as MM-DD-YYYY
          String formattedDate =
              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
          setState(() {
            installationDateController.text =
                formattedDate; // Set the selected date in the controller
          });
        }
      },
      child: AbsorbPointer(
        child: Input(
          controller: installationDateController,
          hintText: 'Installation Date (YYYY-MM-DD)',
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

  Widget _buildFetchButton() {
    return ElevatedButton(
      onPressed: fetchDataByComponentId,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        backgroundColor: kSecondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Get Data',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
