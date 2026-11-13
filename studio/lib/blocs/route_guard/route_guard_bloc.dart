// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:code_arrow_creator_studio/main.dart';
import 'package:meta/meta.dart';

part 'route_guard_event.dart';
part 'route_guard_state.dart';

class RouteGuardBloc extends Bloc<RouteGuardEvent, RouteGuardState> {
  RouteGuardBloc() : super(RouteGuardInitial()) {
    on<BasicRouteProtection>(checkStatus);
  }

  FutureOr<void> checkStatus(BasicRouteProtection event, Emitter<RouteGuardState> emit) async {
    var localData = await storage.readAll();
    if (localData['token'] != null) {
      emit(LoggedIn());
    } else {
      emit(NotLoggedIn());
    }
  }
}
