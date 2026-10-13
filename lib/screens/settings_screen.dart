import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return ListView(
            children: [
              // Premium upgrade section
              if (!provider.isPremium) _buildPremiumCard(context),

              // Camera settings
              _buildSectionHeader(context, 'Camera'),
              _buildSwitchTile(
                context,
                icon: Icons.flash_on,
                title: 'Auto Flashlight',
                subtitle: 'Enable flashlight in low light',
                value: provider.preferences.autoFlashlight,
                onChanged: (value) async {
                  await provider.updatePreferences(
                    provider.preferences.copyWith(autoFlashlight: value),
                  );
                },
              ),

              // Feedback settings
              _buildSectionHeader(context, 'Feedback'),
              _buildSwitchTile(
                context,
                icon: Icons.vibration,
                title: 'Vibration',
                subtitle: 'Vibrate on successful scan',
                value: provider.preferences.vibrationFeedback,
                onChanged: (value) async {
                  await provider.updatePreferences(
                    provider.preferences.copyWith(vibrationFeedback: value),
                  );
                },
              ),
              _buildSwitchTile(
                context,
                icon: Icons.volume_up,
                title: 'Sound',
                subtitle: 'Play sound on successful scan',
                value: provider.preferences.soundFeedback,
                onChanged: (value) async {
                  await provider.updatePreferences(
                    provider.preferences.copyWith(soundFeedback: value),
                  );
                },
              ),

              // Appearance
              _buildSectionHeader(context, 'Appearance'),
              _buildSwitchTile(
                context,
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: provider.preferences.darkMode,
                onChanged: (value) async {
                  await provider.updatePreferences(
                    provider.preferences.copyWith(darkMode: value),
                  );
                },
              ),

              // About
              _buildSectionHeader(context, 'About'),
              _buildListTile(
                context,
                icon: Icons.info,
                title: 'App Version',
                subtitle: AppConstants.appVersion,
                onTap: () {},
              ),
              _buildListTile(
                context,
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () {
                  // Navigate to privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy policy coming soon')),
                  );
                },
              ),
              _buildListTile(
                context,
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'FAQs and contact',
                onTap: () {
                  // Navigate to help
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help coming soon')),
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.amber.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Go Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Unlimited avoid list items, family profiles, cloud sync, and more!',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Show upgrade options
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Upgrade to Premium'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem(context, 'Unlimited avoid list items'),
                      _buildFeatureItem(context, 'Family profiles (up to 5)'),
                      _buildFeatureItem(context, 'Cloud sync across devices'),
                      _buildFeatureItem(context, 'Advanced analytics'),
                      _buildFeatureItem(context, 'Export data'),
                      const Divider(),
                      Text(
                        '\$${AppConstants.premiumPrice}/month',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                        // Implement payment flow
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment integration coming soon'),
                          ),
                        );
                      },
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.amber.shade700,
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(feature),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
