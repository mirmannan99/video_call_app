import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../data/user_repository.dart';
import '../../data/user_res_model.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  UserListBloc() : super(UserListInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
  }

  Future<void> _onFetchUsers(
    FetchUsersEvent event,
    Emitter<UserListState> emit,
  ) async {
    try {
      final currentState = state;

      if (event.page == 1 && !event.isRefresh) {
        emit(UserListLoading());
      }

      final response = await UserRepository.fetchUsers(page: event.page);

      if (response.error) {
        emit(UserListError(response.errorMessage ?? 'Failed to load users'));
        return;
      }

      final fetchedUsers = response.data?.data ?? [];
      final totalPages = response.data?.totalPages ?? 1;

      bool hasMore = event.page < totalPages;

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
      emit(UserListError(e.toString()));
    }
  }
}
