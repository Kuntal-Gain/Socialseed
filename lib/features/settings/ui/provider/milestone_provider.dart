import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/network/locator.dart';
import 'package:socialseed/features/settings/data/settings_usecase.dart';
import 'package:socialseed/features/settings/model/milestones_model.dart';

final milestonesProvider =
    AutoDisposeAsyncNotifierProvider<MilestoneNotifier, List<MilestoneModel>>(
  MilestoneNotifier.new,
);

class MilestoneNotifier extends AutoDisposeAsyncNotifier<List<MilestoneModel>> {
  @override
  Future<List<MilestoneModel>> build() async {
    final usecase = getIt<SettingsUsecase>();
    return usecase.getMilestones();
  }

  Future<void> createMilestone(MilestoneModel milestone) async {
    final usecase = getIt<SettingsUsecase>();
    await usecase.createMilestone(milestone);
  }
}
