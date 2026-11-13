import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/notifier_engine.dart';
import 'package:lime_time_app/logics/repos/notifications/subscriptions.dart';
import 'package:meta/meta.dart';

part 'n_subscriptions_event.dart';
part 'n_subscriptions_state.dart';

class NSubscriptionsBloc
    extends Bloc<NSubscriptionsEvent, NSubscriptionsState> {
  SubscriptionsRepo repo = SubscriptionsRepo();
  NSubscriptionsBloc() : super(NSubscriptionsInitial()) {
    on<LoadSubscriptionsNotification>((event, emit) async {
      repo = await NotifierEngine().renderSubscriptions(repo);
      emit(NSubscriptionLoaded(repo));
    });
  }
}
