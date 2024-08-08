import 'package:enterkomputer/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  /// Initiates login controller.
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            controller.login();
            // Get.to(() => HomePage());
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}
