import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/avoid_list_item.dart';
import '../utils/constants.dart';

class AvoidListScreen extends StatefulWidget {
  const AvoidListScreen({super.key});

  @override
  State<AvoidListScreen> createState() => _AvoidListScreenState();
}

class _AvoidListScreenState extends State<AvoidListScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = AppConstants.itemCategories.first;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Avoid List'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredient Name',
                    hintText: 'e.g., Artificial Colors',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an ingredient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: AppConstants.itemCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Brief description of why to avoid',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _addItem();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    final provider = context.read<AppProvider>();

    // Check premium limit
    if (!provider.isPremium && provider.avoidListCount >= AppConstants.freeAvoidListLimit) {
      _showUpgradeDialog();
      return;
    }

    final item = AvoidListItem(
      id: const Uuid().v4(),
      ingredientName: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
    );

    provider.addToAvoidList(item);

    // Clear form
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = AppConstants.itemCategories.first;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to avoid list'),
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
            onPressed: () {
              Navigator.pop(context);
              // Navigate to premium screen (to be implemented)
            },
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
        title: const Text('Avoid List'),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              if (provider.isPremium) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('Premium'),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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

          // Limit warning for free users
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              if (!provider.isPremium &&
                  provider.avoidListCount >= AppConstants.freeAvoidListLimit) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Free limit reached. Upgrade to add more items.',
                          style: TextStyle(color: Colors.amber.shade800),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Items list
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, _) {
                final items = provider.searchAvoidList(_searchController.text);

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No items in your avoid list'
                              : 'No matching items',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_searchController.text.isEmpty)
                          Text(
                            'Tap + to add your first ingredient',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItemCard(context, provider, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final atLimit = !provider.isPremium &&
              provider.avoidListCount >= AppConstants.freeAvoidListLimit;

          return FloatingActionButton(
            onPressed: atLimit ? _showUpgradeDialog : _showAddDialog,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, AppProvider provider, AvoidListItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.removeFromAvoidList(item.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(item.category),
            child: Text(
              item.ingredientName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            item.ingredientName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: item.description != null
              ? Text(item.description!)
              : Text(
                  item.category ?? 'Uncategorized',
                  style: TextStyle(color: Colors.grey[600]),
                ),
          trailing: item.usageCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.usageCount}x',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'allergen':
        return Colors.red;
      case 'additive':
        return Colors.orange;
      case 'preservative':
        return Colors.amber;
      case 'color':
        return Colors.purple;
      case 'flavor':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
