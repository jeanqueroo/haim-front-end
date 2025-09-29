import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../services/store_service.dart';
import 'edit_store_page.dart';

class StoresListPage extends StatefulWidget {
  const StoresListPage({super.key});

  @override
  State<StoresListPage> createState() => _StoresListPageState();
}

class _StoresListPageState extends State<StoresListPage> {
  final StoreService _storeService = StoreService();
  List<StoreInfo> _stores = [];
  List<StoreInfo> _filteredStores = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros
  String _searchQuery = '';
  String? _selectedStoreType;
  String? _selectedCountry;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStores();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredStores = _stores.where((store) {
        // Filtro por búsqueda de texto
        final matchesSearch = _searchQuery.isEmpty ||
            store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            store.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            store.phone.contains(_searchQuery);

        // Filtro por tipo de tienda
        final matchesType = _selectedStoreType == null ||
            store.type.toLowerCase() == _selectedStoreType!.toLowerCase();

        // Filtro por país
        final matchesCountry = _selectedCountry == null ||
            store.country.toLowerCase() == _selectedCountry!.toLowerCase();

        return matchesSearch && matchesType && matchesCountry;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStoreType = null;
      _selectedCountry = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  List<Map<String, String>> _getStoreTypeOptions(AppLocalizations l10n) {
    final isSpanish = l10n.locale.languageCode == 'es';
    
    return [
      {'key': 'truck', 'value': isSpanish ? 'Camión' : 'Truck'},
      {'key': 'store', 'value': l10n.store},
      {'key': 'supermarket', 'value': isSpanish ? 'Supermercado' : 'Supermarket'},
      {'key': 'restaurant', 'value': isSpanish ? 'Restaurante' : 'Restaurant'},
      {'key': 'other', 'value': l10n.other},
    ];
  }

  List<Map<String, String>> _getCountryOptions(AppLocalizations l10n) {
    return [
      {'key': 'spain', 'value': l10n.spain},
      {'key': 'unitedStates', 'value': l10n.unitedStates},
    ];
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stores = await _storeService.getAllStores();
      setState(() {
        _stores = stores;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStore(String storeId) async {
    try {
      final result = await _storeService.deleteStore(storeId);
      if (result.isSuccess) {
        // Recargar la lista de tiendas
        await _loadStores();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tienda eliminada exitosamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar tienda: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _navigateToEditStore(StoreInfo store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStorePage(
          storeId: store.id,
          storeInfo: store,
        ),
      ),
    ).then((result) {
      // Recargar la lista si se actualizó la tienda
      if (result == true) {
        _loadStores();
      }
    });
  }

  void _showDeleteConfirmation(String storeId, String storeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar la tienda "$storeName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteStore(storeId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  String _getStoreTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'truck':
        return '🚛';
      case 'store':
        return '🏪';
      case 'supermarket':
        return '🏬';
      case 'restaurant':
        return '🍽️';
      case 'other':
        return '🏢';
      default:
        return '🏪';
    }
  }

  String _getStoreTypeName(String type, AppLocalizations l10n) {
    final isSpanish = l10n.locale.languageCode == 'es';
    
    switch (type.toLowerCase()) {
      case 'truck':
        return isSpanish ? 'Camión' : 'Truck';
      case 'store':
        return l10n.store;
      case 'supermarket':
        return isSpanish ? 'Supermercado' : 'Supermarket';
      case 'restaurant':
        return isSpanish ? 'Restaurante' : 'Restaurant';
      case 'other':
        return l10n.other;
      default:
        return type;
    }
  }

  String _getCountryName(String country, AppLocalizations l10n) {
    switch (country.toLowerCase()) {
      case 'spain':
      case 'es':
        return l10n.spain;
      case 'unitedstates':
      case 'us':
      case 'usa':
        return l10n.unitedStates;
      default:
        return country;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSpanish = l10n.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(isSpanish ? 'Lista de Tiendas' : 'Stores List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadStores,
            icon: const Icon(Icons.refresh),
            tooltip: isSpanish ? 'Actualizar' : 'Refresh',
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: isSpanish ? 'Filtros' : 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: isSpanish ? 'Buscar tiendas...' : 'Search stores...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Lista de tiendas
          Expanded(child: _buildBody(l10n, isSpanish)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register-store').then((_) {
            // Recargar la lista cuando regrese de registrar una tienda
            _loadStores();
          });
        },
        child: const Icon(Icons.add),
        tooltip: isSpanish ? 'Agregar Tienda' : 'Add Store',
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, bool isSpanish) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStores,
              child: Text(isSpanish ? 'Reintentar' : 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredStores.isEmpty) {
      final hasFilters = _searchQuery.isNotEmpty || _selectedStoreType != null || _selectedCountry != null;
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_list_off : Icons.store_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters 
                  ? (isSpanish ? 'No se encontraron tiendas con los filtros aplicados' : 'No stores found with applied filters')
                  : (isSpanish ? 'No hay tiendas registradas' : 'No stores registered'),
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (hasFilters) ...[
              Text(
                isSpanish ? 'Intenta cambiar los filtros o limpiar la búsqueda' : 'Try changing filters or clear the search',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: Text(isSpanish ? 'Limpiar filtros' : 'Clear filters'),
              ),
            ] else ...[
              Text(
                isSpanish ? 'Toca el botón + para agregar una tienda' : 'Tap the + button to add a store',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStores,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredStores.length,
        itemBuilder: (context, index) {
          final store = _filteredStores[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  _getStoreTypeIcon(store.type),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              title: Text(
                store.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStoreTypeName(store.type, l10n),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${store.address}, ${_getCountryName(store.country, l10n)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        store.phone,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (store.createdAt != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSpanish 
                              ? 'Creado: ${_formatDate(store.createdAt!)}'
                              : 'Created: ${_formatDate(store.createdAt!)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEditStore(store);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(store.id, store.name);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue[400]),
                        const SizedBox(width: 8),
                        Text(
                          isSpanish ? 'Editar' : 'Edit',
                          style: TextStyle(color: Colors.blue[400]),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red[400]),
                        const SizedBox(width: 8),
                        Text(
                          isSpanish ? 'Eliminar' : 'Delete',
                          style: TextStyle(color: Colors.red[400]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context);
    final isSpanish = l10n.locale.languageCode == 'es';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isSpanish ? 'Filtros' : 'Filters'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filtro por tipo de tienda
                  DropdownButtonFormField<String>(
                    value: _selectedStoreType,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Tipo de tienda' : 'Store Type',
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(isSpanish ? 'Todos los tipos' : 'All types'),
                      ),
                      ..._getStoreTypeOptions(l10n).map((type) {
                        return DropdownMenuItem<String>(
                          value: type['key'],
                          child: Text(type['value']!),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedStoreType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Filtro por país
                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'País' : 'Country',
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(isSpanish ? 'Todos los países' : 'All countries'),
                      ),
                      ..._getCountryOptions(l10n).map((country) {
                        return DropdownMenuItem<String>(
                          value: country['key'],
                          child: Text(country['value']!),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedCountry = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearFilters();
                  },
                  child: Text(isSpanish ? 'Limpiar' : 'Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  child: Text(isSpanish ? 'Aplicar' : 'Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}