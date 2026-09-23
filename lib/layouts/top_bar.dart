import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const TopBar({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    String name = 'User';
    String company = '';
    String branch = '';

    final state = context.read<AuthBloc>().state;

    if (state is AuthAuthenticated) {
      name = state.loginResponse.user.fullName;
      company = state.loginResponse.company.name;
      branch = state.loginResponse.branch.name;
    }

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (onMenuPressed != null)
            IconButton(onPressed: onMenuPressed, icon: const Icon(Icons.menu)),

          const Spacer(),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),

          const SizedBox(width: 8),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(LogoutRequested());

                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(name),
                  subtitle: Text('$company\n$branch'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
                ),
                const SizedBox(width: 10),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
