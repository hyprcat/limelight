part of 'add_something_bloc.dart';

@immutable
abstract class AddSomethingState {}

class AddSomethingInitial extends AddSomethingState {}

class LoadCategoriesSuccessful extends AddSomethingInitial {
  final List<LoungeCategory> categories;
  LoadCategoriesSuccessful(this.categories);
}

class LoadingCategories extends AddSomethingState {}

class AddError extends AddSomethingState {}
