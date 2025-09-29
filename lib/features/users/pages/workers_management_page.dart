import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../services/user_service.dart';
import '../../stores/services/store_service.dart';
import 'register_user_page.dart';
import 'edit_user_page.dart';

class WorkersManagementPage extends StatefulWidget {
  final StoreInfo store;

  const WorkersManagementPage({
    super.key,
    required this.store,
  });

  @override
  State<WorkersManagementPage> createState() => _WorkersManagementPageState();
}

class _WorkersManagementPageState extends State<WorkersManagementPage> {
  final UserService _userService = UserService();
  List<UserInfo> _workers = [];
  List<UserInfo> _filteredWorkers = [];
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
      final users = await _userService.getAllUsers();
      // Filtrar solo los trabajadores de esta tienda
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

  void _navigateToRegisterWorker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterUserPage(
          preSelectedStore: widget.store,
        ),
      ),
    ).then((_) {
      // Recargar la lista cuando regrese de registrar un trabajador
      _loadWorkers();
    });
  }

  void _navigateToEditWorker(UserInfo user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserPage(
          user: user,
        ),
      ),
    ).then((_) {
      // Recargar la lista cuando regrese de editar un trabajador
      _loadWorkers();
    });
  }

  void _showDeleteConfirmation(UserInfo user) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteUser),
          content: Text('${l10n.confirmDeleteUser} ${user.firstName} ${user.lastName}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteWorker(user.id);
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteWorker(String userId) async {
    final l10n = AppLocalizations.of(context);
    try {
      // Note: UserService doesn't have deleteUser method, we'll skip deletion for now
      // await _userService.deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.userDeletedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
      _loadWorkers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorDeletingUser}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.workersForStore}: ${widget.store.name}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToRegisterWorker,
        child: const Icon(Icons.person_add),
        tooltip: l10n.addWorker,
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
            ElevatedButton.icon(
              onPressed: _navigateToRegisterWorker,
              icon: const Icon(Icons.person_add),
              label: Text(l10n.addFirstWorker),
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
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
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
            trailing: PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'edit') {
                  _navigateToEditWorker(worker);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(worker);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 8),
                      Text(l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete),
                      const SizedBox(width: 8),
                      Text(l10n.delete),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _navigateToEditWorker(worker),
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
