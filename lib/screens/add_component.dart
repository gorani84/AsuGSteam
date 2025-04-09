import 'package:gridscout/constants.dart';
import 'package:gridscout/screens/replace_component.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
        widget.onTap?.call();
        if (widget.onTap == null) {
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
            keyboardType: TextInputType.text,
            minLines: 1,
            maxLines: 1,
            onTap: widget.onTap,
            maxLength:
                widget.labelText == "Notes (Max 200 Characters)" ? 200 : null,
            inputFormatters: widget.labelText == "Notes (Max 200 Characters)"
                ? [LengthLimitingTextInputFormatter(200)]
                : [],
            decoration: InputDecoration(
              counterText: '',
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

class AddComponentPage extends StatefulWidget {
  const AddComponentPage({super.key});

  @override
  State<AddComponentPage> createState() => _AddComponentPageState();
}

class _AddComponentPageState extends State<AddComponentPage> {
  // Text editing controllers
  final equipmentIDController = TextEditingController();
  final componentIDController = TextEditingController();
  final componentTypeController = TextEditingController();
  final geoLocationController =
      TextEditingController(); // Geolocation controller
  final installationDateController = TextEditingController();
  final bus1Controller = TextEditingController();
  final bus2Controller = TextEditingController();
  final serialNumberController = TextEditingController();
  final notesController = TextEditingController();
  final circuitIDController = TextEditingController();

  // Dynamic parameter controllers
  final Map<String, TextEditingController> parameterControllers = {};

  String selectedComponentType = '';
  List<String> parameterFields = [];

  // List of component types from database
  final List<String> componentTypes = [
    'Transformer',
    'Fuse',
    'Reactor',
    'Capacitor',
    'Generator'
  ];

  // Define Parameter fields for each component type based on database schema
  final Map<String, List<String>> componentParameters = {
    'Transformer': [
      'Phases',
      'Windings',
      'Xhl',
      'Conn1',
      'kV1',
      'kVA1',
      'Conn2',
      'kV2',
      'kVA2',
    ],
    'Fuse': [
      'Bus1',
      'Monitored Object',
      'RatedCurrent',
    ],
    'Reactor': [
      'Bus1',
      'Phases',
      'kV',
      'kVAR',
    ],
    'Capacitor': [
      'Bus1',
      'Phases',
      'kVAR',
      'kV',
    ],
    'Generator': [
      'Bus1',
      'Phases',
      'kV',
      'kW',
      'kvar',
      'Model',
    ]
  };

  // Equipment IDs from database
  final List<String> equipmentIDs = [
    'T1',
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'T8',
    'T9',
    'T10',
    'T11',
    'T12',
    'Cap1',
    'Cap2',
    'Cap3',
    'Cap4',
    'Cap5',
    'FuseX',
    'FuseA',
    'FuseB',
    'FuseC',
    'FuseD',
    'PVGen',
    'Secondary_Reactor'
  ];

  // Serial numbers from database
  final List<String> serialNumbers = [
    'GE-TX100',
    'SIE-TX200',
    'ASU-TX300',
    'SCH-TX400',
    'EAT-TX500',
    'HIT-TX600',
    'MITS-TX700',
    'GE-TX800',
    'SIE-TX900',
    'ABB-TX1000',
    'ASU-TX400',
    'GE-CAP100',
    'SIE-CAP200',
    'ASU-CAP300',
    'SCH-CAP400',
    'EAT-CAP500',
    'GE-FUS100',
    'SIE-FUS200',
    'ASU-FUS300',
    'SCH-FUS400',
    'EAT-FUS500',
    'GE-GEN100',
    'ASU-REA100'
  ];

  // List for work order numbers
  final List<String> workOrderNumbers = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15'
  ];

  // Variables to hold Bus1 and Bus2
  String bus1 = '';
  String bus2 = '';

  //Check the first letter of the Equip ID and update component Type accordingly
  @override
  void initState() {
    super.initState();
    _determinePosition(); // ask for geo location upon page opening

    equipmentIDController.addListener(() {
      String equipmentID = equipmentIDController.text;

      if (equipmentID.isNotEmpty) {
        String firstLetter = equipmentID[0].toUpperCase();
        String componentType = '';

        switch (firstLetter) {
          case 'T':
            componentType = 'Transformer';
            break;
          case 'C':
            componentType = 'Capacitor';
            break;
          case 'R':
            componentType = 'Reactor';
            break;
          case 'G':
            componentType = 'Generator';
            break;
          default:
            componentType = '';
        }

        if (componentType != componentTypeController.text) {
          setState(() {
            componentTypeController.text = componentType;
            updateParameterFields(componentType);
          });
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    final args = route?.settings.arguments as Map<String, dynamic>;

    if (args != null) {
      setState(() {
        bus1 = args['Bus1'] ?? '';
        bus2 = args['Bus2'] ?? '';
        equipmentIDController.text = args['EquipmentID'] ?? '';
        componentIDController.text = args['SchematicID'] ?? '';
        serialNumberController.text = args['SerialNumber'] ?? '';

        // Initialize controllers with values for bus1 and bus2
        bus1Controller.text = bus1;
        bus2Controller.text = bus2;

        // Update the dynamic fields if the component type is Reactor
        final componentType = componentTypeController.text;

        // components that require bus 1 and bus 2 updates
        final componentsWithBus = ['Reactor', 'Capacitor', 'Generator', 'Fuse'];

        if (componentsWithBus.contains(componentType)) {
          parameterFields = componentParameters[componentType] ?? [];
          parameterControllers.clear();
          parameterControllers['Bus1']?.text = bus1;
          parameterControllers['Bus2']?.text = bus2;

          for (var field in parameterFields) {
            parameterControllers[field] = TextEditingController();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    componentTypeController.dispose();
    componentIDController.dispose();
    geoLocationController.dispose();
    installationDateController.dispose();
    parameterControllers.forEach((key, controller) => controller.dispose());
    notesController.dispose();
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

      if (['Reactor', 'Transformer', 'Capacitor', 'Generator']
          .contains(componentType)) {
        parameterControllers['Bus1']?.text = bus1;
        parameterControllers['Bus2']?.text = bus2;
      }
    });
  }

  // Method to determine the current position
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location services are disabled. Please enable location services.')),
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location permissions are denied. Please enable them in settings.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permissions are permanently denied. Please enable them in settings.')),
        );
        return;
      }

      // Get the current position and update the controller
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        geoLocationController.text =
            "${position.latitude}, ${position.longitude}";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  // Send data method
  Future<void> sendData() async {
    try {
      // Create base payload
      Map<String, dynamic> payload = {
        'component_id': componentIDController.text,
        'component_type': selectedComponentType,
        'parameters': {},
        'tracking_info': {
          'circuit_id': circuitIDController.text,
          'bus_1': bus1Controller.text,
          'bus_2': bus2Controller.text,
        },
        'instance_info': {
          'equipment_id': equipmentIDController.text,
          'serial_number': serialNumberController.text,
          'notes': notesController.text,
        }
      };

      // Add parameters based on component type
      switch (selectedComponentType.toLowerCase()) {
        case 'transformer':
          payload['parameters'] = {
            'phases': _parseNumericValue(parameterControllers['Phases']?.text),
            'windings':
                _parseNumericValue(parameterControllers['Windings']?.text),
            'xhl': _parseNumericValue(parameterControllers['Xhl']?.text),
            'conn1': parameterControllers['Conn1']?.text,
            'kv1': _parseNumericValue(parameterControllers['kV1']?.text),
            'kva1': _parseNumericValue(parameterControllers['kVA1']?.text),
            'conn2': parameterControllers['Conn2']?.text,
            'kv2': _parseNumericValue(parameterControllers['kV2']?.text),
            'kva2': _parseNumericValue(parameterControllers['kVA2']?.text),
          };
          break;

        case 'capacitor':
          payload['parameters'] = {
            'phases': _parseNumericValue(parameterControllers['Phases']?.text),
            'kvar': _parseNumericValue(parameterControllers['kVAR']?.text),
            'kv': _parseNumericValue(parameterControllers['kV']?.text),
          };
          break;

        case 'reactor':
          payload['parameters'] = {
            'phases': _parseNumericValue(parameterControllers['Phases']?.text),
            'kv': _parseNumericValue(parameterControllers['kV']?.text),
            'kvar': _parseNumericValue(parameterControllers['kVAR']?.text),
          };
          break;

        case 'generator':
          payload['parameters'] = {
            'phases': _parseNumericValue(parameterControllers['Phases']?.text),
            'kv': _parseNumericValue(parameterControllers['kV']?.text),
            'kw': _parseNumericValue(parameterControllers['kW']?.text),
            'kvar': _parseNumericValue(parameterControllers['kvar']?.text),
            'model': parameterControllers['Model']?.text,
          };
          break;

        case 'fuse':
          payload['parameters'] = {
            'monitored_object': parameterControllers['Monitored Object']?.text,
            'rated_current':
                _parseNumericValue(parameterControllers['RatedCurrent']?.text),
          };
          break;
      }

      final geoLocation = geoLocationController.text
          .split(',')
          .map((e) => double.tryParse(e.trim()) ?? 0.0)
          .toList();

      if (geoLocation.length >= 2) {
        payload['geolocation'] = geoLocation;
      }

      final response = await http.post(
        Uri.parse('https://asugs-flask-backend.onrender.com/add_component'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Component added successfully!')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  // Helper method to parse numeric values
  dynamic _parseNumericValue(String? value) {
    if (value == null || value.isEmpty) return null;

    // Try parsing as double first
    final doubleValue = double.tryParse(value);
    if (doubleValue == null) return value; // Return as string if not numeric

    // If it's a whole number, return as int
    if (doubleValue == doubleValue.roundToDouble()) {
      return doubleValue.toInt();
    }

    // Otherwise return as double with original precision
    return doubleValue;
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
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          // Extract parameters from the response
          Map<String, dynamic> parameters = {};
          data.forEach((key, value) {
            // Skip non-parameter fields
            if (![
              'component_id',
              'component_type',
              'action',
              'Bus_1',
              'Bus_2',
              'Schematic_ID',
              'Circuit_ID'
            ].contains(key)) {
              parameters[key] = value;
            }
          });
          return parameters;
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
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/substation_background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Add a Component",
                      style: TextStyle(fontSize: 28, color: Colors.white),
                    ),
                    const SizedBox(height: 40),

                    // Component Type field
                    FloatingLabelTextField(
                      controller: componentTypeController,
                      labelText: 'Component Type',
                    ),

                    const SizedBox(height: 30),

                    // Component ID field
                    FloatingLabelTextField(
                      controller: componentIDController,
                      labelText: 'Component ID',
                    ),

                    const SizedBox(height: 30),

                    // Equipment ID field
                    FloatingLabelTextField(
                        controller: equipmentIDController,
                        labelText: 'Equipment ID'),

                    const SizedBox(height: 30),

                    // Geolocation field
                    FloatingLabelTextField(
                      controller: geoLocationController,
                      labelText: 'Geo Location (Latitude, Longitude)',
                    ),
                    const SizedBox(height: 30),

                    // Installation Date field with Date Picker
                    _buildInstallationDateField(),
                    const SizedBox(height: 30),

                    // Serial Number field
                    FloatingLabelTextField(
                        controller: serialNumberController,
                        labelText: 'Serial Number'),

                    const SizedBox(height: 30),

                    // Render dynamic parameter fields for selected component type
                    if (parameterFields.isNotEmpty)
                      ...parameterFields.map((field) {
                        return Column(
                          children: [
                            FloatingLabelTextField(
                              controller: parameterControllers[field]!,
                              labelText: field,
                            ),
                            const SizedBox(height: 30),
                          ],
                        );
                      }).toList(),

                    // Notes field
                    Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: FloatingLabelTextField(
                          controller: notesController,
                          labelText: 'Notes (Max 200 Characters)'),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    _buildFetchButton(),
                    const SizedBox(height: 16),
                    _buildAddComponentButton(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReplaceComponentPage(),
                            settings: RouteSettings(
                              arguments: {
                                'Bus1': bus1,
                                'Bus2': bus2,
                                'EquipmentID': equipmentIDController.text,
                                'SchematicID': componentIDController.text,
                                'SerialNumber': serialNumberController.text
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        backgroundColor: kSecondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Replace Component',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
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
        child: FloatingLabelTextField(
          controller: installationDateController,
          labelText: 'Installation Date (YYYY-MM-DD)',
        ),
      ),
    );
  }

  // Custom Send Data Button
  Widget _buildAddComponentButton() {
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
        'Add Component',
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

          // Update parameter controllers with the fetched data
          data.forEach((key, value) {
            if (parameterControllers.containsKey(key)) {
              parameterControllers[key]?.text = value.toString();
            }
          });

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
        'Find Component Parameters',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
