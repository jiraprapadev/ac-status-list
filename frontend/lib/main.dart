import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
    // theme: ThemeData(
    //   useMaterial3: true,
    //   iconTheme: IconThemeData(color: Colors.deepOrange),
    //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    //   ),
    // theme: ThemeData(
    //   brightness: Brightness.light,
    //   primarySwatch: Colors.indigo,
    //   scaffoldBackgroundColor: Colors.grey[100],
    //   textTheme: const TextTheme(
    //     bodyMedium: TextStyle(fontSize: 16),
    //   ),
    //   appBarTheme: const AppBarTheme(
    //     backgroundColor: Colors.indigo,
    //     foregroundColor: Colors.white,
    //     elevation: 4,
    //   ),
    // ),
    theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00897B)),
    iconTheme: IconThemeData(
      color: Colors.black,
      size: 30,
      ),
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00897B),
      brightness: Brightness.dark)
    ),
    themeMode: ThemeMode.system,
    routes: {
      '/dashboard': (context) => Scaffold(body: Center(child: Text("Dashboard Here"))),
    },
  ));
}
