import 'package:flutter/material.dart';
import 'register_product_page.dart';

class SelectStorePage extends StatefulWidget {
  const SelectStorePage({super.key});

  @override
  State<SelectStorePage> createState() => _SelectStorePageState();
}

class _SelectStorePageState extends State<SelectStorePage> {
  String? _selectedStore;
  bool _isLoading = false;

  // Lista de tiendas (simulada - en una app real vendría de una base de datos)
  static const List<Map<String, String>> _stores = [
    {'name': 'Mi Tienda Favorita', 'type': 'General', 'staff': '5 empleados'},
    {'name': 'Supermercado Central', 'type': 'Supermercado', 'staff': '25 empleados'},
    {'name': 'Farmacia San José', 'type': 'Farmacia', 'staff': '8 empleados'},
    {'name': 'ElectroMax', 'type': 'Electrónicos', 'staff': '12 empleados'},
    {'name': 'Ropa & Moda', 'type': 'Ropa', 'staff': '6 empleados'},
    {'name': 'Librería del Centro', 'type': 'Libros', 'staff': '4 empleados'},
  ];

  Future<void> _proceedToProductRegistration() async {
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una tienda'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular carga
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // Navegar a la página de registro de productos con la tienda seleccionada
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => RegisterProductPage(
          selectedStore: _selectedStore!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Tienda'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Icono y título
              Icon(
                Icons.store,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              
              Text(
                'Selecciona una tienda',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Elige la tienda donde quieres registrar productos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Lista de tiendas
              Expanded(
                child: ListView.builder(
                  itemCount: _stores.length,
                  itemBuilder: (BuildContext context, int index) {
                    final store = _stores[index];
                    final isSelected = _selectedStore == store['name'];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isSelected ? 4 : 1,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                          child: Icon(
                            Icons.store,
                            color: isSelected 
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                        title: Text(
                          store['name']!,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipo: ${store['type']}',
                              style: TextStyle(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Personal: ${store['staff']}',
                              style: TextStyle(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: isSelected 
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedStore = store['name'];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Botón para continuar
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _proceedToProductRegistration,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(_isLoading ? 'Cargando...' : 'Continuar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

