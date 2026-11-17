import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static final PaymentService instance = PaymentService._internal();
  PaymentService._internal();

  /// Launches official UPI deep-link intent safely to any installed payment app (GPay, PhonePe, Paytm, BHIM)
  Future<bool> initiateUpiPayment({
    required String payeeVpa,
    required String payeeName,
    required double amount,
    required String transactionNote,
    String? transactionRefId,
  }) async {
    final trId = transactionRefId ?? 'KM${DateTime.now().millisecondsSinceEpoch}';
    final cleanNote = transactionNote.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), ' ').trim();

    // Standard NPCI UPI URI Specification
    final upiUriString = 'upi://pay?'
        'pa=${Uri.encodeComponent(payeeVpa)}'
        '&pn=${Uri.encodeComponent(payeeName)}'
        '&mc=5499'
        '&tid=$trId'
        '&tr=$trId'
        '&tn=${Uri.encodeComponent(cleanNote)}'
        '&am=${amount.toStringAsFixed(2)}'
        '&cu=INR';

    final uri = Uri.parse(upiUriString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try opening with generic intent
        return await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
    } catch (e) {
      if (kDebugMode) print('Secure UPI Payment launch error: $e');
      return false;
    }
  }
}
