import 'package:flutter_test/flutter_test.dart';
import 'package:kisanmitra_app/data/services/api_service.dart';

void main() {
  group('AI Advisory Chatbot Dynamic Intelligence Tests', () {
    final apiService = ApiService();

    test('Query 1: whats is price of onion hi dhule market', () async {
      final response = await apiService.sendChatMessage('whats is price of onion hi dhule market', 'en');
      expect(response.toLowerCase().contains('dhule'), isTrue);
      expect(response.toLowerCase().contains('onion'), isTrue);
      expect(response.contains('1,780'), isTrue);
    });

    test('Query 2: what is price of maize in Malegaon', () async {
      final response = await apiService.sendChatMessage('what is price of maize in Malegaon', 'en');
      expect(response.toLowerCase().contains('malegaon'), isTrue);
      expect(response.toLowerCase().contains('maize'), isTrue);
      expect(response.contains('2,180'), isTrue);
    });

    test('Query 3: fertilizer schedule for maize', () async {
      final response = await apiService.sendChatMessage('fertilizer schedule for maize', 'en');
      expect(response.toLowerCase().contains('maize'), isTrue);
      expect(response.toLowerCase().contains('dap'), isTrue);
      expect(response.toLowerCase().contains('urea'), isTrue);
    });
  });
}
