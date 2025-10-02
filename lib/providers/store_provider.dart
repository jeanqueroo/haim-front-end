import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/stores/services/store_service.dart';
import '../features/auth/providers/auth_provider.dart';

class StoreProvider extends ChangeNotifier {
  final StoreService _storeService = StoreService();
  
  StoreInfo? _selectedStore;
  List<StoreInfo> _stores = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  StoreInfo? get selectedStore => _selectedStore;
  List<StoreInfo> get stores => _stores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasStore => _selectedStore != null;

  // Inicializar el provider
  Future<void> initialize({AuthProvider? authProvider}) async {
    await loadStores(authProvider: authProvider);
  }

  // Cargar tiendas basado en el rol del usuario
  Future<void> loadStores({AuthProvider? authProvider}) async {
    _setLoading(true);
    _clearError();
    
    try {
      List<StoreInfo> stores = [];
      
      if (authProvider != null && authProvider.isAdmin) {
        // Admin puede ver todas las tiendas
        stores = await _storeService.getAllStores();
      } else if (authProvider != null && authProvider.currentUser != null) {
        // Usuario normal solo ve sus tiendas
        final userId = authProvider.currentUser!['id']?.toString() ?? '';
        if (userId.isNotEmpty) {
          stores = await _storeService.getStoresForUser(userId);
        }
      } else {
        // Fallback: cargar todas las tiendas si no hay información de usuario
        stores = await _storeService.getAllStores();
      }
      
      _stores = stores;
      
      // Si no hay tienda seleccionada y hay tiendas disponibles, seleccionar la primera
      if (_selectedStore == null && stores.isNotEmpty) {
        _selectedStore = stores.first;
      }
    } catch (e) {
      _setError('Error al cargar tiendas: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Seleccionar una tienda
  void selectStore(StoreInfo store) {
    _selectedStore = store;
    _clearError();
    notifyListeners();
  }

  // Deseleccionar tienda
  void clearStore() {
    _selectedStore = null;
    notifyListeners();
  }

  // Obtener tienda por ID
  StoreInfo? getStoreById(String id) {
    try {
      return _stores.firstWhere((store) => store.id == id);
    } catch (e) {
      return null;
    }
  }

  // Verificar si una tienda está seleccionada
  bool isStoreSelected(String storeId) {
    return _selectedStore?.id == storeId;
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Método para mostrar diálogo de selección de tienda
  Future<StoreInfo?> showStoreSelector(BuildContext context) async {
    // Obtener el AuthProvider del contexto
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_stores.isEmpty) {
      await loadStores(authProvider: authProvider);
    }

    return await showDialog<StoreInfo>(
      context: context,
      builder: (BuildContext context) {
        return StoreSelectorDialog(
          stores: _stores,
          selectedStore: _selectedStore,
          isAdmin: authProvider.isAdmin,
          onStoreSelected: (StoreInfo store) {
            selectStore(store);
            Navigator.of(context).pop(store);
          },
        );
      },
    );
  }
}

// Widget para mostrar el selector de tienda
class StoreSelectorDialog extends StatefulWidget {
  final List<StoreInfo> stores;
  final StoreInfo? selectedStore;
  final bool isAdmin;
  final Function(StoreInfo) onStoreSelected;

  const StoreSelectorDialog({
    super.key,
    required this.stores,
    this.selectedStore,
    required this.isAdmin,
    required this.onStoreSelected,
  });

  @override
  State<StoreSelectorDialog> createState() => _StoreSelectorDialogState();
}

class _StoreSelectorDialogState extends State<StoreSelectorDialog> {
  StoreInfo? _tempSelectedStore;

  @override
  void initState() {
    super.initState();
    _tempSelectedStore = widget.selectedStore;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Seleccionar Tienda'),
          const SizedBox(height: 4),
          Text(
            widget.isAdmin 
                ? 'Vista de Administrador - Todas las tiendas'
                : 'Tus tiendas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: widget.isAdmin ? Colors.blue : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: widget.stores.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando tiendas...'),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: widget.stores.length,
                itemBuilder: (context, index) {
                  final store = widget.stores[index];
                  final isSelected = _tempSelectedStore?.id == store.id;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(
                              _getStoreIcon(store.type),
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (widget.isAdmin && store.responsibleUserId.isNotEmpty)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        store.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(store.address),
                          Text(
                            _getStoreTypeName(store.type),
                            style: Theme.of(context).textTheme.bodySmall,
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
                          _tempSelectedStore = store;
                        });
                      },
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _tempSelectedStore != null
              ? () => widget.onStoreSelected(_tempSelectedStore!)
              : null,
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }

  IconData _getStoreIcon(String type) {
    switch (type.toLowerCase()) {
      case 'truck':
        return Icons.local_shipping;
      case 'store':
        return Icons.store;
      case 'supermarket':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.business;
    }
  }

  String _getStoreTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'truck':
        return 'Camión';
      case 'store':
        return 'Tienda';
      case 'supermarket':
        return 'Supermercado';
      case 'restaurant':
        return 'Restaurante';
      default:
        return 'Otro';
    }
  }
}
