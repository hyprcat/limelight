import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/repos/notifications/for_you.dart';
import 'package:meta/meta.dart';

import 'package:lime_time_app/logics/engines/notifier_engine.dart';

part 'n_for_you_event.dart';
part 'n_for_you_state.dart';

class NForYouBloc extends Bloc<NForYouEvent, NForYouState> {
  ForYouRepo repo = ForYouRepo();
  NForYouBloc() : super(NForYouInitial()) {
    on<NForYouEvent>((event, emit) async {
      repo = await NotifierEngine().renderForYou(repo);
      emit(NForYouSuccess(repo));
    });
  }
}
