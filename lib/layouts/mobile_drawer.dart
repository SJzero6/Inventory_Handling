import 'package:flutter/material.dart';

import 'sidebar.dart';

class MobileDrawer extends StatelessWidget {
  final String selectedRoute;
  final Function(String route) onItemSelected;

  const MobileDrawer({
    super.key,
    required this.selectedRoute,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Sidebar(
        selectedRoute: selectedRoute,
        onItemSelected: (route) {
          Navigator.pop(context);
          onItemSelected(route);
        },
      ),
    );
  }
}
