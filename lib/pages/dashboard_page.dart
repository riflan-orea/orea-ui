import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/activity_card.dart';
import '../widgets/chart_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // MediaQuery for responsive design
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Responsive breakpoints
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
    final isLargeScreen = screenWidth >= 1200;

    // Grid columns based on screen size
    final crossAxisCount = isSmallScreen ? 1 : isMediumScreen ? 2 : 4;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(context, authState.username, isSmallScreen),
          const SizedBox(height: 32),

          // Stats Grid (Responsive Grid)
          _buildStatsGrid(context, crossAxisCount),
          const SizedBox(height: 32),

          // Charts and Activity Row (Responsive Layout)
          if (isSmallScreen)
            Column(
              children: [
                SizedBox(
                  height: 400,
                  child: _buildChartCard(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 400,
                  child: _buildActivityCard(),
                ),
              ],
            )
          else
            SizedBox(
              height: 400,
              child: Row(
                children: [
                  Expanded(
                    flex: isMediumScreen ? 1 : 2,
                    child: _buildChartCard(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: _buildActivityCard(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Quick Actions Section
          _buildQuickActions(context, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(
    BuildContext context,
    String? username,
    bool isSmallScreen,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${username ?? 'User'}! 👋',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 20 : 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what\'s happening with your projects today.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
          if (!isSmallScreen) ...[
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dashboard,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, int crossAxisCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Total Users',
          value: '1,234',
          icon: Icons.people,
          color: Colors.blue,
          subtitle: '+12% from last month',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Users card tapped!')),
            );
          },
        ),
        StatCard(
          title: 'Revenue',
          value: '\$45.2K',
          icon: Icons.attach_money,
          color: Colors.green,
          subtitle: '+8% from last month',
        ),
        StatCard(
          title: 'Active Projects',
          value: '23',
          icon: Icons.folder,
          color: Colors.orange,
          subtitle: '5 completed this week',
        ),
        StatCard(
          title: 'Tasks',
          value: '156',
          icon: Icons.task_alt,
          color: Colors.purple,
          subtitle: '12 pending',
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    return ChartCard(
      title: 'Weekly Overview',
      data: const [
        ChartData(label: 'Mon', value: 65),
        ChartData(label: 'Tue', value: 85),
        ChartData(label: 'Wed', value: 45),
        ChartData(label: 'Thu', value: 95),
        ChartData(label: 'Fri', value: 75),
        ChartData(label: 'Sat', value: 55),
        ChartData(label: 'Sun', value: 35),
      ],
    );
  }

  Widget _buildActivityCard() {
    return ActivityCard(
      title: 'Recent Activity',
      activities: const [
        ActivityItem(
          title: 'New user registered',
          description: 'John Doe created an account',
          time: '2 minutes ago',
          icon: Icons.person_add,
          color: Colors.blue,
          badge: 'NEW',
          badgeColor: Colors.blue,
        ),
        ActivityItem(
          title: 'Form submitted',
          description: 'Reactive form was successfully submitted',
          time: '15 minutes ago',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        ActivityItem(
          title: 'Project updated',
          description: 'Dashboard redesign completed',
          time: '1 hour ago',
          icon: Icons.update,
          color: Colors.orange,
          badge: 'UPDATE',
          badgeColor: Colors.orange,
        ),
        ActivityItem(
          title: 'User logged in',
          description: 'Jane Smith signed in',
          time: '2 hours ago',
          icon: Icons.login,
          color: Colors.purple,
        ),
        ActivityItem(
          title: 'Data exported',
          description: 'Monthly report generated',
          time: '3 hours ago',
          icon: Icons.download,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                context,
                'Reactive Form',
                Icons.dynamic_form,
                Colors.deepPurple,
                () => context.go('/reactive-form'),
              ),
              _buildActionButton(
                context,
                'Settings',
                Icons.settings,
                Colors.blue,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon!')),
                  );
                },
              ),
              _buildActionButton(
                context,
                'Analytics',
                Icons.analytics,
                Colors.green,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics coming soon!')),
                  );
                },
              ),
              _buildActionButton(
                context,
                'Help',
                Icons.help_outline,
                Colors.orange,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help coming soon!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }
}
