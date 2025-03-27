import '../models/payment_strategy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  PaymentStrategy? _currentStrategy;
  Map<String, dynamic> _paymentDetails = {};

  void setStrategy(PaymentStrategy strategy) {
    _currentStrategy = strategy;
    _paymentDetails = {};
  }

  String? validateCurrentInput() {
    if (_currentStrategy == null) {
      return 'No payment method selected';
    }
    return _currentStrategy!.validateInput(_paymentDetails);
  }

  Future<bool> processCurrentPayment() async {
    if (_currentStrategy == null) {
      throw Exception('No payment strategy selected');
    }
    
    final validationError = validateCurrentInput();
    if (validationError != null && validationError.isNotEmpty) {
      throw Exception(validationError);
    }
    
    final paymentSuccess = await _currentStrategy!.processPayment(_paymentDetails);
    if (paymentSuccess) {
      // Save payment details to Firebase
      try {
        final paymentCollection = FirebaseFirestore.instance.collection('payments');
        await paymentCollection.add({
          'paymentDetails': _paymentDetails,
          'timestamp': FieldValue.serverTimestamp(),
          'paymentType': _currentStrategy!.name,
        });
      } catch (e) {
        throw Exception('Failed to save payment information: $e');
      }
    }
    
    return paymentSuccess;
  }

  void updatePaymentDetails(Map<String, dynamic> details) {
    _paymentDetails.addAll(details);
  }
}