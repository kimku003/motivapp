import 'dart:convert';
//import 'package:shared_preferences';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/quote_model.dart';
// #docregion migrate
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
// #enddocregion migrate

class QuotesCacheService {
  static const String _cacheKey = 'cached_quotes';
  static const String _lastUpdateKey = 'last_update_timestamp';

  final SharedPreferences _prefs;

  QuotesCacheService(this._prefs);

  Future<void> cacheQuotes(QuotesResponse quotes) async {
    final String quotesJson = json.encode({
      'last_updated': quotes.lastUpdated,
      'quotes': quotes.quotes
          .map((q) => {
                'id': q.id,
                'translations': q.translations,
                'from': q.from,
                'tags': q.tags,
                'category': q.category,
              })
          .toList(),
    });

    await _prefs.setString(_cacheKey, quotesJson);
    await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  Future<QuotesResponse?> getCachedQuotes() async {
    final String? cachedData = _prefs.getString(_cacheKey);
    if (cachedData == null) return null;

    try {
      final Map<String, dynamic> jsonData = json.decode(cachedData);
      return QuotesResponse.fromJson(jsonData);
    } catch (e) {
      print('Error reading cached quotes: $e');
      return null;
    }
  }

  bool shouldUpdate() {
    final String? lastUpdate = _prefs.getString(_lastUpdateKey);
    if (lastUpdate == null) return true;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    final difference = DateTime.now().difference(lastUpdateTime);

    // Mettre à jour si la dernière synchronisation date de plus de 24h
    return difference.inHours > 24;
  }
}
