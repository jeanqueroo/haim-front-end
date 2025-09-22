import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'register_user_page.dart';
import '../../../l10n/app_localizations.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserInfo> _users = [];
  List<UserInfo> _filteredUsers = [];
  bool _isLoading = true;
  String _selectedRole = 'all';
  String _searchQuery = '';

  final List<String> _roles = ['all', 'admin', 'vendedor', 'user'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorLoadingUsers}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = _searchQuery.isEmpty ||
            user.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesRole = _selectedRole == 'all' ||
            user.roles.contains(_selectedRole);
        
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterUsers();
  }

  void _onRoleChanged(String? role) {
    setState(() {
      _selectedRole = role ?? 'all';
    });
    _filterUsers();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registeredUsers),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchUsers,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                
                // Filtro por rol
                Row(
                  children: [
                    Text(
                      l10n.filterByRole,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _roles.map((role) {
                          String displayName;
                          switch (role) {
                            case 'all':
                              displayName = l10n.allRoles;
                              break;
                            case 'admin':
                              displayName = l10n.admin;
                              break;
                            case 'vendedor':
                              displayName = l10n.vendedor;
                              break;
                            case 'user':
                              displayName = l10n.user;
                              break;
                            default:
                              displayName = role;
                          }
                          return DropdownMenuItem(
                            value: role,
                            child: Text(displayName),
                          );
                        }).toList(),
                        onChanged: _onRoleChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de usuarios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
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
                              _searchQuery.isNotEmpty || _selectedRole != 'all'
                                  ? l10n.noUsersFound
                                  : l10n.noUsersRegistered,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchQuery.isNotEmpty || _selectedRole != 'all') ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                  _onRoleChanged('all');
                                },
                                child: Text(l10n.clearFilters),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserCard(user, l10n);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const RegisterUserPage(),
            ),
          ).then((_) {
            // Recargar la lista cuando regrese de registrar usuario
            _loadUsers();
          });
        },
        child: const Icon(Icons.person_add),
        tooltip: l10n.registerUser,
      ),
    );
  }

  Widget _buildUserCard(UserInfo user, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y email
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // Aquí puedes agregar acciones como editar, eliminar, etc.
                    if (value == 'view') {
                      _showUserDetails(user, l10n);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          const Icon(Icons.visibility),
                          const SizedBox(width: 8),
                          Text(l10n.viewDetails),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Información adicional
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.location_on,
                    user.address,
                    l10n.address,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    Icons.flag,
                    user.country,
                    l10n.country,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.cake,
                    '${user.age} ${l10n.years}',
                    l10n.age,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    user.gender == 'M' ? Icons.male : user.gender == 'F' ? Icons.female : Icons.person,
                    user.gender == 'M' ? l10n.male : user.gender == 'F' ? l10n.female : l10n.other,
                    l10n.gender,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Roles
            Wrap(
              spacing: 8,
              children: user.roles.map((role) {
                String roleText;
                Color roleColor;
                switch (role) {
                  case 'admin':
                    roleText = l10n.admin;
                    roleColor = Colors.red;
                    break;
                  case 'vendedor':
                    roleText = l10n.vendedor;
                    roleColor = Colors.blue;
                    break;
                  case 'user':
                    roleText = l10n.user;
                    roleColor = Colors.green;
                    break;
                  default:
                    roleText = role;
                    roleColor = Colors.grey;
                }
                
                return Chip(
                  label: Text(
                    roleText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: roleColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(UserInfo user, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.firstName} ${user.lastName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(l10n.email, user.email),
              _buildDetailRow(l10n.address, user.address),
              _buildDetailRow(l10n.country, user.country),
              _buildDetailRow(l10n.age, '${user.age} ${l10n.years}'),
              _buildDetailRow(
                l10n.gender,
                user.gender == 'M' ? l10n.male : user.gender == 'F' ? l10n.female : l10n.other,
              ),
              _buildDetailRow(l10n.roles, user.roles.join(', ')),
              if (user.createdAt != null)
                _buildDetailRow(l10n.registeredDate, _formatDate(user.createdAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
