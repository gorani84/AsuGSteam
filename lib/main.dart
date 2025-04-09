<<<<<<< HEAD
import 'package:gridscout/app.dart';
import 'package:gridscout/firebase_options.dart';
=======
import 'package:asugs/app.dart';
import 'package:asugs/firebase_options.dart';
>>>>>>> 2eb82753615ad9020e69eb297e85e87fbb301350
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}
