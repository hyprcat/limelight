// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_category.dart';
import 'package:meta/meta.dart';

part 'add_something_event.dart';
part 'add_something_state.dart';

class AddSomethingBloc extends Bloc<AddSomethingEvent, AddSomethingState> {
  AddSomethingBloc() : super(AddSomethingInitial()) {
    on<LoadCategories>(loadCategories);
  }

  FutureOr<void> loadCategories(
      LoadCategories event, Emitter<AddSomethingState> emit) async {
    emit(LoadingCategories());
    try {
      List<LoungeCategory> categories = await LoungeEngine()
          .fetchAvailableCategories(authHandler.loggedInUser!.userId!);
      emit(LoadCategoriesSuccessful(categories));
    } catch (e) {
      emit(AddError());
    }
  }
}
