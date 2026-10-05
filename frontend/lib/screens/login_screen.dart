import 'package:flutter/material.dart';
import 'package:ac_status_list/constants/building_mapping.dart';
import 'package:ac_status_list/screens/register_screen.dart';
import 'package:ac_status_list/screens/setting_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

double _volume = 0.0;

// Clear the navigation history and go back to the login screen
void logout(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
    (route) => false,
  );
}

class LoginScreen extends StatelessWidget {
  final userController = TextEditingController(text: "admin@example.com");
  final passController = TextEditingController(text: "1234");

  LoginScreen({super.key});

  void login(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://localhost:8001/login'),
      headers: {'Content-Type': 'application/json'},

      body: json.encode({
        'user': userController.text,
        'password': passController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // final userPrefix = userController.text.split('@')[0];
      // final buildings = data['bid'] ?? 'defaultBid';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsScreen(
            userId: userController.text,
            password: passController.text,
            buildings: buildingMapping.keys.toList()
            
        ),)
      );
      print("📥 Status code: ${response.statusCode}");
      print("📥 Response body: ${response.body}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Login Failed')),
      );
    }
  }

  void register(BuildContext context) {
    // TODO: Add navigation to Register screen or implement registration logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 Register functionality coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Login")),
        // body: const Center(child: ObscuredTextFieldSample())
        // appBar: AppBar(
        //   title: Row(
        //     children: <Widget>[
        //       Icon(
        //         key: UniqueKey(),
        //         Icons.lock,
        //         color: Colors.amber,
        //         size: 24,
        //         semanticLabel: "Login",
        //       ),
        //       // คุณสามารถเพิ่ม Widget อื่นๆ ใน Row ได้ที่นี่
        //     ],
        //   ),
        // ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => login(context),
                label: const Text("Login"),
                icon: Icon(Icons.lock),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text("No account? Register"),
              ),
            ]
          ),
        ),
      );
  }
}