import 'package:gridscout/constants.dart';
import 'package:gridscout/screens/add_component.dart'
    hide FloatingLabelTextField;
import 'package:gridscout/screens/replace_component.dart'
    hide FloatingLabelTextField;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';

// Custom FloatingLabelTextField for this file
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
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: null,
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
  final serialNumberController = TextEditingController();

  // Lists for picker options
  final List<String> workOrderNumbers = List.generate(15, (i) => '${i + 1}');
  final List<String> equipmentIDs = [
    'T1',
    'T2',
    'Cap1',
    'Cap2',
    'FuseX',
    'FuseA',
    'FuseB',
    'FuseC',
    'FuseD',
    'PVGen',
    'Secondary_Reactor'
  ];
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
    'ASU-TX400'
  ];

  // Store API response data
  String? Bus1;
  String? Bus2;

  // Add loading state variable
  bool _isLoading = false;

  // Validation functions
  bool isValidWorkOrder(String value) {
    int? number = int.tryParse(value);
    return number != null && number >= 1 && number <= 12;
  }

  bool isValidEquipmentID(String value) {
    return RegExp(r'^[A-Z][0-9]$').hasMatch(value);
  }

  bool isValidSerialNumber(String value) {
    return RegExp(r'^[A-Z]{3}-[A-Z]{2}[0-9]{3}$').hasMatch(value);
  }

  // Parse QR code data
  void parseQRCode(String qrData) {
    // Expected format: "workOrder|equipmentID|serialNumber"
    List<String> parts = qrData.split('|');
    if (parts.length == 3) {
      String workOrder = parts[0];
      String equipmentID = parts[1];
      String serialNumber = parts[2];

      if (isValidWorkOrder(workOrder) &&
          isValidEquipmentID(equipmentID) &&
          isValidSerialNumber(serialNumber)) {
        setState(() {
          workOrderIDController.text = workOrder;
          equipmentIDController.text = equipmentID;
          serialNumberController.text = serialNumber;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid QR code format")),
          );
        });
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid QR code data")),
        );
      });
    }
  }

  // Show picker dialog
  void _showPicker(BuildContext context, List<String> items, String title,
      TextEditingController controller) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                color: kPrimaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: 0,
                  ),
                  onSelectedItemChanged: (int selectedIndex) {
                    setState(() {
                      controller.text = items[selectedIndex];
                    });
                  },
                  children: items
                      .map((item) => Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkWorkOrder() async {
    setState(() {
      _isLoading = true;
    });

    final String workOrderID = workOrderIDController.text;

    if (!isValidWorkOrder(workOrderID)) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter a valid work order number (1-12).")),
      );
      return;
    }

    if (!isValidEquipmentID(equipmentIDController.text)) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter a valid equipment ID (e.g., T1, C2).")),
      );
      return;
    }

    if (!isValidSerialNumber(serialNumberController.text)) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Please enter a valid serial number (e.g., ASU-GS123).")),
      );
      return;
    }

    final Uri url = Uri.parse(
        'https://asugs-flask-backend.onrender.com/process_work_order/$workOrderID');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Convert Bus values to strings if they're not null
        final bus1Value = data['Bus_1']?.toString() ?? '';
        final bus2Value = data['Bus_2']?.toString() ?? '';
        final schematicId = data['Schematic_ID']?.toString() ?? '';
        final circuitId = data['Circuit_ID']?.toString() ?? '';

        setState(() {
          Bus1 = bus1Value;
          Bus2 = bus2Value;
          schematicIDController.text = schematicId;
          circuitIDController.text = circuitId;
        });

        String action = data['action']?.toString() ?? '';

        if (action == "replace_component") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReplaceComponentPage(),
              settings: RouteSettings(
                arguments: {
                  'Bus1': bus1Value,
                  'Bus2': bus2Value,
                  'EquipmentID': equipmentIDController.text,
                  'SchematicID': schematicId,
                  'SerialNumber': serialNumberController.text
                },
              ),
            ),
          );
        } else if (action == "add_component") {
          Navigator.pushNamed(
            context,
            '/addComponent',
            arguments: {
              'Bus1': bus1Value,
              'Bus2': bus2Value,
              'EquipmentID': equipmentIDController.text,
              'SchematicID': schematicId,
              'SerialNumber': serialNumberController.text
            },
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
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String?>?;

    if (args != null && args['qr'] != null) {
      parseQRCode(args['qr']!);
    }

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
                      "Work Order",
                      style: TextStyle(fontSize: 28, color: Colors.white),
                    ),
                    const SizedBox(height: 40),

                    // QR Code Scan Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/qrcode');
                      },
                      icon: const Icon(Icons.qr_code_scanner,
                          color: Colors.white),
                      label: const Text(
                        'Scan QR Code',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Work Order Number field
                    FloatingLabelTextField(
                      controller: workOrderIDController,
                      labelText: 'Work Order Number \u2731',
                      onTap: () => _showPicker(
                        context,
                        workOrderNumbers,
                        'Select Work Order Number',
                        workOrderIDController,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Circuit ID Field
                    FloatingLabelTextField(
                      controller: circuitIDController,
                      labelText: 'Circuit ID',
                    ),
                    const SizedBox(height: 30),

                    // Schematic ID field
                    FloatingLabelTextField(
                      controller: schematicIDController,
                      labelText: 'Schematic ID',
                    ),
                    const SizedBox(height: 30),

                    // Equipment ID field with picker
                    FloatingLabelTextField(
                      controller: equipmentIDController,
                      labelText: 'Equipment ID \u2731',
                      onTap: () => _showPicker(
                        context,
                        equipmentIDs,
                        'Select Equipment ID',
                        equipmentIDController,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Serial Number field with picker
                    FloatingLabelTextField(
                      controller: serialNumberController,
                      labelText: 'Serial Number \u2731',
                      onTap: () => _showPicker(
                        context,
                        serialNumbers,
                        'Select Serial Number',
                        serialNumberController,
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildSearchButton()
                  ],
                ),
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
      onPressed: _isLoading ? null : checkWorkOrder,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        backgroundColor: kSecondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Searching...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : Text(
              'Search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
    );
  }
}
