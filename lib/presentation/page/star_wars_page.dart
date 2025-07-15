import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_wars/presentation/controllers/character_controller.dart';
import 'package:star_wars/presentation/widgets/character_card.dart';

class StarWarsCharactersScreen extends StatelessWidget {
  final StarWarsController controller = Get.put(StarWarsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Star Wars Characters',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.refreshCharacters(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingWidget();
        }

        if (controller.hasError.value) {
          return _buildErrorWidget();
        }

        if (controller.characters.isEmpty) {
          return _buildEmptyWidget();
        }

        return _buildCharactersList();
      }),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
          SizedBox(height: 16),
          Text(
            'Loading characters...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load characters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.refreshCharacters(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No characters found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharactersList() {
    return Column(
      children: [
        // Header dengan total count
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Characters: ${controller.totalCharacters}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Icon(
                Icons.group,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        
        // Characters List
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshCharacters,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: controller.characters.length,
              itemBuilder: (context, index) {
                final character = controller.characters[index];
                return CharacterCard(
                  character: character,
                  controller: controller,
                  index: index,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}