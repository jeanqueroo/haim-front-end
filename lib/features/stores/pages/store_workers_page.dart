import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../users/services/user_service.dart';
import '../services/store_service.dart';

class StoreWorkersPage extends StatefulWidget {
  final StoreInfo store;

  const StoreWorkersPage({
    super.key,
    required this.store,
  });

  @override
  State<StoreWorkersPage> createState() => _StoreWorkersPageState();
}

class _StoreWorkersPageState extends State<StoreWorkersPage> {
  final UserService _userService = UserService();
  List<UserInfo> _workers = [];
  List<UserInfo> _filteredWorkers = [];
  Set<String> _selectedWorkers = {}; // IDs de trabajadores seleccionados
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedRole;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _userService.getAllUsers(context: context);
      // Filtrar solo los trabajadores de esta tienda
      // Por ahora mostramos todos los usuarios, pero en el futuro se puede filtrar por tienda
      final workers = users.where((user) => 
        user.roles.contains('vendedor') || user.roles.contains('admin')
      ).toList();
      
      setState(() {
        _workers = workers;
        _filteredWorkers = workers;
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

  void _onRoleFilterChanged(String? role) {
    setState(() {
      _selectedRole = role;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<UserInfo> filtered = _workers;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.firstName.toLowerCase().contains(_searchQuery) ||
               user.lastName.toLowerCase().contains(_searchQuery) ||
               user.email.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Filtrar por rol
    if (_selectedRole != null && _selectedRole!.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.roles.contains(_selectedRole!);
      }).toList();
    }

    setState(() {
      _filteredWorkers = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedRole = null;
      _searchController.clear();
      _filteredWorkers = _workers;
    });
  }

  void _toggleWorkerSelection(UserInfo worker) {
    setState(() {
      if (_selectedWorkers.contains(worker.id)) {
        _selectedWorkers.remove(worker.id);
      } else {
        _selectedWorkers.add(worker.id);
      }
    });
  }

  void _selectAllWorkers() {
    setState(() {
      _selectedWorkers = _filteredWorkers.map((worker) => worker.id).toSet();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedWorkers.clear();
    });
  }

  Future<void> _sendSelectedWorkers() async {
    if (_selectedWorkers.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectWorkersFirst),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    final selectedWorkersList = _workers.where((worker) => _selectedWorkers.contains(worker.id)).toList();

    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmSendWorkers),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.selectedWorkersCount}: ${_selectedWorkers.length}'),
              const SizedBox(height: 8),
              Text(l10n.workersToSend),
              const SizedBox(height: 8),
              ...selectedWorkersList.take(3).map((worker) => 
                Text('• ${worker.firstName} ${worker.lastName} (${worker.email})')
              ).toList(),
              if (selectedWorkersList.length > 3)
                Text('... ${l10n.andMore.replaceAll('{count}', (selectedWorkersList.length - 3).toString())}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.send),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _processSelectedWorkers(selectedWorkersList);
    }
  }

  Future<void> _processSelectedWorkers(List<UserInfo> workers) async {
    final l10n = AppLocalizations.of(context);
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir IDs de string a int para el API
      final userIds = workers.map((worker) => int.tryParse(worker.id) ?? 0).where((id) => id > 0).toList();
      
      if (userIds.isEmpty) {
        throw Exception('No se pudieron procesar los IDs de los usuarios');
      }

      // Llamar al API real
      final result = await _userService.addUsersToStore(
        storeId: int.tryParse(widget.store.id) ?? 0,
        userIds: userIds,
        isPrimary: false, // Por defecto no son usuarios principales
        context: context,
      );

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.workersSentSuccessfully} (${result.totalSuccessful}/${result.totalProcessed})'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Limpiar selección después del envío exitoso
        _clearSelection();
      } else if (result.totalSuccessful > 0) {
        // Éxito parcial
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.workersSentSuccessfully} (${result.totalSuccessful}/${result.totalProcessed}). ${l10n.someErrorsOccurred}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Mostrar errores detallados
        _showDetailedErrors(result.errors, l10n);
        
        // Limpiar selección de los usuarios exitosos
        _clearSelection();
      } else {
        // Error completo
        throw Exception(result.message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorSendingWorkers}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDetailedErrors(List<String> errors, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.errorsOccurred),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errors.map((error) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('• $error'),
              )).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.workersForStore}: ${widget.store.name}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedWorkers.isNotEmpty) ...[
            IconButton(
              onPressed: _clearSelection,
              icon: const Icon(Icons.clear_all),
              tooltip: l10n.clearSelection,
            ),
            IconButton(
              onPressed: _selectAllWorkers,
              icon: const Icon(Icons.select_all),
              tooltip: l10n.selectAll,
            ),
          ],
          IconButton(
            onPressed: _loadWorkers,
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
          // Información de la tienda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    _getStoreIcon(widget.store.type),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.store.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.storeType}: ${_getStoreTypeName(widget.store.type, l10n)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                      if (widget.store.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.address}: ${widget.store.address}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchWorkers,
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
              onChanged: (value) => _onSearchChanged(),
            ),
          ),

          // Información de selección
          if (_selectedWorkers.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.selectedWorkersCount}: ${_selectedWorkers.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendSelectedWorkers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 28),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading) ...[
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ] else ...[
                          const Icon(Icons.send, size: 14),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          l10n.sendSelected,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Filtros activos
          if (_selectedRole != null || _searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_selectedRole != null)
                          Chip(
                            label: Text('${l10n.roles}: ${_getRoleName(_selectedRole!, l10n)}'),
                            onDeleted: () => _onRoleFilterChanged(null),
                          ),
                        if (_searchQuery.isNotEmpty)
                          Chip(
                            label: Text('${l10n.searchUsers}: "$_searchQuery"'),
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
              l10n.errorLoadingUsers,
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
              onPressed: _loadWorkers,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_workers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noWorkersFound,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noWorkersInStore,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectWorkersToSend,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_filteredWorkers.isEmpty) {
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
              l10n.noWorkersWithFilters,
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
      itemCount: _filteredWorkers.length,
      itemBuilder: (context, index) {
        final worker = _filteredWorkers[index];
        final isSelected = _selectedWorkers.contains(worker.id);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 1,
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (bool? value) => _toggleWorkerSelection(worker),
            title: Text(
              '${worker.firstName} ${worker.lastName}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  worker.email,
                  style: TextStyle(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.age}: ${worker.age} ${l10n.years}',
                  style: TextStyle(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.roles}: ${_getRolesText(worker.roles, l10n)}',
                  style: TextStyle(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                        : null,
                  ),
                ),
              ],
            ),
            secondary: CircleAvatar(
              backgroundColor: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary,
              child: Text(
                '${worker.firstName[0]}${worker.lastName[0]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            activeColor: Theme.of(context).colorScheme.primary,
            checkColor: Colors.white,
          ),
        );
      },
    );
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
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: l10n.filterByRole,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(l10n.allRoles),
                  ),
                  DropdownMenuItem<String>(
                    value: 'admin',
                    child: Text(l10n.admin),
                  ),
                  DropdownMenuItem<String>(
                    value: 'vendedor',
                    child: Text(l10n.vendedor),
                  ),
                ],
                onChanged: _onRoleFilterChanged,
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
          ],
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

  String _getRoleName(String role, AppLocalizations l10n) {
    switch (role) {
      case 'admin':
        return l10n.admin;
      case 'vendedor':
        return l10n.vendedor;
      default:
        return role;
    }
  }

  String _getRolesText(List<String> roles, AppLocalizations l10n) {
    return roles.map((role) => _getRoleName(role, l10n)).join(', ');
  }
}
