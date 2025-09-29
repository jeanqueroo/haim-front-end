import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../services/table_service.dart';
import 'edit_table_page.dart';

class TablesListPage extends StatefulWidget {
  const TablesListPage({super.key});

  @override
  State<TablesListPage> createState() => _TablesListPageState();
}

class _TablesListPageState extends State<TablesListPage> {
  final TableService _tableService = TableService();
  List<TableInfo> _tables = [];
  List<TableInfo> _filteredTables = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros
  String _searchQuery = '';
  String? _selectedStatus;
  String? _selectedStoreId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTables();
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
      _filteredTables = _tables.where((table) {
        // Filtro por búsqueda de texto
        final matchesSearch = _searchQuery.isEmpty ||
            table.tableNumber.toString().contains(_searchQuery) ||
            table.capacity.toString().contains(_searchQuery) ||
            (table.storeName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        // Filtro por estado
        final matchesStatus = _selectedStatus == null ||
            table.status.toLowerCase() == _selectedStatus!.toLowerCase();

        // Filtro por tienda
        final matchesStore = _selectedStoreId == null ||
            table.storeId == _selectedStoreId;

        return matchesSearch && matchesStatus && matchesStore;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = null;
      _selectedStoreId = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  Future<void> _loadTables() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tables = await _tableService.getAllTables();
      setState(() {
        _tables = tables;
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

  Future<void> _deleteTable(String tableId) async {
    try {
      final result = await _tableService.deleteTable(tableId);
      if (result.isSuccess) {
        // Recargar la lista de mesas
        await _loadTables();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mesa eliminada exitosamente'),
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
            content: Text('Error al eliminar mesa: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _navigateToEditTable(TableInfo table) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTablePage(
          tableId: table.id,
          tableInfo: table,
        ),
      ),
    ).then((result) {
      // Recargar la lista si se actualizó la mesa
      if (result == true) {
        _loadTables();
      }
    });
  }

  void _showDeleteConfirmation(String tableId, int tableNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar la mesa #$tableNumber?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTable(tableId);
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filtros'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filtro por estado
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(labelText: 'Estado'),
                    items: [
                      DropdownMenuItem(value: null, child: Text('Todos los estados')),
                      DropdownMenuItem(value: 'available', child: Text('Disponible')),
                      DropdownMenuItem(value: 'occupied', child: Text('Ocupada')),
                      DropdownMenuItem(value: 'reserved', child: Text('Reservada')),
                      DropdownMenuItem(value: 'maintenance', child: Text('Mantenimiento')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                    });
                  },
                  child: Text('Limpiar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  child: Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getStatusName(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'available':
        return l10n.available;
      case 'occupied':
        return l10n.occupied;
      case 'reserved':
        return l10n.reserved;
      case 'maintenance':
        return l10n.maintenance;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'occupied':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      case 'maintenance':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle;
      case 'occupied':
        return Icons.person;
      case 'reserved':
        return Icons.schedule;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.table_restaurant;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSpanish = l10n.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tableList),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadTables,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filters,
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
                hintText: l10n.searchTables,
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
          // Lista de mesas
          Expanded(child: _buildBody(l10n, isSpanish)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register-table').then((_) {
            // Recargar la lista cuando regrese de registrar una mesa
            _loadTables();
          });
        },
        child: const Icon(Icons.add),
        tooltip: l10n.addTable,
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
              onPressed: _loadTables,
              child: Text(isSpanish ? 'Reintentar' : 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredTables.isEmpty) {
      final hasFilters = _searchQuery.isNotEmpty || _selectedStatus != null || _selectedStoreId != null;
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_list_off : Icons.table_restaurant_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters 
                  ? (isSpanish ? 'No se encontraron mesas con los filtros aplicados' : 'No tables found with applied filters')
                  : (isSpanish ? 'No hay mesas registradas' : 'No tables registered'),
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
                isSpanish ? 'Toca el botón + para agregar una mesa' : 'Tap the + button to add a table',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTables,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredTables.length,
        itemBuilder: (context, index) {
          final table = _filteredTables[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(table.status),
                child: Icon(
                  _getStatusIcon(table.status),
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Mesa #${table.tableNumber}',
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
                        Icons.people,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Capacidad: ${table.capacity} personas',
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
                        _getStatusIcon(table.status),
                        size: 16,
                        color: _getStatusColor(table.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Estado: ${_getStatusName(table.status, l10n)}',
                        style: TextStyle(
                          color: _getStatusColor(table.status),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (table.storeName != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          table.storeName!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (table.createdAt != null) ...[
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
                              ? 'Creado: ${_formatDate(table.createdAt!)}'
                              : 'Created: ${_formatDate(table.createdAt!)}',
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
                    _navigateToEditTable(table);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(table.id, table.tableNumber);
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
}
