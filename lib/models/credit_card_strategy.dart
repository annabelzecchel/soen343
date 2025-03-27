import 'package:flutter/material.dart';
import 'payment_strategy.dart';

class CreditCardStrategy implements PaymentStrategy {
  @override
  String get name => "Credit Card";

  @override
  String get icon => "💳";

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
    final controller = TextEditingController();
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Card Number'),
          keyboardType: TextInputType.number,
          onChanged: (value) => onChanged({'cardNumber': value}),
          validator: (value) {
            final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
            if (value == null || value.isEmpty) {
              return 'Card number is required';
            }
            if (!emailPattern.hasMatch(value)) {
              return 'Card number must match the required pattern';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
          onChanged: (value) => onChanged({'expiryDate': value}),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Expiry date is required';
            }
            final expiryDatePattern = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
            if (!expiryDatePattern.hasMatch(value)) {
              return 'Expiry date must be in MM/YY format';
            }
            final parts = value.split('/');
            final month = int.parse(parts[0]);
            final year = int.parse('20${parts[1]}');
            final now = DateTime.now();
            final expiry = DateTime(year, month + 1, 0);
            if (expiry.isBefore(now)) {
              return 'Expiry date must be in the future';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'CVV'),
          keyboardType: TextInputType.number,
          obscureText: true,
          onChanged: (value) => onChanged({'cvv': value}),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'CVV is required';
            }
            if (value.length != 3 || int.tryParse(value) == null) {
              return 'CVV must be a 3-digit number';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Card Holder Name'),
          onChanged: (value) => onChanged({'cardHolder': value}),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Card number is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
