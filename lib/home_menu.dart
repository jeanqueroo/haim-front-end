import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_store_page.dart';
import 'select_store_page.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key});

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    _DashboardPage(),
    _ProfilePage(),
    _SettingsPage(),
    _RegisterStorePage(),
    _SelectStorePage(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      // Cerrar el drawer primero
      Navigator.of(context).pop();
      
      // Navegar de vuelta a la página de login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginPage(),
        ),
      );
      
      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (_selectedIndex) {
            0 => 'Inicio',
            1 => 'Perfil',
            2 => 'Ajustes',
            3 => 'Registrar Tienda',
            _ => 'Seleccionar Tienda',
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text('Usuario Demo'),
              accountEmail: Text('demo@demo.com'),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Inicio'),
              selected: _selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              selected: _selectedIndex == 1,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Ajustes'),
              selected: _selectedIndex == 2,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_business),
              title: const Text('Registrar Tienda'),
              selected: _selectedIndex == 3,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Registrar Producto'),
              selected: _selectedIndex == 4,
              onTap: () {
                Navigator.pop(context);
                _onNavTap(4);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
          NavigationDestination(icon: Icon(Icons.add_business), label: 'Tienda'),
          NavigationDestination(icon: Icon(Icons.add_shopping_cart), label: 'Producto'),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Bienvenido al dashboard'),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        ListTile(leading: Icon(Icons.person), title: Text('Nombre'), subtitle: Text('Usuario Demo')),
        ListTile(leading: Icon(Icons.email), title: Text('Email'), subtitle: Text('demo@demo.com')),
      ],
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        SwitchListTile(
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (_) {},
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Modo oscuro (demo)'),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Versión'),
          subtitle: Text('1.0.0'),
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



