part of 'user_list_bloc.dart';

@immutable
abstract class UserListState {}

class UserListInitial extends UserListState {}

class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState {
  final List<UserData> users;
  final int currentPage;
  final bool hasMore;

  UserListLoaded({
    required this.users,
    required this.currentPage,
    required this.hasMore,
  });

  UserListLoaded copyWith({
    List<UserData>? users,
    int? currentPage,
    bool? hasMore,
  }) {
    return UserListLoaded(
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class UserListError extends UserListState {
  final String message;
  UserListError(this.message);
}
