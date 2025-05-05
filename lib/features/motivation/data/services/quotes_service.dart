import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quote_model.dart';

class QuotesService {
  // URL du contenu brut (raw) sur GitHub
  static const String _url =
      'https://raw.githubusercontent.com/kimku003/quotes/main/quotes.json';

  Future<QuotesResponse> fetchQuotes() async {
    try {
      print('Fetching quotes from: $_url'); // Debug log

      final response = await http.get(Uri.parse(_url));
      print('Response status code: ${response.statusCode}'); // Debug log

      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // Debug log
        final decodedData = json.decode(response.body);
        print('Decoded data: $decodedData'); // Debug log

        return QuotesResponse.fromJson(decodedData);
      } else if (response.statusCode == 404) {
        throw Exception(
            'URL not found (404). Please check the repository URL and file path');
      } else {
        throw Exception(
            'Failed to load quotes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error details: $e'); // Debug log
      throw Exception('Error fetching quotes: $e');
    }
  }
}
