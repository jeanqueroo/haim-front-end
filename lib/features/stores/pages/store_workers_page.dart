import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../users/services/user_service.dart';
import '../services/store_service.dart';
import '../../../widgets/country_dropdown_form_field.dart';
import '../../../providers/store_provider.dart';

class StoreWorkersPage extends StatefulWidget {
  const StoreWorkersPage({super.key});

  @override
  State<StoreWorkersPage> createState() => _StoreWorkersPageState();
}

class _StoreWorkersPageState extends State<StoreWorkersPage> {
  final UserService _userService = UserService();
  List<UserInfo> _allUsers = []; // Todos los usuarios disponibles
  List<UserInfo> _searchResults = []; // Resultados de búsqueda
  List<UserInfo> _selectedWorkers = []; // Usuarios seleccionados para enviar
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
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final selectedStore = storeProvider.selectedStore;

    if (selectedStore == null) {
      setState(() {
        _errorMessage = 'No hay tienda seleccionada';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Cargar todos los usuarios disponibles para búsqueda
      final allUsers = await _userService.getAllUsers(context: context);
      
      // Cargar usuarios existentes de la tienda
      final storeId = int.tryParse(selectedStore.id) ?? 0;
      List<UserInfo> existingStoreUsers = [];
      
      if (storeId > 0) {
        existingStoreUsers = await _userService.getStoreUsers(storeId, context: context);
      }
      
      // Filtrar solo los trabajadores disponibles para agregar
      final availableWorkers = allUsers.where((user) => 
        user.roles.contains('waiter') || user.roles.contains('chef') || user.roles.contains('vendedor') || user.roles.contains('admin')
      ).toList();
      
      setState(() {
        _allUsers = availableWorkers;
        _selectedWorkers = existingStoreUsers; // Cargar usuarios existentes como seleccionados
        _searchResults = [];
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
      _performSearch();
    });
  }

  void _onRoleFilterChanged(String? role) {
    setState(() {
      _selectedRole = role;
      _performSearch();
    });
  }

  void _performSearch() {
    List<UserInfo> filtered = _allUsers;

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

    // Excluir usuarios ya seleccionados
    final selectedIds = _selectedWorkers.map((user) => user.id).toSet();
    filtered = filtered.where((user) => !selectedIds.contains(user.id)).toList();

    setState(() {
      _searchResults = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedRole = null;
      _searchController.clear();
      _searchResults = [];
    });
  }

  Future<void> _addWorker(UserInfo worker) async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final selectedStore = storeProvider.selectedStore;

    if (selectedStore == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storeId = int.tryParse(selectedStore.id) ?? 0;
      if (storeId == 0) {
        throw Exception('ID de tienda inválido');
      }

      final userId = int.tryParse(worker.id) ?? 0;
      if (userId == 0) {
        throw Exception('ID de usuario inválido');
      }

      // Llamar al API para agregar el usuario individualmente
      final result = await _userService.addUserToStore(
        storeId: storeId,
        userId: userId,
        isPrimary: false,
        context: context,
      );

      if (result.isSuccess) {
        // Agregar a la lista de seleccionados solo si fue exitoso
        setState(() {
          _selectedWorkers.add(worker);
          _performSearch(); // Actualizar resultados de búsqueda
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${worker.firstName} ${worker.lastName} agregado a la tienda'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Mostrar error si falló
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al agregar ${worker.firstName} ${worker.lastName}: ${result.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al agregar usuario: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeWorker(UserInfo worker) async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final selectedStore = storeProvider.selectedStore;

    if (selectedStore == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storeId = int.tryParse(selectedStore.id) ?? 0;
      if (storeId == 0) {
        throw Exception('ID de tienda inválido');
      }

      final userId = int.tryParse(worker.id) ?? 0;
      if (userId == 0) {
        throw Exception('ID de usuario inválido');
      }

      // Llamar al API para eliminar el usuario de la tienda
      final result = await _userService.removeUserFromStore(
        storeId: storeId,
        userId: userId,
        context: context,
      );

      if (result.isSuccess) {
        // Remover de la lista de seleccionados solo si fue exitoso
        setState(() {
          _selectedWorkers.remove(worker);
          _performSearch(); // Actualizar resultados de búsqueda
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${worker.firstName} ${worker.lastName} eliminado de la tienda'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Mostrar error si falló
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar ${worker.firstName} ${worker.lastName}: ${result.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al eliminar usuario: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearSelection() async {
    if (_selectedWorkers.isEmpty) return;

    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final selectedStore = storeProvider.selectedStore;

    if (selectedStore == null) return;

    // Mostrar confirmación antes de eliminar todos
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar todos los usuarios'),
          content: Text('¿Estás seguro de que quieres eliminar ${_selectedWorkers.length} usuario(s) de la tienda?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar todos'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final storeId = int.tryParse(selectedStore.id) ?? 0;
        if (storeId == 0) {
          throw Exception('ID de tienda inválido');
        }

        // Eliminar cada usuario individualmente
        int successCount = 0;
        int errorCount = 0;
        final errors = <String>[];

        for (final worker in _selectedWorkers) {
          final userId = int.tryParse(worker.id) ?? 0;
          if (userId > 0) {
            final result = await _userService.removeUserFromStore(
              storeId: storeId,
              userId: userId,
              context: context,
            );

            if (result.isSuccess) {
              successCount++;
            } else {
              errorCount++;
              errors.add('${worker.firstName} ${worker.lastName}: ${result.message}');
            }
          }
        }

        // Limpiar la lista local
    setState(() {
      _selectedWorkers.clear();
          _performSearch();
        });

        // Mostrar resultado
        if (errorCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $successCount usuario(s) eliminado(s) exitosamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (successCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ $successCount eliminado(s), $errorCount error(es)'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
          
          // Mostrar errores detallados
          if (errors.isNotEmpty) {
            _showDetailedErrors(errors, AppLocalizations.of(context));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ No se pudo eliminar ningún usuario'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar usuarios: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    final selectedWorkersList = _selectedWorkers;

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
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final selectedStore = storeProvider.selectedStore;

    if (selectedStore == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir IDs de string a int para el API
      final userIds = workers.map((worker) => int.tryParse(worker.id) ?? 0).where((id) => id > 0).toList();
      
      if (userIds.isEmpty) {
        throw Exception('No se pudieron procesar los IDs de los usuarios');
      }

      final storeId = int.tryParse(selectedStore.id) ?? 0;
      if (storeId == 0) {
        throw Exception('ID de tienda inválido');
      }

      // Llamar al API real
      final result = await _userService.addUsersToStore(
        storeId: storeId,
        userIds: userIds,
        isPrimary: false, // Por defecto no son usuarios principales
        context: context,
      );

      if (result.isSuccess) {
        // Éxito completo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${result.totalSuccessful} trabajador(es) agregado(s) exitosamente a la tienda'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Limpiar selección después del envío exitoso
        _clearSelection();
      } else if (result.totalSuccessful > 0) {
        // Éxito parcial
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${result.totalSuccessful}/${result.totalProcessed} trabajadores agregados. Algunos errores ocurrieron.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${result.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al enviar trabajadores: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
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

    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final selectedStore = storeProvider.selectedStore;
        
        if (selectedStore == null) {
    return Scaffold(
      appBar: AppBar(
              title: Text('${l10n.workersForStore} - Sin Tienda'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay tienda seleccionada',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona una tienda para gestionar los trabajadores',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => storeProvider.showStoreSelector(context),
                    icon: const Icon(Icons.store),
                    label: const Text('Seleccionar Tienda'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.workersForStore}'),
                Text(
                  selectedStore.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedWorkers.isNotEmpty) ...[
            IconButton(
              onPressed: _clearSelection,
              icon: const Icon(Icons.clear_all),
              tooltip: l10n.clearSelection,
            ),
          ],
            IconButton(
            onPressed: _showRegisterUserDialog,
            icon: const Icon(Icons.person_add),
            tooltip: 'Register New User',
          ),
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
                    _getStoreIcon(selectedStore.type),
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
                        selectedStore.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.storeType}: ${_getStoreTypeName(selectedStore.type, l10n)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                      if (selectedStore.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.address}: ${selectedStore.address}',
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

          // Lista de usuarios seleccionados
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                          'Trabajadores de la tienda: ${_selectedWorkers.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                        Text(
                          'Usuarios existentes en la tienda',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Lista de usuarios seleccionados
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedWorkers.map((worker) => Chip(
                      label: Text('${worker.firstName} ${worker.lastName}'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeWorker(worker),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    )).toList(),
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

          // Título de resultados de búsqueda
          if (_searchQuery.isNotEmpty || _selectedRole != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search Results',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${_searchResults.length})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRegisterUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
        );
      },
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final selectedStore = storeProvider.selectedStore;
        
        if (selectedStore == null) {
          return const SizedBox.shrink();
        }

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

    if (_allUsers.isEmpty) {
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

    // Si no hay búsqueda activa, mostrar mensaje para buscar
    if (_searchQuery.isEmpty && _selectedRole == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Search Workers to Add',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Usa la barra de búsqueda para encontrar trabajadores y agregarlos a la tienda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Si hay búsqueda pero no hay resultados
    if (_searchResults.isEmpty) {
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

    // Mostrar resultados de búsqueda
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final worker = _searchResults[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                '${worker.firstName[0]}${worker.lastName[0]}',
                style: const TextStyle(
                  color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
            title: Text(
              '${worker.firstName} ${worker.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(worker.email),
                const SizedBox(height: 2),
                Text('${l10n.age}: ${worker.age} ${l10n.years}'),
                const SizedBox(height: 2),
                Text('${l10n.roles}: ${_getRolesText(worker.roles, l10n)}'),
              ],
            ),
            trailing: ElevatedButton.icon(
              onPressed: () => _addWorker(worker),
              icon: const Icon(Icons.add, size: 16),
              label: Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 32),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      },
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

  void _showRegisterUserDialog() {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final selectedStore = storeProvider.selectedStore;

    if (selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una tienda primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _RegisterUserDialog(
          onUserRegistered: (UserInfo newUser) {
            // Agregar el nuevo usuario a la lista de usuarios disponibles
            setState(() {
              _allUsers.add(newUser);
              // Agregar automáticamente a la lista de usuarios seleccionados
              _selectedWorkers.add(newUser);
              _performSearch(); // Actualizar resultados de búsqueda
            });
            
            // Mostrar confirmación adicional
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${newUser.firstName} ${newUser.lastName} has been added to the selected workers list'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          },
          store: selectedStore,
        );
      },
    );
  }
}

class _RegisterUserDialog extends StatefulWidget {
  final Function(UserInfo) onUserRegistered;
  final StoreInfo store;

  const _RegisterUserDialog({
    required this.onUserRegistered,
    required this.store,
  });

  @override
  State<_RegisterUserDialog> createState() => _RegisterUserDialogState();
}

class _RegisterUserDialogState extends State<_RegisterUserDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _gender;
  String _selectedCountry = 'spain';
  final List<String> _selectedRoles = <String>[];
  bool _isSubmitting = false;

  // Solo permitir roles de waiter y chef
  final List<String> _allowedRoles = ['waiter', 'chef'];

  InputDecoration _getInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void cleanUser() {
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _ageController.clear();
    _emailController.clear();
    _passwordController.clear();
    _gender = null;
    _selectedRoles.clear();
    _selectedCountry = 'spain';
    _isSubmitting = false;
    _formKey.currentState?.reset();
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleSubmit() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;
    
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender')),
      );
      return;
    }
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one role')),
      );
      return;
    }

    setState(() { _isSubmitting = true; });
    try {
      // Map country key to full country name for server
      String countryForServer;
      switch (_selectedCountry) {
        case 'spain':
          countryForServer = 'España';
          break;
        case 'unitedStates':
          countryForServer = 'Estados Unidos';
          break;
        default:
          countryForServer = 'España';
      }
      
      final result = await _userService.registerUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        country: countryForServer,
        age: int.parse(_ageController.text.trim()),
        gender: _gender!,
        roles: _selectedRoles.toList(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (result.isSuccess) {
        // Crear objeto UserInfo del nuevo usuario
        final newUser = UserInfo(
          id: result.userId ?? '',
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          country: countryForServer,
          age: int.parse(_ageController.text.trim()),
          gender: _gender!,
          roles: _selectedRoles.toList(),
        );
        
        // Asignar automáticamente el usuario a la tienda
        final storeId = int.tryParse(widget.store.id) ?? 0;
        if (storeId > 0) {
          final userId = int.tryParse(newUser.id) ?? 0;
          if (userId > 0) {
            try {
              final assignmentResult = await _userService.addUserToStore(
                storeId: storeId,
                userId: userId,
                isPrimary: false,
                context: context,
              );
              
              if (assignmentResult.isSuccess) {
                // Agregar el usuario a la lista solo si la asignación fue exitosa
                widget.onUserRegistered(newUser);
                
                // Mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${result.message} - Usuario agregado automáticamente a la tienda'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else {
                // Mostrar error de asignación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuario registrado pero error al asignar a la tienda: ${assignmentResult.message}'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 4),
                  ),
                );
                
                // Agregar el usuario a la lista de todos modos para que pueda ser asignado manualmente
                widget.onUserRegistered(newUser);
              }
            } catch (e) {
              // Mostrar error de asignación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Usuario registrado pero error al asignar a la tienda: $e'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
              
              // Agregar el usuario a la lista de todos modos para que pueda ser asignado manualmente
              widget.onUserRegistered(newUser);
            }
          } else {
            // Error con el ID del usuario
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario registrado pero ID inválido para asignación'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
            
            // Agregar el usuario a la lista de todos modos
            widget.onUserRegistered(newUser);
          }
        } else {
          // Error con el ID de la tienda
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario registrado pero ID de tienda inválido para asignación'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          
          // Agregar el usuario a la lista de todos modos
          widget.onUserRegistered(newUser);
        }
        
        // Limpiar los campos del formulario
        cleanUser();
        
        // Cerrar el diálogo
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Register New User',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        width: 400,
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: _getInputDecoration('First Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: _getInputDecoration('Last Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: _getInputDecoration('Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Password
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: _getInputDecoration('Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Address
                TextFormField(
                  controller: _addressController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: _getInputDecoration('Address'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Country
                CountryDropdownFormField(
                  value: _selectedCountry,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCountry = newValue ?? 'spain';
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Age
                TextFormField(
                  controller: _ageController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: _getInputDecoration('Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Age is required';
                    }
                    final age = int.tryParse(value.trim());
                    if (age == null || age <= 0) {
                      return 'Age must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Gender
                DropdownButtonFormField<String>(
                  value: _gender,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: _getInputDecoration('Gender'),
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Male')),
                    DropdownMenuItem(value: 'F', child: Text('Female')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _gender = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Roles
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roles:', 
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _allowedRoles.map((role) {
                        final isSelected = _selectedRoles.contains(role);
                        return FilterChip(
                          label: Text(
                            role.toUpperCase(),
                            style: TextStyle(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedRoles.add(role);
                              } else {
                                _selectedRoles.remove(role);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSubmitting 
                ? Theme.of(context).colorScheme.surfaceVariant
                : Theme.of(context).colorScheme.primary,
            foregroundColor: _isSubmitting
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onPrimary,
            elevation: _isSubmitting ? 0 : 2,
          ),
          child: _isSubmitting
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Saving...'),
                  ],
                )
              : const Text('Register'),
        ),
      ],
    );
  }
}
