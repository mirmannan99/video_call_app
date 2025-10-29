import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/user_res_model.dart';
import '../logic/bloc/user_list_bloc.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<UserListBloc>().add(FetchUsersEvent(page: 1));

    _scrollController.addListener(() {
      final bloc = context.read<UserListBloc>();
      final state = bloc.state;
      if (state is UserListLoaded &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          state.hasMore) {
        bloc.add(FetchUsersEvent(page: state.currentPage + 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users")),
      body: BlocBuilder<UserListBloc, UserListState>(
        builder: (context, state) {
          if (state is UserListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserListError) {
            return Center(child: Text(state.message));
          } else if (state is UserListLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<UserListBloc>().add(
                  FetchUsersEvent(page: 1, isRefresh: true),
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.users.length + 1,
                itemBuilder: (context, index) {
                  if (index < state.users.length) {
                    final user = state.users[index];
                    return _userTile(user);
                  } else {
                    return state.hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _userTile(UserData user) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Text(user.email),
    );
  }
}
