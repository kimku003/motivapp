import 'dart:convert';

class Quote {
  final String id;
  final Map<String, String> translations;
  final Map<String, String> from;
  final String category;
  final List<String> tags;

  Quote({
    required this.id,
    required this.translations,
    required this.from,
    required this.category,
    required this.tags,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    try {
      return Quote(
        id: json['id'] as String,
        translations: Map<String, String>.from(json['translations'] as Map),
        from: Map<String, String>.from(json['from'] as Map),
        category: json['category'] as String,
        tags: List<String>.from(json['tags'] as List),
      );
    } catch (e) {
      print('Error parsing Quote: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'translations': translations,
        'from': from,
        'category': category,
        'tags': tags,
      };
}

class QuotesResponse {
  final String lastUpdated;
  final List<Quote> quotes;

  QuotesResponse({
    required this.lastUpdated,
    required this.quotes,
  });

  factory QuotesResponse.fromJson(Map<String, dynamic> json) {
    return QuotesResponse(
      lastUpdated: json['last_updated'],
      quotes: (json['quotes'] as List)
          .map((quote) => Quote.fromJson(quote))
          .toList(),
    );
  }
}
