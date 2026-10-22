import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/scanned_product.dart';
import '../models/ingredient.dart';
import '../models/avoid_list_item.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ScannedProduct? scannedProduct;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.scannedProduct,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get _canAddToAvoidList => widget.scannedProduct != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scannedProduct = widget.scannedProduct;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        bottom: scannedProduct != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Info'),
                  Tab(text: 'Ingredients'),
                ],
              )
            : null,
      ),
      body: scannedProduct != null
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(scannedProduct),
                _buildIngredientsTab(scannedProduct),
              ],
            )
          : _buildInfoTabWithoutTabs(widget.product),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _canAddToAvoidList ? () => _addToAvoidListDialog() : null,
        icon: const Icon(Icons.add),
        label: const Text('Add Ingredient'),
      ),
    );
  }

  Widget _buildInfoTab(ScannedProduct scannedProduct) {
    final product = scannedProduct.product;

    return _buildInfoContent(product, scannedProduct);
  }

  Widget _buildInfoTabWithoutTabs(Product product) {
    return _buildInfoContent(product, null);
  }

  Widget _buildInfoContent(Product product, ScannedProduct? scannedProduct) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          if (product.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 64),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Product name
          Text(
            product.productName ?? 'Unknown Product',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          if (product.brand != null) ...[
            const SizedBox(height: 4),
            Text(
              product.brand!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Safety status card (only for scanned products)
          if (scannedProduct != null) _buildSafetyCard(scannedProduct),

          const SizedBox(height: 24),

          // Nutri-Score
          if (product.nutriscore != null) _buildNutriscoreCard(context, product),

          const SizedBox(height: 16),

          // Allergens
          if (product.hasAllergens) _buildAllergensCard(context, product),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(ScannedProduct scannedProduct) {
    final product = scannedProduct.product;
    final matchedItems = scannedProduct.matchedAvoidItems;

    if (product.ingredients == null || product.ingredients!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No ingredient data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (product.ingredientsText != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  product.ingredientsText!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary
        if (matchedItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${matchedItems.length} ingredient${matchedItems.length > 1 ? 's' : ''} on your avoid list',
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Ingredients list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: product.ingredients!.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final ingredient = product.ingredients![index];
            final isMatched = matchedItems.any((id) => id == ingredient.id ||
                ingredient.name.toLowerCase().contains(id.toLowerCase()));

            return _buildIngredientRow(ingredient, isMatched);
          },
        ),
      ],
    );
  }

  Widget _buildSafetyCard(ScannedProduct scannedProduct) {
    final status = scannedProduct.safetyStatus;

    return Card(
      color: AppTheme.getSafetyColor(status.name),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              AppTheme.getSafetyIcon(status.name),
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Safety Status',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    status.displayName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutriscoreCard(BuildContext context, Product product) {
    final score = product.nutriscore!;
    final letters = ['A', 'B', 'C', 'D', 'E'];
    final colors = [
      Color(0xFF054752),
      Color(0xFF48915F),
      Color(0xFFF2BC2D),
      Color(0xFFF58E0C),
      Color(0xFFE63E2D),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutri-Score',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                final isSelected = score == index + 1;
                return Container(
                  width: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            letters[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        letters[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergensCard(BuildContext context, Product product) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Contains Allergens',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.allergens!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(dynamic ingredient, bool isMatched) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: isMatched
          ? BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Row(
        children: [
          if (isMatched)
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ingredient is Ingredient ? ingredient.name : ingredient.toString(),
              style: TextStyle(
                fontWeight: isMatched ? FontWeight.w600 : FontWeight.normal,
                color: isMatched ? Colors.red.shade700 : null,
              ),
            ),
          ),
          if (isMatched)
            const Icon(
              Icons.info,
              size: 16,
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  void _addToAvoidListDialog() {
    final provider = context.read<AppProvider>();
    final product = widget.product;

    // Check if already at limit
    if (!provider.isPremium && provider.avoidListCount >= AppConstants.freeAvoidListLimit) {
      _showUpgradeDialog();
      return;
    }

    final ingredients = product.ingredients ?? [];
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No ingredients available to add'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Avoid List'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select an ingredient from this product to add to your avoid list:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: ingredients.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    final isSelected = provider.avoidList.any(
                      (item) => item.id == ingredient.id ||
                          item.ingredientName.toLowerCase() == ingredient.name.toLowerCase(),
                    );

                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Colors.grey : null,
                      ),
                      title: Text(ingredient.name),
                      subtitle: ingredient.description != null
                          ? Text(
                              ingredient.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(context);

                        if (isSelected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${ingredient.name} is already in your avoid list'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Add to avoid list
                        final newItem = AvoidListItem(
                          id: ingredient.id.isNotEmpty ? ingredient.id : const Uuid().v4(),
                          ingredientName: ingredient.name,
                          description: ingredient.description != null
                              ? ingredient.description!
                              : (ingredient.additives != null
                                  ? 'Contains: ${ingredient.additives!.join(", ")}'
                                  : null),
                          category: _inferCategoryFromIngredient(ingredient),
                          usageCount: 0,
                        );

                        try {
                          await provider.addToAvoidList(newItem);
                          if (!mounted) return;
                          final successMessage = 'Added "${ingredient.name}" to avoid list';
                          // Show snackbar outside async context
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(successMessage),
                                backgroundColor: Colors.green,
                              ),
                            );
                          });
                        } catch (e) {
                          if (!mounted) return;
                          final errorMessage = 'Failed to add: ${e.toString()}';
                          // Show snackbar outside async context
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
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

  String _inferCategoryFromIngredient(Ingredient ingredient) {
    final name = ingredient.name.toLowerCase();
    final categories = ingredient.categories ?? [];

    // Check categories first
    for (final cat in categories) {
      final lowerCat = cat.toLowerCase();
      if (lowerCat.contains('allergen') || lowerCat.contains('allerg')) {
        return 'Allergen';
      }
      if (lowerCat.contains('additive') || lowerCat.contains('color') || lowerCat.contains('preservative')) {
        if (lowerCat.contains('color')) return 'Color';
        if (lowerCat.contains('preservative')) return 'Preservative';
        return 'Additive';
      }
    }

    // Infer from ingredient name
    if (name.contains('color') || name.startsWith('e1') || name.startsWith('e2') || name.startsWith('e3')) {
      return 'Color';
    }
    if (name.contains('preserv') || name.contains('nitrate') || name.contains('nitrite')) {
      return 'Preservative';
    }
    if (name.contains('sweet') || name.contains('flavor') || name.contains('aroma')) {
      return 'Flavor';
    }

    return 'Other';
  }
}
