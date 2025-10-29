import 'package:cached_network_image/cached_network_image.dart';
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
      appBar: AppBar(
        title: const Text("Users"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await _showLogoutConfirmDialog();
              if (confirm) {
                if (!context.mounted) return;
                context.read<UserListBloc>().add(LogoutEvent());
              }
            },
          ),
        ],
      ),
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
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: CachedNetworkImage(
          imageUrl: user.avatar,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const CircularProgressIndicator(strokeWidth: 1),
          errorWidget: (context, url, error) =>
              const Icon(Icons.person, size: 40, color: Colors.grey),
        ),
      ),

      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Text(user.email),
    );
  }

  Future<bool> _showLogoutConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Log out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Log out',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
