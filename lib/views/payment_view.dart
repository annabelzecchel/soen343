import 'package:flutter/material.dart';
import 'package:soen343/components/app_theme.dart';
import 'package:flutter/foundation.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle credit card payment
              },
              child: const Text('Pay with Credit Card'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle PayPal payment
              },
              child: const Text('Pay with PayPal'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle other payment methods
              },
              child: const Text('Other Payment Methods'),
            ),
          ],
        ),
      ),
    );
  }
}