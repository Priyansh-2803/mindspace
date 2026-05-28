import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindspace/screens/authenticate/authenticate.dart';
import 'package:mindspace/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);
    print(user);

    if (user == null){
      return Authenticate();
    } else{
      return Home();
    }


  }
}
