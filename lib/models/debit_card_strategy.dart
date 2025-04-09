import 'payment_strategy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    var formatted = '';
    
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += text[i];
    }
    
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class DebitCardStrategy implements PaymentStrategy {
    final TextEditingController _expiryDateController = TextEditingController();

  @override
  String get name => "Debit Card";
  
  @override
  String get icon => "🏦";

  @override
  String validateInput(Map<String, dynamic> paymentDetails) {
    // Validate card number
    if (paymentDetails['cardNumber']?.isEmpty ?? true) {
      return 'Card number is required';
    }
    final cardNumber = paymentDetails['cardNumber'].replaceAll(' ', '');
    if (cardNumber.length != 16) {
      return 'Card number must be 16 digits';
    }
    if (!_isValidLuhn(cardNumber)) {
      return 'Invalid card number';
    }

    // Validate expiry date
    if (paymentDetails['expiryDate']?.isEmpty ?? true) {
      return 'Expiry date is required';
    }
    if (_isCardExpired(paymentDetails['expiryDate'])) {
      return 'Card has expired';
    }

    // Validate CVV
    if (paymentDetails['cvv']?.isEmpty ?? true) {
      return 'CVV is required';
    }
    if (paymentDetails['cvv']?.length != 3) {
      return 'CVV must be 3 digits';
    }
    if (!RegExp(r'^[0-9]{3}$').hasMatch(paymentDetails['cvv'])) {
      return 'CVV must be numeric';
    }

    // Validate card holder
    if (paymentDetails['cardHolder']?.isEmpty ?? true) {
      return 'Card holder name is required';
    }

    return '';
  }


  bool _isCardExpired(String expiryDate) {
    final parts = expiryDate.split('/');
    if (parts.length != 2) return true;

    final month = int.tryParse(parts[0]) ?? 0;
    final year = 2000 + (int.tryParse(parts[1]) ?? 0);
    final now = DateTime.now();
    
    return year < now.year || (year == now.year && month < now.month);
  }

  bool _isValidLuhn(String input) {
    final number = input.replaceAll(RegExp(r'[^0-9]'), '');
    int sum = 0;
    bool alternate = false;
    
    for (var i = number.length - 1; i >= 0; i--) {
      var digit = int.parse(number[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  @override
  Future<bool> processPayment(Map<String, dynamic> paymentDetails) async {
    if (validateInput(paymentDetails).isNotEmpty) {
      return false;
    }
    if (_isCardExpired(paymentDetails['expiryDate'])) {
      return false;
    }
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Widget buildInputForm(ValueChanged<Map<String, dynamic>> onChanged) {
    return Column(
      children: [
        // Card Number Field
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '4242 4242 4242 4242',
            prefixIcon: Icon(Icons.credit_card),
            counterText: '',
          ),
          keyboardType: TextInputType.number,
          maxLength: 19,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CardNumberInputFormatter(),
          ],
          onChanged: (value) => onChanged({'cardNumber': value}),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Card number is required';
            final cleanValue = value.replaceAll(' ', '');
            if (cleanValue.length != 16) return 'Must be 16 digits';
            if (!_isValidLuhn(cleanValue)) return 'Invalid card number';
            return null;
          },
        ),

        // Expiry Date Field
        TextFormField(
          controller: _expiryDateController,
          decoration: const InputDecoration(
            labelText: 'Expiry Date (MM/YY)',
            hintText: '12/25',
            prefixIcon: Icon(Icons.calendar_today),
          ),
          keyboardType: TextInputType.datetime,
          onChanged: (value) => onChanged({'expiryDate': value}),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
              return 'MM/YY format';
            }
            if (_isCardExpired(value)) return 'Card expired';
            return null;
          },
        ),

        // CVV Field (Fixed)
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'CVV',
            hintText: '123',
            prefixIcon: Icon(Icons.lock),
            counterText: '',
          ),
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 3,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (value.length != 3) return 'Must be 3 digits';
            if (!RegExp(r'^[0-9]{3}$').hasMatch(value)) return 'Numbers only';
            return null;
          },
          onChanged: (value) => onChanged({'cvv': value}),
        ),

        // Card Holder Field
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Card Holder Name',
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) => 
              value?.isEmpty ?? true ? 'Required' : null,
          onChanged: (value) => onChanged({'cardHolder': value}),
        ),
      ],
    );
  }
}