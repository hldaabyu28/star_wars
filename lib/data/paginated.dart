import 'package:star_wars/domain/models/character.dart';

class PaginatedResponse {
  final List<CharacterModel> results;
  final String? next;

  PaginatedResponse({
    required this.results,
    this.next,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse(
      results: (json['results'] as List)
          .map((e) => CharacterModel.fromJson(e))
          .toList(),
      next: json['next'],
    );
  }
}
