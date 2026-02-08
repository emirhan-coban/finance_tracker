import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://api.genelpara.com/json';

  Future<Map<String, double>> fetchRates() async {
    try {
      final url = Uri.parse('$_baseUrl/?list=doviz&sembol=USD,EUR');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'] ?? {};

        // The API returns a Map where keys are currency codes (USD, EUR)
        // and values are objects containing 'satis' (selling price) as string.
        final double usdRate =
            double.tryParse(data['USD']?['satis']?.toString() ?? '0') ?? 0.0;
        final double eurRate =
            double.tryParse(data['EUR']?['satis']?.toString() ?? '0') ?? 0.0;

        return {'USD': usdRate, 'EUR': eurRate};
      } else {
        throw Exception('Failed to load currency rates');
      }
    } catch (e) {
      throw Exception('Error fetching currency rates: $e');
    }
  }
}
