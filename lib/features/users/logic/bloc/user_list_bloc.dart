import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import '../../data/user_repository.dart';
import '../../data/user_res_model.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends HydratedBloc<UserListEvent, UserListState> {
  UserListBloc() : super(UserListInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
  }

  Future<void> _onFetchUsers(
    FetchUsersEvent event,
    Emitter<UserListState> emit,
  ) async {
    try {
      final currentState = state;

      // Show loader only for first-time load
      if (event.page == 1 &&
          !event.isRefresh &&
          currentState is! UserListLoaded) {
        emit(UserListLoading());
      }

      final response = await UserRepository.fetchUsers(page: event.page);

      if (response.error) {
        // Preserve cached data if available
        if (currentState is UserListLoaded) {
          emit(currentState);
        } else {
          emit(UserListError(response.errorMessage ?? 'Failed to load users'));
        }
        return;
      }

      final fetchedUsers = response.data?.data ?? [];
      final totalPages = response.data?.totalPages ?? 1;
      final hasMore = event.page < totalPages;

      if (currentState is UserListLoaded && event.page > 1) {
        final updatedUsers = [...currentState.users, ...fetchedUsers];
        emit(
          currentState.copyWith(
            users: updatedUsers,
            currentPage: event.page,
            hasMore: hasMore,
          ),
        );
      } else {
        emit(
          UserListLoaded(
            users: fetchedUsers,
            currentPage: event.page,
            hasMore: hasMore,
          ),
        );
      }
    } catch (e) {
      final currentState = state;
      if (currentState is UserListLoaded) {
        emit(currentState); // Keep last good cache
      } else {
        emit(UserListError(e.toString()));
      }
    }
  }

  // ✅ Restore last successful cached state
  @override
  UserListState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        final usersJson = (json['users'] as List?) ?? const [];
        final users = usersJson
            .map((e) => UserData.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        return UserListLoaded(
          users: users,
          currentPage: json['currentPage'] as int? ?? 1,
          hasMore: json['hasMore'] as bool? ?? false,
        );
      }
    } catch (_) {
      // ignore malformed cache
    }
    return null;
  }

  // ✅ Persist only loaded state
  @override
  Map<String, dynamic>? toJson(UserListState state) {
    if (state is UserListLoaded) {
      return {
        'type': 'loaded',
        'users': state.users.map((u) => u.toJson()).toList(),
        'currentPage': state.currentPage,
        'hasMore': state.hasMore,
      };
    }
    return null;
  }
}
