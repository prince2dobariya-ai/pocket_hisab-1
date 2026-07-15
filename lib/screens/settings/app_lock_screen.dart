import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/constants/app_theme.dart';

class AppLockScreen extends StatefulWidget {
  final Widget child;
  const AppLockScreen({super.key, required this.child});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to open Khissu',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      setState(() {
        _isAuthenticated = didAuthenticate;
        _hasError = !didAuthenticate;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, size: 80, color: context.themePrimary),
            const SizedBox(height: 16),
            const Text(
              'Khissu is locked',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (_hasError)
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Try Again'),
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}