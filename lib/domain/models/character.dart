class CharacterModel {
  final String name;
  final int height;

  CharacterModel({
    required this.name,
    required this.height,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      name: json['name'] as String,
      height: int.tryParse(json['height'].toString()) ?? 0, // fix crash
    );
  }
}
