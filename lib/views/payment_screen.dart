// payment_screen.dart
import 'package:flutter/material.dart';
import '../models/credit_card_strategy.dart';
import '../models/debit_card_strategy.dart';
import '../models/paypal_strategy.dart';
import '../controllers/payment_service.dart';
import '../models/payment_strategy.dart';
import '../models/event_model.dart';

class PaymentScreen extends StatefulWidget {
  final Event event;
  final String attendeeEmail;
  final double amount;

    const PaymentScreen({
    required this.event,
    required this.attendeeEmail,
    required this.amount,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final List<PaymentStrategy> _strategies = [
    CreditCardStrategy(),
    DebitCardStrategy(),
    PayPalStrategy(),
  ];
  
  PaymentStrategy? _selectedStrategy;
  Widget? _currentForm;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Payment method selection
            DropdownButton<PaymentStrategy>(
              value: _selectedStrategy,
              hint: const Text('Select Payment Method'),
              items: _strategies.map((strategy) {
                return DropdownMenuItem(
                  value: strategy,
                  child: Row(
                    children: [
                      Text(strategy.icon),
                      const SizedBox(width: 10),
                      Text(strategy.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (strategy) {
                setState(() {
                  _selectedStrategy = strategy;
                  _paymentService.setStrategy(strategy!);
                  _currentForm = (strategy as dynamic).buildInputForm(
                    (details) => _paymentService.updatePaymentDetails(details),
                  );
                  _errorMessage = null;
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            // Dynamic form based on selected strategy
            if (_currentForm != null) _currentForm!,
            
            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            
            const Spacer(),
            
            // Pay button
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // final validationError = _paymentService.validateCurrentInput();
      final validationError = null;
      if (validationError != null) {
        throw Exception('Validation Error:&& $validationError');
      }

      final success = await _paymentService.processCurrentPayment();
      print('Payment success: $success');
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}