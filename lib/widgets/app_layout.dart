import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

/// Common layout for protected routes with navbar and sidebar
class AppLayout extends ConsumerStatefulWidget {
  final Widget child;
  final String? title;

  const AppLayout({
    super.key,
    required this.child,
    this.title,
  });

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout> {
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Orea UI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          // User info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.account_circle, size: 28),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.username ?? 'User',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Authenticated',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarExpanded ? 250 : 70,
            child: _buildSidebar(context),
          ),
          // Divider
          const VerticalDivider(width: 1, thickness: 1),
          // Main content
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          // Toggle sidebar button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: IconButton(
              icon: Icon(
                _isSidebarExpanded ? Icons.menu_open : Icons.menu,
              ),
              tooltip: _isSidebarExpanded ? 'Collapse Sidebar' : 'Expand Sidebar',
              onPressed: () {
                setState(() {
                  _isSidebarExpanded = !_isSidebarExpanded;
                });
              },
            ),
          ),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/',
                  isActive: currentLocation == '/',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.dynamic_form,
                  label: 'Reactive Form',
                  route: '/reactive-form',
                  isActive: currentLocation == '/reactive-form',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.people,
                  label: 'Users',
                  route: '/users',
                  isActive: currentLocation == '/users',
                ),
                const Divider(),
                _buildNavItem(
                  context: context,
                  icon: Icons.settings,
                  label: 'Settings',
                  route: '/settings',
                  isActive: currentLocation == '/settings',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.help_outline,
                  label: 'Help',
                  route: '/help',
                  isActive: currentLocation == '/help',
                ),
              ],
            ),
          ),
          // Footer
          if (_isSidebarExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(),
                  Text(
                    'Orea UI v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: label,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer.withOpacity(0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isActive ? colorScheme.primary : null,
          ),
          title: _isSidebarExpanded
              ? Text(
                  label,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? colorScheme.primary : null,
                  ),
                )
              : null,
          dense: true,
          visualDensity: VisualDensity.compact,
          onTap: () {
            context.go(route);
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
