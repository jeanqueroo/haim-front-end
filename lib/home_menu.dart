import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/pages/settings_page.dart';
import 'register_store_page.dart';
import 'select_store_page.dart';
import 'dashboard_page.dart';
import 'features/auth/pages/profile_page.dart';
import 'l10n/app_localizations.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key});

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    ProfilePage(),
    SettingsPage(),
    _RegisterStorePage(),
    _SelectStorePage(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutConfirmation),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      // Cerrar el drawer primero
      Navigator.of(context).pop();
      
      // Cerrar sesión usando el AuthProvider
      authProvider.logout();
      
      // Navegar de vuelta a la página de login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginPage(),
        ),
      );
      
      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sessionClosed),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (_selectedIndex) {
            0 => l10n.home,
            1 => l10n.profile,
            2 => l10n.settings,
            3 => l10n.registerStore,
            _ => l10n.selectStore,
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(authProvider.userFullName ?? l10n.user),
              accountEmail: Text(authProvider.userEmail ?? ''),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  _getInitials(authProvider.userFullName ?? 'U'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(l10n.home),
              selected: _selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.profile),
              selected: _selectedIndex == 1,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settings),
              selected: _selectedIndex == 2,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_business),
              title: Text(l10n.registerStore),
              selected: _selectedIndex == 3,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: Text(l10n.registerProduct),
              selected: _selectedIndex == 4,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(4);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logout),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        destinations: <NavigationDestination>[
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), label: l10n.home),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: l10n.profile),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: l10n.settings),
          NavigationDestination(icon: const Icon(Icons.add_business), label: l10n.store),
          NavigationDestination(icon: const Icon(Icons.add_shopping_cart), label: l10n.product),
        ],
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



class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        SwitchListTile(
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (_) {},
          secondary: const Icon(Icons.dark_mode_outlined),
          title: Text(l10n.darkMode),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.version),
          subtitle: const Text('1.0.0'),
        ),
      ],
    );
  }
}

class _RegisterStorePage extends StatelessWidget {
  const _RegisterStorePage();

  @override
  Widget build(BuildContext context) {
    return const RegisterStorePage();
  }
}

class _SelectStorePage extends StatelessWidget {
  const _SelectStorePage();

  @override
  Widget build(BuildContext context) {
    return const SelectStorePage();
  }
}



