import 'package:flutter/material.dart';
import 'SecPage.dart';
//import 'package:splashscreen/splashscreen.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

class MySplashPage extends StatefulWidget {
  const MySplashPage({Key? key}) : super(key: key);

  @override
  MySplashState createState() => MySplashState();
}

class MySplashState extends State<MySplashPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 2500,
      splash: "assets/phone.png",
      nextScreen: const SecPage(),
      splashTransition: SplashTransition.slideTransition,
    );
  }
}