import 'package:gridscout/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';

class FloatingLabelTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final VoidCallback? onTap;

  const FloatingLabelTextField({
    required this.controller,
    required this.labelText,
    this.onTap,
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
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          FocusScope.of(context).requestFocus(_focusNode);
        }
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
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.labelText.replaceAll(' \u2731', ''),
                    style: TextStyle(
                      fontSize: hasText || isFocused ? 12 : 16,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (widget.labelText.contains('\u2731'))
                    TextSpan(
                      text: ' \u2731',
                      style: TextStyle(
                        fontSize: hasText || isFocused ? 12 : 16,
                        color: kSecondaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  State<DataEntryPage> createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  // Text editing controllers
  final componentIDController = TextEditingController();
  final componentTypeController = TextEditingController();
  final geoLocationController =
      TextEditingController(); // Geolocation controller
  final installationDateController = TextEditingController();

  // Dynamic parameter controllers
  final Map<String, TextEditingController> parameterControllers = {};

  String selectedComponentType = '';
  List<String> parameterFields = [];

  // List of component types for the picker
  final List<String> componentTypes = [
    'Transformer',
    'Fuse',
    'Reactor',
    'Capacitor Bank'
  ];

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
    //Add other component types here
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
    //Add more component types here like this until all component types needed are added in this dynamic parameter editor
  };

  @override
  void dispose() {
    componentTypeController.dispose();
    componentIDController.dispose();
    geoLocationController.dispose();
    installationDateController.dispose();
    parameterControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void updateParameterFields(String componentType) {
    setState(() {
      selectedComponentType = componentType;
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

    // Add listener to the componentTypeController to update parameter fields
    componentTypeController.addListener(() {
      final componentType = componentTypeController.text;
      updateParameterFields(
          componentType); // Update parameter fields when the text changes
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
  Future<void> sendData() async {
    try {
      if (componentIDController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Component ID is required")),
        );
        return;
      }

      if (componentTypeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Component Type is required")),
        );
        return;
      }

      // Print controllers to debug
      print("Parameter controllers: ${parameterControllers.length}");
      parameterControllers.forEach((key, controller) {
        print("Key: $key, Value: ${controller.text}");
      });

      // Create a payload with parameters nested under a 'parameters' key
      Map<String, dynamic> payload = {
        'component_id': componentIDController.text,
        'component_type': selectedComponentType,
        'parameters': {},
      };

      // Add parameters from controllers to the nested 'parameters' object
      parameterControllers.forEach((key, controller) {
        final value = controller.text;
        if (value.isNotEmpty) {
          // Try to preserve the same number format as the GET response
          if (double.tryParse(value) != null) {
            // For values like "5000.00", keep them as strings to preserve decimals
            if (value.contains('.')) {
              payload['parameters'][key] = value;
            } else {
              // For integer values, convert to int
              payload['parameters'][key] = int.parse(value);
            }
          } else {
            payload['parameters'][key] = value;
          }
        }
      });

      final geoLocation = geoLocationController.text
          .split(',')
          .map((e) => double.tryParse(e.trim()) ?? 0.0)
          .toList();

      if (geoLocation.length >= 2) {
        payload['geolocation'] = geoLocation;
      }

      // Convert the payload to JSON and log it for debugging
      final jsonPayload = jsonEncode(payload);
      print("Sending complete payload: $jsonPayload");

      final response = await http.post(
        Uri.parse('https://asugs-flask-backend.onrender.com/modify_component'),
        headers: {'Content-Type': 'application/json'},
        body: jsonPayload,
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Component updated successfully!')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      print("Exception in sendData: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  //get data from table by referencing component id
  Future<Map<String, dynamic>> fetchDataByComponentId(
      String componentId, String componentType) async {
    final String baseUrl = "https://asugs-flask-backend.onrender.com/get_data";
    final Uri url =
        Uri.parse("$baseUrl/$componentId?component_type=$componentType");

    try {
      final response = await http.get(url);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // The API is returning parameters directly in the response, not inside a 'parameters' object
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          // Return the data directly since it contains the parameters
          return data;
        } else {
          throw Exception("Invalid response format");
        }
      } else if (response.statusCode == 404) {
        throw Exception('Component not found.');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An error occurred: $e');
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
                  // Component Type field
                  FloatingLabelTextField(
                    controller: componentTypeController,
                    labelText: 'Component Type \u2731',
                    onTap: () => _showPicker(
                      context,
                      componentTypes,
                      'Select Component Type',
                      componentTypeController,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Component ID field
                  TextField(
                    controller: componentIDController,
                    decoration: InputDecoration(
                      labelText: 'Component ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Geolocation field
                  TextField(
                    controller: geoLocationController,
                    decoration: InputDecoration(
                      labelText: 'Geo Location (Latitude, Longitude)',
                      border: OutlineInputBorder(),
                    ),
                    enabled: true,
                  ),
                  const SizedBox(height: 30),

                  // Installation Date field with Date Picker
                  _buildInstallationDateField(),
                  const SizedBox(height: 30),

                  // Render dynamic parameter fields for selected component type
                  if (parameterFields.isNotEmpty)
                    ...parameterFields.map((field) {
                      return Column(
                        children: [
                          _buildTextField(
                            controller: parameterControllers[field]!,
                            hintText: field,
                          ),
                          const SizedBox(
                              height: 30), // Add spacing between dynamic fields
                        ],
                      );
                    }).toList(),
                  const SizedBox(height: 30),

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
          firstDate: DateTime(2000), // Earliest selectable date
          lastDate: DateTime(2100), // Latest selectable date
        );

        if (pickedDate != null) {
          // Ensure MM and DD always have two digits
          String formattedDate =
              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

          setState(() {
            installationDateController.text =
                formattedDate; // Update the text field
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: installationDateController,
          decoration: InputDecoration(
            labelText: 'Installation Date (YYYY-MM-DD)',
            floatingLabelStyle: TextStyle(height: 0.8),
            border: OutlineInputBorder(),
          ),
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
      onPressed: () async {
        final componentId = componentIDController.text.trim();
        final componentType = componentTypeController.text.trim();

        if (componentId.isEmpty || componentType.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Please enter Component ID and Type.")),
          );
          return;
        }

        try {
          // Fetch data from the server
          final data = await fetchDataByComponentId(componentId, componentType);

          if (data.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      "No data found for the provided Component ID and Type.")),
            );
            return;
          }

          // Clear existing parameters first
          parameterControllers.forEach((key, controller) {
            controller.text = "";
          });

          // The API returns parameters directly at the root level, not inside a 'parameters' object
          // Update parameter controllers with the fetched data
          data.forEach((key, value) {
            if (parameterControllers.containsKey(key)) {
              parameterControllers[key]?.text = value.toString();
            } else {
              print("No controller found for parameter: $key");
            }
          });

          // Update the UI to reflect the current component type
          if (selectedComponentType != componentType) {
            setState(() {
              componentTypeController.text = componentType;
              updateParameterFields(componentType);

              // Give the UI a moment to update before setting values again
              Future.delayed(Duration(milliseconds: 100), () {
                data.forEach((key, value) {
                  if (parameterControllers.containsKey(key)) {
                    parameterControllers[key]?.text = value.toString();
                  }
                });
              });
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data fetched successfully!")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      },
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

  // Show picker dialog that works well in Web
  void _showPicker(BuildContext context, List<String> items, String title,
      TextEditingController controller) {
    // Simple dialog approach that works better for web
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  onTap: () {
                    setState(() {
                      controller.text = items[index];
                      if (controller == componentTypeController) {
                        updateParameterFields(items[index]);
                      }
                    });
                    Navigator.pop(context);
                  },
                  tileColor:
                      controller.text == items[index] ? Colors.grey[200] : null,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
