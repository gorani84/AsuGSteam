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
import 'package:asugs/models/transformer_form_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

enum ComponentType {
  transformer,
  capacitorBank,
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
  final geoLocationController = TextEditingController(); // Geolocation controller
  final installationDateController = TextEditingController();
  final operationStatusController = TextEditingController();
  final componentTypeController = TextEditingController();
  final derController = TextEditingController(); // Optional DER input

  ComponentType selectedComponentType = ComponentType.transformer;
  bool isFetching = false;

  TransformerFormModel? transformerFormModel;

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Get geolocation when the page loads

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
      if (args != null && args['qr'] != null) {
        try {
          String arg = args['qr']!;
          debugPrint("Arg: $arg");
          var name = arg.substring(0, arg.indexOf('_'));
          var componentType = arg.substring(arg.indexOf('_') + 1, arg.length);
          componentTypeController.text = componentType;
          componentIDController.text = name;

          debugPrint("Name: $name");
          debugPrint("Component Type: $componentType");
          selectedComponentType = ComponentType.values
              .firstWhere((type) => type.name == componentTypeController.text.trim().toLowerCase());
          setState(() {});
        } catch (e) {
          debugPrint("Error: $e");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid QR code")));
        }
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
      geoLocationController.text = "${position.latitude}, ${position.longitude}";
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
    isFetching = true;
    setState(() {});
    // Get the component ID from the text field
    final componentId = componentIDController.text;
    final componentType = selectedComponentType.name;
    debugPrint('Component ID: $componentId');
    debugPrint('Component Type: $componentType');
    final url = Uri.parse(
        'https://asugs-flask-backend.onrender.com/get_data/$componentId?component_type=${componentType.replaceRange(0, 1, componentType[0].toUpperCase())}'); // Replace component_type with the actual component type, capitalize the first letter to match the API endpoint

    debugPrint('URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data fetched successfully: $data');
        // Update the transformerFormModel if selected component type is a transformer
        if (selectedComponentType == ComponentType.transformer) {
          transformerFormModel = TransformerFormModel.fromMap(data);
          debugPrint('Transformer Model: $transformerFormModel');
        }
        // Populate the text fields with fetched data
        setState(() {
          selectedComponentType = ComponentType.values.firstWhere(
            (e) => e.name == data['component_type'],
            orElse: () => ComponentType.transformer,
          );
          electricalSpecController.text = data['electrical_specifications'] ?? '';
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
    } finally {
      isFetching = false;
      setState(() {});
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as Map<String, String?>?;
    var componentIDs = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10'];
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
                    "Choose your Component",
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  // Component ID field
                  // Input(
                  //   controller: componentIDController,
                  //   hintText: 'Component ID',
                  //   enabled: true,
                  // ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        backgroundColor: Colors.white,
                        builder: (context) => Container(
                            color: Colors.white,
                            height: 250,
                            child: Column(
                              children: [
                                Expanded(
                                  child: WheelChooser(
                                    unSelectTextStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    onValueChanged: (s) {
                                      componentIDController.text = s;
                                    },
                                    startPosition: ComponentType.values.length ~/ 2,
                                    datas: componentIDs.map((id) {
                                      return id;
                                    }).toList(),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {});
                                  }, // Disable the button while fetching
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                                    backgroundColor: kSecondaryColor,
                                    minimumSize: Size(MediaQuery.sizeOf(context).width, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Coninue',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                )
                              ],
                            )),
                      );
                    },
                    child: Input(
                      controller: componentIDController,
                      hintText: 'Component Id',
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Component Type field
                  // _buildDropdownField(),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        backgroundColor: Colors.white,
                        builder: (context) => Container(
                            color: Colors.white,
                            height: 250,
                            child: Column(
                              children: [
                                Expanded(
                                  child: WheelChooser(
                                    unSelectTextStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    onValueChanged: (s) {
                                      selectedComponentType = ComponentType.values.firstWhere(
                                        (e) => e.name == s,
                                        orElse: () => ComponentType.transformer,
                                      );
                                      componentTypeController.text = s;
                                    },
                                    startPosition: ComponentType.values.length ~/ 2,
                                    datas: ComponentType.values.map((ComponentType type) {
                                      return type.name;
                                    }).toList(),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    componentTypeController.text = selectedComponentType.name;
                                    Navigator.pop(context);
                                    setState(() {});
                                  }, // Disable the button while fetching
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                                    backgroundColor: kSecondaryColor,
                                    minimumSize: Size(MediaQuery.sizeOf(context).width, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Coninue',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                )
                              ],
                            )),
                      );
                    },
                    child: Input(
                      controller: componentTypeController,
                      hintText: 'Component Type',
                      enabled: false,
                    ),
                  ),
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

                  //get data button
                  _buildFetchButton(),

                  const SizedBox(height: 30),

                  // component input types
                  _componentInputWidget(),

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

  Widget _componentInputWidget() {
    switch (selectedComponentType) {
      case ComponentType.transformer:
        return TransformersForm(
          transformerFormModel: transformerFormModel,
        );
      case ComponentType.capacitorBank:
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
          borderSide: BorderSide(color: Colors.grey, width: 1.0), // Customize enabled border
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
          firstDate: DateTime(2000), // Date picker starts from the year 2000
          lastDate: DateTime(2100), // Date picker ends in the year 2100
        );

        if (pickedDate != null) {
          // Format the selected date as MM-DD-YYYY
          String formattedDate = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
          setState(() {
            installationDateController.text = formattedDate; // Set the selected date in the controller
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
      onPressed: isFetching ? null : sendData, // Disable the button while fetching
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        backgroundColor: kSecondaryColor,
        minimumSize: Size(MediaQuery.sizeOf(context).width, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Search Data', // change the text to "Search Data"
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFetchButton() {
    return ElevatedButton(
      onPressed: isFetching ? null : fetchDataByComponentId, // Disable the button while fetching
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        backgroundColor: kSecondaryColor,
        minimumSize: Size(MediaQuery.sizeOf(context).width, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isFetching // Show loading indicator while fetching
          ? Row(children: [CircularProgressIndicator(
        color: Colors.white,
      ), Text("Scouting... ")],)
          : const Text(
              'Get Data',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
    );
  }
}
