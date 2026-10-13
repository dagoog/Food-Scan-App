import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/avoid_list_item.dart';
import '../utils/constants.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  String _selectedSection = 'Allergens';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToAvoidList(String ingredientName) {
    final provider = context.read<AppProvider>();

    // Check if already in avoid list
    if (provider.avoidList.any(
      (item) => item.ingredientName.toLowerCase() == ingredientName.toLowerCase(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$ingredientName is already in your avoid list'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check premium limit
    if (!provider.isPremium && provider.avoidListCount >= AppConstants.freeAvoidListLimit) {
      _showUpgradeDialog();
      return;
    }

    final item = AvoidListItem(
      id: const Uuid().v4(),
      ingredientName: ingredientName,
      category: _selectedSection == 'Allergens' ? 'Allergen' : 'Additive',
      usageCount: 0,
    );

    provider.addToAvoidList(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$ingredientName" to avoid list'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You\'ve reached the free limit of 10 avoid list items.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Upgrade to Premium for unlimited items, family profiles, and more!',
            ),
            const SizedBox(height: 8),
            Text(
              '\$${AppConstants.premiumPrice}/month',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Library'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Allergens section
          _buildSection(
            context,
            title: 'Common Allergens',
            icon: Icons.warning_amber,
            color: Colors.red,
            items: AppConstants.commonAllergens,
          ),

          // Additives section (placeholder)
          _buildSection(
            context,
            title: 'Common Additives',
            icon: Icons.tag,
            color: Colors.orange,
            items: [
              'Food coloring',
              'Preservatives',
              'Artificial sweeteners',
              'Emulsifiers',
              'Thickeners',
            ],
          ),

          // Popular ingredients (placeholder)
          _buildSection(
            context,
            title: 'Popular Ingredients',
            icon: Icons.star,
            color: Colors.blue,
            items: [
              'High fructose corn syrup',
              'Artificial flavors',
              'MSG',
              'Sodium nitrite',
              'Trans fats',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return _buildIngredientChip(items[index], color);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientChip(String name, Color color) {
    return InkWell(
      onTap: () => _addToAvoidList(name),
      borderRadius: BorderRadius.circular(12),
      child: Chip(
        avatar: Icon(Icons.info_outline, size: 16, color: color),
        label: Text(
          name,
          style: const TextStyle(fontSize: 12),
        ),
        deleteIcon: const Icon(Icons.add, size: 16),
        onDeleted: () => _addToAvoidList(name),
      ),
    );
  }
}
