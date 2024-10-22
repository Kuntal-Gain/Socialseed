import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("No Internet")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.signal_wifi_off, size: 80),
            SizedBox(height: 20),
            Text(
              "No Internet Connection",
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
