import 'package:cafe_144/page/login.dart';
import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 245, 218),
            background: const Color.fromARGB(255, 250, 227, 162)),
        useMaterial3: true,
      ),
      home: FlutterSplashScreen.scale(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 255, 209, 93),
            Color.fromARGB(255, 255, 255, 255),
          ],
        ),
        childWidget: SizedBox(
          height: 150,
          child: Image.asset("assets/images/logo.png"),
        ),
        duration: const Duration(milliseconds: 1500),
        animationDuration: const Duration(milliseconds: 1000),
        onAnimationEnd: () => debugPrint("On Scale End"),
        nextScreen: const LoginScreen(),
      ),
    );
  }
}
