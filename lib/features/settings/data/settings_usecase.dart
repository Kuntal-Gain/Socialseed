import 'package:socialseed/features/settings/model/milestones_model.dart';

abstract class SettingsUsecase {
  Future<void> createMilestone(MilestoneModel milestone);
  Future<List<MilestoneModel>> getMilestones();
}
