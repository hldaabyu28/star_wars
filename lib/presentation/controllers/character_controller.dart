import 'package:get/get.dart';
import '../../data/services/swapi_service.dart';
import '../../domain/models/character.dart';


class StarWarsController extends GetxController {
  late final StarWarsApiService _apiService;
  
  // Observable variables
  var characters = <CharacterModel>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = StarWarsApiService();
    fetchCharacters();
  }

  @override
  void onClose() {
    _apiService.dispose();
    super.onClose();
  }

  Future<void> fetchCharacters() async {
    try {
      _setLoading(true);
      _clearError();
      
      final fetchedCharacters = await _apiService.fetchAllCharacters();
      
      characters.value = fetchedCharacters;
      _setLoading(false);
      
    } catch (e) {
      _setError('Error: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Method untuk refresh data
  Future<void> refreshCharacters() async {
    await fetchCharacters();
  }

  // Method untuk convert height ke format yang tepat
  String getFormattedHeight(String height) {
    if (height == 'unknown') return 'Unknown';
    
    // Coba parse sebagai angka
    try {
      final heightNum = int.parse(height);
      return '$heightNum cm';
    } catch (e) {
      return height;
    }
  }

  // Helper methods untuk state management
  void _setLoading(bool loading) {
    isLoading.value = loading;
  }

  void _setError(String error) {
    hasError.value = true;
    errorMessage.value = error;
  }

  void _clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  // Getter untuk total characters count
  int get totalCharacters => characters.length;

  // Method untuk search characters (bonus feature)
  List<CharacterModel> searchCharacters(String query) {
    if (query.isEmpty) return characters;
    
    return characters.where((character) =>
        character.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}