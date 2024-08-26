// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/usecases/story/add_story_usecase.dart';
import 'package:socialseed/domain/usecases/story/fetch_story_usecase.dart';
import 'package:socialseed/domain/usecases/story/view_story_usecase.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';

part 'story_state.dart';

class StoryCubit extends Cubit<StoryState> {
  final AddStoryUsecase addStoryUsecase;
  final ViewStoryUsecase viewStoryUsecase;
  final FetchStoryUsecase fetchStoryUsecase;
  StoryCubit({
    required this.addStoryUsecase,
    required this.viewStoryUsecase,
    required this.fetchStoryUsecase,
  }) : super(StoryInitial());

  Future<void> createStory(
      {required StoryEntity story, required BuildContext context}) async {
    try {
      await addStoryUsecase.call(story);
    } on SocketException catch (_) {
      failureBar(context, "No Internet");
    } catch (_) {
      failureBar(context, _.toString());
    }
  }

  Future<void> viewStory(
      {required StoryEntity story, required BuildContext context}) async {
    try {
      await viewStoryUsecase.call(story);
      emit(StoryViewed(story.id));
    } on SocketException catch (_) {
      failureBar(context, "No Internet");
      emit(StoryNotViewed(story.id));
    } catch (_) {
      failureBar(context, _.toString());
      emit(StoryNotViewed(story.id));
    }
  }

  Future<void> fetchStory(
      {required String uid, required BuildContext context}) async {
    emit(StoryInitial());
    try {
      final response = fetchStoryUsecase.call(uid);

      response.listen((story) {
        if (story.isEmpty) {
          emit(const StoryLoaded([]));
        } else {
          emit(StoryLoaded(story));
        }
      });
    } on SocketException catch (_) {
      failureBar(context, "No Internet");
    } catch (_) {
      failureBar(context, _.toString());
    }
  }
}
