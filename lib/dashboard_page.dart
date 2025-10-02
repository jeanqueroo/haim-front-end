import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/users/pages/register_user_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/users/pages/users_list_page.dart';
import 'features/stores/pages/register_store_page.dart';
import 'features/products/pages/register_product_page.dart';
import 'features/stores/pages/stores_list_page.dart';
import 'features/auth/pages/profile_page.dart';
import 'features/auth/providers/auth_provider.dart';
import 'l10n/app_localizations.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.dashboard ?? 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
            tooltip: l10n?.profile ?? 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SettingsPage(),
                ),
              );
            },
            tooltip: l10n?.settings ?? 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de bienvenida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n?.hello ?? 'Hello'} ${authProvider.userFullName ?? 'User'} 👋',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n?.welcomeToDashboard ?? 'Welcome to Dashboard',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            if (authProvider.userEmail != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                authProvider.userEmail!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Avatar del usuario
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Text(
                            _getInitials(authProvider.userFullName ?? 'U'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Roles del usuario
                  if (authProvider.userRoles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: authProvider.userRoles.map((role) {
                        String roleText;
                        Color roleColor;
                        switch (role) {
                          case 'admin':
                            roleText = l10n?.admin ?? 'Administrator';
                            roleColor = Colors.red;
                            break;
                          case 'vendedor':
                            roleText = l10n?.vendedor ?? 'Salesperson';
                            roleColor = Colors.blue;
                            break;
                          case 'user':
                            roleText = l10n?.user ?? 'User';
                            roleColor = Colors.green;
                            break;
                          default:
                            roleText = role;
                            roleColor = Colors.grey;
                        }
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: roleColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            roleText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección de acciones rápidas
            Text(
              l10n?.quickActions ?? 'Quick Actions',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de acciones
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                // Opciones de gestión de usuarios - Solo para administradores
                if (authProvider.isAdmin) ...[
                  _buildActionCard(
                    context,
                    icon: Icons.person_add_alt_1,
                    title: l10n?.registerUser ?? 'Register User',
                    subtitle: l10n?.createNewUser ?? 'Create new user',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const RegisterUserPage(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.people,
                    title: l10n?.viewUsers ?? 'View Users',
                    subtitle: l10n?.manageUsers ?? 'Manage users',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const UsersListPage(),
                        ),
                      );
                    },
                  ),
                ],
                _buildActionCard(
                  context,
                  icon: Icons.add_business,
                  title: l10n?.registerStore ?? 'Register Store',
                  subtitle: l10n?.addNewStore ?? 'Add new store',
                  color: Colors.green,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const RegisterStorePage(),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.add_shopping_cart,
                  title: l10n?.registerProduct ?? 'Register Product',
                  subtitle: l10n?.addProducts ?? 'Add products',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const RegisterProductPage(),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.store,
                  title: l10n?.viewStores ?? 'View Stores',
                  subtitle: l10n?.manageStores ?? 'Manage stores',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const StoresListPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sección de estadísticas
            Text(
              l10n?.statistics ?? 'Statistics',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Cards de estadísticas
            Row(
              children: [
                // Estadística de usuarios - Solo para administradores
                if (authProvider.isAdmin) ...[
                  Expanded(
                    child: _buildStatCard(
                      l10n?.users ?? 'Users',
                      '12',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: _buildStatCard(
                    l10n?.stores ?? 'Stores',
                    '5',
                    Icons.store,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    l10n?.products ?? 'Products',
                    '48',
                    Icons.inventory,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    l10n?.sales ?? 'Sales',
                    '156',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

