import 'payment_strategy.dart';
import 'package:flutter/material.dart';

class PayPalStrategy implements PaymentStrategy {
  @override
  String get name => "PayPal";
  
  @override
  String get icon => "🔵";

  @override
  String validateInput(Map<String, dynamic> paymentDetails) {
    if (paymentDetails['email']?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(paymentDetails['email'] ?? '')) {
      return 'Invalid email format';
    }
    if (paymentDetails['password']?.isEmpty ?? true) {
      return 'Password is required';
    }
    return '';
  }

  @override
  Future<bool> processPayment(Map<String, dynamic> paymentDetails) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Widget buildInputForm(ValueChanged<Map<String, dynamic>> onChanged) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'PayPal Email'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => onChanged({'email': value}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          onChanged: (value) => onChanged({'password': value}),
        ),
      ],
    );
  }
}