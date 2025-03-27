abstract class PaymentStrategy {
  String get name;
  String get icon;
  String validateInput(Map<String, dynamic> paymentDetails);
  Future<bool> processPayment(Map<String, dynamic> paymentDetails);
}