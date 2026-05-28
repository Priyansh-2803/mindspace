import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mindspace/firebase_options.dart';
import 'package:mindspace/screens/wrapper.dart';
import 'package:mindspace/services/auth.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  try {
    if(kIsWeb){
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else{
      await Firebase.initializeApp();
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ FIREBASE INITIALIZED SUCCESSFULLY");
  } catch (e) {
    print("🛑 FIREBASE INIT ERROR: $e");
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: AuthService().user,
        initialData: null,
        child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}


