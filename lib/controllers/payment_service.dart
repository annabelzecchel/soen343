import '../models/payment_strategy.dart';

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
    
    return await _currentStrategy!.processPayment(_paymentDetails);
  }

  void updatePaymentDetails(Map<String, dynamic> details) {
    _paymentDetails.addAll(details);
  }
}