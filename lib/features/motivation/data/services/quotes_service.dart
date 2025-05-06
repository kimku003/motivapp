import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quote_model.dart';
import '../services/quotes_cache_service.dart';

class QuotesService {
  static const String _url =
      'https://raw.githubusercontent.com/kimku003/quotes/main/quotes.json';

  final QuotesCacheService _cacheService;

  QuotesService(this._cacheService);

  Future<QuotesResponse> fetchQuotes() async {
    try {
      // Vérifier si une mise à jour est nécessaire
      if (!_cacheService.shouldUpdate()) {
        final cachedQuotes = await _cacheService.getCachedQuotes();
        if (cachedQuotes != null) {
          print('Using cached quotes');
          return cachedQuotes;
        }
      }

      // Essayer de récupérer les nouvelles citations
      print('Fetching fresh quotes from: $_url');
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final quotesResponse = QuotesResponse.fromJson(decodedData);

        // Mettre en cache les nouvelles citations
        await _cacheService.cacheQuotes(quotesResponse);
        return quotesResponse;
      } else {
        // En cas d'erreur, essayer d'utiliser le cache
        final cachedQuotes = await _cacheService.getCachedQuotes();
        if (cachedQuotes != null) {
          print('Using cached quotes after failed network request');
          return cachedQuotes;
        }
        throw Exception('Failed to load quotes: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur réseau, utiliser le cache
      final cachedQuotes = await _cacheService.getCachedQuotes();
      if (cachedQuotes != null) {
        print('Using cached quotes due to error: $e');
        return cachedQuotes;
      }
      throw Exception('Error fetching quotes: $e');
    }
  }
}
