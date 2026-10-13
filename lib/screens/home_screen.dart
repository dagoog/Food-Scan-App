import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/scanned_product.dart';
import '../utils/theme.dart';
import 'scan_screen.dart';
import 'avoid_list_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const AvoidListScreen(),
    const LibraryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Avoid List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodScan'),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              if (provider.isPremium) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.star,
                    color: Colors.amber.shade700,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick stats
                _buildStatsCard(context, provider),
                const SizedBox(height: 24),

                // Last scan
                if (provider.lastScan != null) ...[
                  _buildLastScanCard(context, provider.lastScan!),
                  const SizedBox(height: 24),
                ],

                // Quick actions
                _buildQuickActions(context),
                const SizedBox(height: 24),

                // Recent scans
                _buildRecentScans(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, AppProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Scans', provider.scanHistory.length.toString()),
                _buildStatItem(
                  'Avoided',
                  provider.avoidListCount.toString(),
                ),
                _buildStatItem(
                  'Premium',
                  provider.isPremium ? 'Yes' : 'No',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLastScanCard(BuildContext context, ScannedProduct scan) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to product detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Safety indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.getSafetyColor(scan.safetyStatus.name),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppTheme.getSafetyIcon(scan.safetyStatus.name),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.product.productName ?? 'Unknown Product',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.safetyStatus.name.toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.getSafetyColor(scan.safetyStatus.name),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.qr_code_scanner,
            label: 'Scan',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScanScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.search,
            label: 'Search',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LibraryScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScans(BuildContext context, AppProvider provider) {
    if (provider.scanHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Scans',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.scanHistory.take(5).length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final scan = provider.scanHistory[index];
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.getSafetyColor(scan.safetyStatus.name),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppTheme.getSafetyIcon(scan.safetyStatus.name),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(scan.product.productName ?? 'Unknown'),
              subtitle: Text(
                '${scan.safetyStatus.name} • ${scan.scanMethod ?? 'barcode'}',
              ),
              trailing: Text(
                _formatTimeAgo(scan.scanTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
