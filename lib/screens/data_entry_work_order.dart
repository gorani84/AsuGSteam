import 'package:asugs/components/ui/input.dart';
import 'package:asugs/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:wheel_chooser/wheel_chooser.dart';

class WorkOrderDataEntryPage extends StatefulWidget {
  const WorkOrderDataEntryPage({super.key});

  @override
  State<WorkOrderDataEntryPage> createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<WorkOrderDataEntryPage> {
  // Text editing controllers
  final workOrderIdController = TextEditingController();
  final circuitNameController = TextEditingController();
  final schematicComponentIdController = TextEditingController();

  bool isFetching = false;

  @override
  void initState() {
    super.initState();

    workOrderIdController.text = '1';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
      if (args != null && args['qr'] != null) {
        try {
          // TODO: handle qr code here
          setState(() {});
        } catch (e) {
          debugPrint("Error: $e");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid QR code")));
        }
      }
    });
  }

  // Send data method
  void sendData() async {}

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    var workOrderIds = [
      '1',
      '2',
      '3',
      '4',
      '5',
    ];
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
                    "Choose your work order",
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  // Work Order ID field
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
                                      workOrderIdController.text = s;
                                      setState(() {});
                                    },
                                    datas: workOrderIds.map((id) {
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
                      controller: workOrderIdController,
                      hintText: 'Work Order Id',
                      enabled: false,
                    ),
                  ),

                  const SizedBox(height: 30),
                  // Circuit name field
                  GestureDetector(
                    onTap: () {},
                    child: Input(
                      controller: circuitNameController,
                      hintText: 'Circuit Name',
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // schematic component id field
                  Input(
                    controller: schematicComponentIdController,
                    hintText: 'Schematic Component Id',
                    enabled: false,
                  ),
                  const SizedBox(height: 30),

                  //get data button
                  _buildFetchButton(),

                  const SizedBox(height: 30),

                  // Send data button
                  // _buildSendButton(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
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
        'Replace Circuit', // change the text to "Search Data"
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFetchButton() {
    return ElevatedButton(
      onPressed: () {}, // Disable the button while fetching
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        backgroundColor: kSecondaryColor,
        minimumSize: Size(MediaQuery.sizeOf(context).width, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isFetching // Show loading indicator while fetching
          ? Row(
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                Text("Scouting... ")
              ],
            )
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
