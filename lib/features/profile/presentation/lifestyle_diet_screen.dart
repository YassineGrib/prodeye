import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/profile_repository.dart';
import '../models/lifestyle.dart';
import '../models/diet_type.dart';
import 'profile_controller.dart';

import '../../../l10n/app_localizations.dart';

class LifestyleDietScreen extends ConsumerStatefulWidget {
  const LifestyleDietScreen({super.key});

  @override
  ConsumerState<LifestyleDietScreen> createState() =>
      _LifestyleDietScreenState();
}

class _LifestyleDietScreenState extends ConsumerState<LifestyleDietScreen> {
  Lifestyle? _selectedLifestyle;
  DietType? _selectedDietType;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lifestyleDiet)),
      body: userProfileAsync.when(
        data: (profile) {
          if (!_initialized && profile != null) {
            _selectedLifestyle = profile.lifestyle;
            _selectedDietType = profile.dietType;
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle(l10n.selectLifestyle), // Reusing keys roughly
              const SizedBox(height: 8),
              ...Lifestyle.values
                  .map(
                    (l) => RadioListTile<Lifestyle>(
                      value: l,
                      groupValue: _selectedLifestyle,
                      title: Text(l.localizedName(l10n)),
                      onChanged: (val) =>
                          setState(() => _selectedLifestyle = val),
                    ),
                  )
                  .toList(),

              const Divider(height: 32),

              _buildSectionTitle(l10n.selectDiet),
              const SizedBox(height: 8),
              ...DietType.values
                  .map(
                    (d) => RadioListTile<DietType>(
                      value: d,
                      groupValue: _selectedDietType,
                      title: Text(d.localizedName(l10n)),
                      onChanged: (val) =>
                          setState(() => _selectedDietType = val),
                    ),
                  )
                  .toList(),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  child: Text(l10n.saveChanges),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading profile')),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    await ref
        .read(profileControllerProvider.notifier)
        .updateLifestyleAndDiet(
          lifestyle: _selectedLifestyle,
          dietType: _selectedDietType,
        );
    if (mounted) {
      context.pop();
    }
  }
}
