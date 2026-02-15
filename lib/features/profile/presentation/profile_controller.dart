import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';

import '../models/health_condition.dart';
import '../models/lifestyle.dart';
import '../models/diet_type.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

class ProfileController extends AsyncNotifier<void> {
  late final ProfileRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(profileRepositoryProvider);
    return null;
  }

  /// Save ALL profile fields in a single Firestore write
  Future<void> saveFullProfile({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    List<HealthCondition>? healthConditions,
    Lifestyle? lifestyle,
    DietType? dietType,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentProfile = await _repository.getUserProfile();
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          name: name,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
          healthConditions: healthConditions,
          lifestyle: lifestyle,
          dietType: dietType,
        );
        await _repository.updateUserProfile(updatedProfile);
        // Refresh the stream so the profile screen updates immediately
        ref.invalidate(userProfileProvider);
      }
    });
  }

  Future<void> updateProfile({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentProfile = await _repository.getUserProfile();
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          name: name,
          age: age,
          gender: gender,
          height: height,
          weight: weight,
        );
        await _repository.updateUserProfile(updatedProfile);
      }
    });
  }

  Future<void> updateHealthConditions(List<HealthCondition> conditions) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentProfile = await _repository.getUserProfile();
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          healthConditions: conditions,
        );
        await _repository.updateUserProfile(updatedProfile);
      }
    });
  }

  Future<void> updateLifestyleAndDiet({
    Lifestyle? lifestyle,
    DietType? dietType,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentProfile = await _repository.getUserProfile();
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          lifestyle: lifestyle,
          dietType: dietType,
        );
        await _repository.updateUserProfile(updatedProfile);
      }
    });
  }
}
