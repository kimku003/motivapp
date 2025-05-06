import 'dart:convert';

class Quote {
  final String id;
  final Map<String, String> translations;
  final String from;
  final List<String> tags;
  final String category;

  Quote({
    required this.id,
    required this.translations,
    required this.from,
    required this.tags,
    required this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      translations: Map<String, String>.from(json['translations']),
      from: json['from'],
      tags: List<String>.from(json['tags']),
      category: json['category'],
    );
  }
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
