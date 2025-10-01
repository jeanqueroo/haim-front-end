import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../services/store_service.dart';
import '../../auth/services/auth_service.dart';
import 'store_workers_page.dart';
import '../../../providers/store_provider.dart';

class SelectStoreForUsersPage extends StatefulWidget {
  const SelectStoreForUsersPage({super.key});

  @override
  State<SelectStoreForUsersPage> createState() => _SelectStoreForUsersPageState();
}

class _SelectStoreForUsersPageState extends State<SelectStoreForUsersPage> {
  final StoreService _storeService = StoreService();
  List<StoreInfo> _stores = [];
  List<StoreInfo> _filteredStores = [];
  bool _isLoading = false;
  String? _errorMessage;
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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verificar si el usuario es admin y obtener su ID
      final authService = AuthService();
      final userRoles = await authService.getUserRoles();
      final isAdmin = userRoles.contains('admin');
      
      // Obtener el ID del usuario actual
      final userData = await authService.getUserData();
      final userId = userData?['id']?.toString() ?? '';
      
      List<StoreInfo> stores;
      if (isAdmin) {
        // Si es admin, obtener todas las tiendas sin filtrado
        stores = await _storeService.getAllStores();
      } else {
        // Si no es admin, obtener solo las tiendas del usuario
        stores = await _storeService.getStoresForUser(userId, context: context);
      }
      
      setState(() {
        _stores = stores;
        _filteredStores = stores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _onStoreTypeFilterChanged(String? storeType) {
    setState(() {
      _selectedStoreType = storeType;
      _applyFilters();
    });
  }

  void _onCountryFilterChanged(String? country) {
    setState(() {
      _selectedCountry = country;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<StoreInfo> filtered = _stores;

    // Filtrar por búsqueda de texto
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((store) {
        return store.name.toLowerCase().contains(_searchQuery) ||
               store.type.toLowerCase().contains(_searchQuery) ||
               store.address.toLowerCase().contains(_searchQuery) ||
               store.country.toLowerCase().contains(_searchQuery) ||
               store.phone.toLowerCase().contains(_searchQuery) ||
               (store.responsibleUserName?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Filtrar por tipo de tienda
    if (_selectedStoreType != null && _selectedStoreType!.isNotEmpty) {
      filtered = filtered.where((store) {
        return store.type.toLowerCase() == _selectedStoreType!.toLowerCase();
      }).toList();
    }

    // Filtrar por país
    if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
      filtered = filtered.where((store) {
        return store.country.toLowerCase() == _selectedCountry!.toLowerCase();
      }).toList();
    }

    setState(() {
      _filteredStores = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStoreType = null;
      _selectedCountry = null;
      _searchController.clear();
      _filteredStores = _stores;
    });
  }

  void _selectStore(StoreInfo store) {
    // Seleccionar la tienda en el provider global
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    storeProvider.selectStore(store);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StoreWorkersPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectStoreForUsers),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadStores,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'filter') {
                _showFilterDialog(l10n);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'filter',
                child: Row(
                  children: [
                    const Icon(Icons.filter_list),
                    const SizedBox(width: 8),
                    Text(l10n.filters),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchStores,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // Filtros activos
          if (_selectedStoreType != null || _selectedCountry != null || _searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_selectedStoreType != null)
                          Chip(
                            label: Text('${l10n.storeType}: ${_getStoreTypeName(_selectedStoreType!, l10n)}'),
                            onDeleted: () => _onStoreTypeFilterChanged(null),
                          ),
                        if (_selectedCountry != null)
                          Chip(
                            label: Text('${l10n.country}: ${_getCountryName(_selectedCountry!, l10n)}'),
                            onDeleted: () => _onCountryFilterChanged(null),
                          ),
                        if (_searchQuery.isNotEmpty)
                          Chip(
                            label: Text('${l10n.search}: "$_searchQuery"'),
                            onDeleted: () {
                              _searchController.clear();
                              _onSearchChanged();
                            },
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(l10n.clearFilters),
                  ),
                ],
              ),
            ),

          // Contenido principal
          Expanded(
            child: _buildBody(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
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
              l10n.errorLoadingStores,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadStores,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_stores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noStoresFound,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noStoresRegistered,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_filteredStores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noStoresWithFilters,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryChangingFilters,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear),
              label: Text(l10n.clearFilters),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStores.length,
      itemBuilder: (context, index) {
        final store = _filteredStores[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                _getStoreIcon(store.type),
                color: Colors.white,
              ),
            ),
            title: Text(
              store.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${l10n.storeType}: ${_getStoreTypeName(store.type, l10n)}'),
                if (store.address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('${l10n.address}: ${store.address}'),
                ],
                if (store.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('${l10n.phone}: ${store.phone}'),
                ],
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[600],
            ),
            onTap: () => _selectStore(store),
          ),
        );
      },
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

  String _getStoreTypeName(String type, AppLocalizations l10n) {
    switch (type.toLowerCase()) {
      case 'truck':
        return l10n.truck;
      case 'store':
        return l10n.store;
      case 'supermarket':
        return l10n.supermarket;
      case 'restaurant':
        return l10n.restaurant;
      default:
        return l10n.other;
    }
  }

  String _getCountryName(String country, AppLocalizations l10n) {
    switch (country.toLowerCase()) {
      case 'spain':
        return l10n.spain;
      case 'unitedstates':
        return l10n.unitedStates;
      default:
        return country;
    }
  }

  void _showFilterDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.filters),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro por tipo de tienda
              DropdownButtonFormField<String>(
                value: _selectedStoreType,
                decoration: InputDecoration(
                  labelText: l10n.storeType,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(l10n.allStoreTypes),
                  ),
                  DropdownMenuItem<String>(
                    value: 'truck',
                    child: Text(l10n.truck),
                  ),
                  DropdownMenuItem<String>(
                    value: 'store',
                    child: Text(l10n.store),
                  ),
                  DropdownMenuItem<String>(
                    value: 'supermarket',
                    child: Text(l10n.supermarket),
                  ),
                  DropdownMenuItem<String>(
                    value: 'restaurant',
                    child: Text(l10n.restaurant),
                  ),
                ],
                onChanged: _onStoreTypeFilterChanged,
              ),
              const SizedBox(height: 16),
              // Filtro por país
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: InputDecoration(
                  labelText: l10n.country,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(l10n.allCountries),
                  ),
                  DropdownMenuItem<String>(
                    value: 'spain',
                    child: Text(l10n.spain),
                  ),
                  DropdownMenuItem<String>(
                    value: 'unitedstates',
                    child: Text(l10n.unitedStates),
                  ),
                ],
                onChanged: _onCountryFilterChanged,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearFilters();
              },
              child: Text(l10n.clearFilters),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.applyFilters),
            ),
          ],
        );
      },
    );
  }
}
