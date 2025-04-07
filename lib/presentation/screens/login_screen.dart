import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../utility/show_alert.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  // Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  // Function to authenticate with fingerprint/pattern and show Snackbar
  Future<void> _authenticate(BuildContext context) async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint or use device authentication',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        ShowAlert.showSnackBar(context, "Authorized successfully", Colors.teal);
        // Navigate to home screen or other functionality on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CardListScreen()),
        );
      } else {
        ShowAlert.showSnackBar(context, "Authorization failed", Colors.red);
      }
    } catch (e) {
      ShowAlert.showSnackBar(context, "Error: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center the content in the screen
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _authenticate(context),
                child: Column(
                  children: [
                    Icon(Icons.fingerprint, size: 100, color: Colors.blue),
                    SizedBox(height: 10),
                    // Text(
                    //   "Tap to authenticate",
                    //   style: TextStyle(fontSize: 16, color: Colors.blue),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _canCheckBiometrics
                  ? ElevatedButton(
                      onPressed: () => _authenticate(context),
                      child: Text("Tap to Authenticate with Fingerprint"),
                    )
                  : Text(
                      "Fingerprint/Biometric authentication not available",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
