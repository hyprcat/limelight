import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/logics/repos/notifications/lounges.dart';
import 'package:meta/meta.dart';

part 'n_lounges_event.dart';
part 'n_lounges_state.dart';

class NLoungesBloc extends Bloc<NLoungesEvent, NLoungesState> {
  LoungeNotificationRepo repo = LoungeNotificationRepo();
  NLoungesBloc() : super(NLoungesInitial()) {
    on<LoadNLounges>((event, emit) async {
      repo = await NotifierEngine().renderLoungeNotifications(repo);
      emit(NLoungeSuccess(repo));
    });
  }
}
