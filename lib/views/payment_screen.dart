// payment_screen.dart
import 'package:flutter/material.dart';
import '../models/credit_card_strategy.dart';
import '../models/debit_card_strategy.dart';
import '../models/paypal_strategy.dart';
import '../controllers/payment_service.dart';
import '../models/payment_strategy.dart';
import '../models/event_model.dart';

class PaymentDialog extends StatefulWidget {
  final Event event;
  final String role;
  final double amount;

  const PaymentDialog({
    required this.event,
    required this.role,
    required this.amount,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
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
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Payment method dropdown
              DropdownButton<PaymentStrategy>(
                value: _selectedStrategy,
                hint: const Text('Select Payment Method'),
                isExpanded: true,
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

              if (_currentForm != null) _currentForm!,

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 16),

              if (_selectedStrategy != null) ...[
                if (widget.event.discount > 0) ...[
                  Text('Original Price: \$${widget.amount}', style: const TextStyle(fontSize: 14)),
                  if (widget.role != 'Stakeholders')
                    Text('Discount: -\$${widget.event.discount}', style: const TextStyle(fontSize: 14, color: Colors.green)),
                ],
                const SizedBox(height: 8),
                Text(
                  'Total: \$${(widget.amount - widget.event.discount).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Pay Now'),
                ),
              ],
              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              )
            ],
          ),
        ),
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
      final validationError = null;
      if (validationError != null) {
        throw Exception('Validation Error: $validationError');
      }

      final success = await _paymentService.processCurrentPayment();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );
          Navigator.of(context).pop(true);
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