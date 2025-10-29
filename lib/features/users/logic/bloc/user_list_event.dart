part of 'user_list_bloc.dart';

@immutable
abstract class UserListEvent {}

class FetchUsersEvent extends UserListEvent {
  final int page;
  final bool isRefresh;

  FetchUsersEvent({this.page = 1, this.isRefresh = false});
}

class LogoutEvent extends UserListEvent {}
