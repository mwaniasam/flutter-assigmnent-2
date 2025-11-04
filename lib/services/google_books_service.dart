import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  static Future<List<BookSearchResult>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=${Uri.encodeComponent(query)}&maxResults=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) return [];

        return items.map((item) {
          final volumeInfo = item['volumeInfo'] as Map<String, dynamic>;
          final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
          final industryIdentifiers = volumeInfo['industryIdentifiers'] as List<dynamic>?;

          String? isbn;
          if (industryIdentifiers != null) {
            for (var identifier in industryIdentifiers) {
              if (identifier['type'] == 'ISBN_13' || identifier['type'] == 'ISBN_10') {
                isbn = identifier['identifier'];
                break;
              }
            }
          }

          return BookSearchResult(
            title: volumeInfo['title'] ?? 'Unknown Title',
            authors: (volumeInfo['authors'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                ['Unknown Author'],
            imageUrl: imageLinks?['thumbnail']?.toString().replaceAll('http:', 'https:'),
            publisher: volumeInfo['publisher']?.toString(),
            publishedDate: volumeInfo['publishedDate']?.toString(),
            description: volumeInfo['description']?.toString(),
            isbn: isbn,
            pageCount: volumeInfo['pageCount']?.toString(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

class BookSearchResult {
  final String title;
  final List<String> authors;
  final String? imageUrl;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? isbn;
  final String? pageCount;

  BookSearchResult({
    required this.title,
    required this.authors,
    this.imageUrl,
    this.publisher,
    this.publishedDate,
    this.description,
    this.isbn,
    this.pageCount,
  });

  String get authorNames => authors.join(', ');
}
