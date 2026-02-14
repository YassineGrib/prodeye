import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/profile_repository.dart';
import '../models/health_condition.dart';
import 'profile_controller.dart';

import '../../../l10n/app_localizations.dart';

class HealthConditionsScreen extends ConsumerStatefulWidget {
  const HealthConditionsScreen({super.key});

  @override
  ConsumerState<HealthConditionsScreen> createState() =>
      _HealthConditionsScreenState();
}

class _HealthConditionsScreenState
    extends ConsumerState<HealthConditionsScreen> {
  final Set<HealthCondition> _selectedConditions = {};
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthConditions),
        actions: [
          TextButton(
            onPressed: () => _saveConditions(),
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
      body: userProfileAsync.when(
        data: (profile) {
          // Initialize selection from profile only once
          if (!_initialized && profile != null) {
            _selectedConditions.addAll(profile.healthConditions);
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.selectHealthConditions, // Used existing key or fallback
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...HealthCondition.values
                  .where(
                    (c) => c != HealthCondition.none,
                  ) // Hide 'none' from list if implied by empty
                  .map((condition) {
                    final isSelected = _selectedConditions.contains(condition);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(condition.localizedName(l10n)),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedConditions.add(condition);
                          } else {
                            _selectedConditions.remove(condition);
                          }
                        });
                      },
                    );
                  })
                  .toList(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading profile')),
      ),
    );
  }

  Future<void> _saveConditions() async {
    await ref
        .read(profileControllerProvider.notifier)
        .updateHealthConditions(_selectedConditions.toList());
    if (mounted) {
      context.pop();
    }
  }
}
