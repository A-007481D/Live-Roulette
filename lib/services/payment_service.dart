import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firebase_service.dart';

class PaymentService extends ChangeNotifier {
  bool _isProcessing = false;
  
  bool get isProcessing => _isProcessing;

  Future<String?> processPayment({
    required double amount,
    required String currency,
    required String description,
    required String userId,
    String? dareId,
  }) async {
    try {
      _isProcessing = true;
      notifyListeners();

      // Create payment intent on your backend
      final paymentIntent = await _createPaymentIntent(
        amount: (amount * 100).round(), // Convert to cents
        currency: currency,
        description: description,
      );

      if (paymentIntent == null) {
        return 'Failed to create payment intent';
      }

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Chaos Dare',
          style: ThemeMode.dark,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Record payment in Firebase
      await FirebaseService.recordPayment({
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'description': description,
        'dareId': dareId,
        'platformCut': _calculatePlatformCut(amount, description),
        'paymentIntentId': paymentIntent['id'],
        'status': 'completed',
      });

      return null;
    } catch (e) {
      if (e is StripeException) {
        return e.error.localizedMessage;
      }
      return 'Payment failed: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent({
    required int amount,
    required String currency,
    required String description,
  }) async {
    try {
      // This should be your backend endpoint
      final response = await http.post(
        Uri.parse('https://your-backend.com/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'currency': currency,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
    }
    return null;
  }

  double _calculatePlatformCut(double amount, String description) {
    if (description.contains('tip') || description.contains('escalation')) {
      return amount * 0.5; // 50% cut on tips
    } else {
      return amount * 0.2; // 20% cut on dare submissions
    }
  }

  Future<String?> processDareSubmission({
    required double submissionFee,
    required String userId,
    required String dareId,
  }) async {
    return await processPayment(
      amount: submissionFee,
      currency: 'usd',
      description: 'Dare submission fee',
      userId: userId,
      dareId: dareId,
    );
  }

  Future<String?> processTip({
    required double tipAmount,
    required String userId,
    required String dareId,
  }) async {
    return await processPayment(
      amount: tipAmount,
      currency: 'usd',
      description: 'Dare tip/escalation',
      userId: userId,
      dareId: dareId,
    );
  }
}