
import 'package:braintumourdetect/auth/login_or_register.dart';
import 'package:braintumourdetect/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          //user is logged in
          if(snapshot.hasData){
            return const Home();
          }
          //user is not logged in
          else{
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
