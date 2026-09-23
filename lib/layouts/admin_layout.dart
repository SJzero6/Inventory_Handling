import 'package:flutter/material.dart';

import '../core/utils/responsive.dart';
import 'mobile_drawer.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  final String selectedRoute;

  const AdminLayout({
    super.key,
    required this.child,
    required this.selectedRoute,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigate(String route) {
    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile
          ? MobileDrawer(
              selectedRoute: widget.selectedRoute,
              onItemSelected: _navigate,
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Sidebar(
              selectedRoute: widget.selectedRoute,
              onItemSelected: _navigate,
            ),

          Expanded(
            child: Column(
              children: [
                TopBar(
                  onMenuPressed: isMobile
                      ? () {
                          _scaffoldKey.currentState?.openDrawer();
                        }
                      : null,
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 16 : 24),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
