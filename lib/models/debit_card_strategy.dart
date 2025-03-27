import 'payment_strategy.dart';
import 'package:flutter/material.dart';

class DebitCardStrategy implements PaymentStrategy {
  @override
  String get name => "Debit Card";
  
  @override
  String get icon => "🏦";

  @override
  String validateInput(Map<String, dynamic> paymentDetails) {
    if (paymentDetails['cardNumber']?.isEmpty ?? true) {
      return 'Card number is required';
    }
    if (paymentDetails['cardNumber']?.length != 16) {
      return 'Card number must be 16 digits';
    }
    if (paymentDetails['expiryDate']?.isEmpty ?? true) {
      return 'Expiry date is required';
    }
    if (paymentDetails['cvv']?.isEmpty ?? true) {
      return 'CVV is required';
    }
    if (paymentDetails['cvv']?.length != 3) {
      return 'CVV must be 3 digits';
    }
    if (paymentDetails['cardHolder']?.isEmpty ?? true) {
      return 'Card holder name is required';
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
          decoration: const InputDecoration(labelText: 'Card Number'),
          keyboardType: TextInputType.number,
          onChanged: (value) => onChanged({'cardNumber': value}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
          onChanged: (value) => onChanged({'expiryDate': value}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'CVV'),
          keyboardType: TextInputType.number,
          obscureText: true,
          onChanged: (value) => onChanged({'cvv': value}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Card Holder Name'),
          onChanged: (value) => onChanged({'cardHolder': value}),
        ),
      ],
    );
  }
}