import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:meta/meta.dart';

part 'account_deletion_event.dart';
part 'account_deletion_state.dart';

class AccountDeletionBloc
    extends Bloc<AccountDeletionEvent, AccountDeletionState> {
  AccountDeletionBloc() : super(AccountDeletionInitial()) {
    on<LoadAccountDeletionEvent>((event, emit) async {
      try {
        bool response = await UserEngine().checkUserAccountRemoval();

        emit(AccDeletionPageSuccess(response));
      } catch (e) {
        rethrow;
      }
    });
  }
}
