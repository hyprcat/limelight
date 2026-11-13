import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/logics/repos/notifications/threads.dart';
import 'package:meta/meta.dart';

part 'n_threads_event.dart';
part 'n_threads_state.dart';

class NThreadsBloc extends Bloc<NThreadsEvent, NThreadsState> {
  ThreadNotifications repo = ThreadNotifications();
  NThreadsBloc() : super(NThreadsInitial()) {
    on<LoadNThreads>((event, emit) async {
      repo = await NotifierEngine().renderThreads(repo);
      emit(NThreadsSuccess(repo));
    });
  }
}
