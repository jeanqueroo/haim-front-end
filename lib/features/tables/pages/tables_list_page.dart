import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/table_service.dart';
import '../../../providers/store_provider.dart';

class TablesListPage extends StatefulWidget {
  const TablesListPage({super.key});

  @override
  State<TablesListPage> createState() => _TablesListPageState();
}

class _TablesListPageState extends State<TablesListPage> {
  final TableService _tableService = TableService();
  
  // Lista de mesas
  List<TableInfo> _allTables = [];
  List<TableInfo> _filteredTables = [];
  bool _isLoading = false;
  
  // Variables para filtro
  String? _selectedStoreId;
  bool _showAllStores = true;
  
  // Variables para edición
  TableInfo? _editingTable;
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  String? _selectedStatus;
  
  // Estados de mesa disponibles
  final List<Map<String, String>> _tableStatuses = [
    {'key': 'free', 'value': 'Libre'},
    {'key': 'occupied', 'value': 'Ocupada'},
    {'key': 'reserved', 'value': 'Reservada'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllTables();
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  // Cargar todas las mesas de todas las tiendas
  Future<void> _loadAllTables() async {
    setState(() {
      _isLoading = true;
      _allTables = [];
      _filteredTables = [];
    });

    try {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final allTables = <TableInfo>[];
      
      // Cargar mesas de todas las tiendas
      for (final store in storeProvider.stores) {
        final tables = await _tableService.getTablesByStore(store.id);
        allTables.addAll(tables);
      }
      
      setState(() {
        _allTables = allTables;
        _filteredTables = allTables;
        _isLoading = false;
        _showAllStores = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar mesas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Aplicar filtro por tienda
  void _applyFilter() {
    setState(() {
      if (_selectedStoreId == null || _selectedStoreId == 'all') {
        _filteredTables = List.from(_allTables);
        _showAllStores = true;
      } else {
        _filteredTables = _allTables.where((table) => table.storeId == _selectedStoreId).toList();
        _showAllStores = false;
      }
    });
  }

  // Iniciar edición de una mesa
  void _startEditingTable(TableInfo table) {
    setState(() {
      _editingTable = table;
      _tableNumberController.text = table.tableNumber.toString();
      _capacityController.text = table.capacity.toString();
      _selectedStatus = table.status;
    });
    _showEditDialog();
  }

  // Mostrar diálogo de edición
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Mesa ${_editingTable?.tableNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tableNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de Mesa',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacidad (personas)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado de la Mesa',
                  border: OutlineInputBorder(),
                ),
                items: _tableStatuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status['key'],
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status['key']!),
                          size: 20,
                          color: _getStatusColor(status['key']!),
                        ),
                        const SizedBox(width: 12),
                        Text(status['value']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'El estado es obligatorio';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelEditing();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _handleEditSubmit,
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  // Manejar envío de edición
  Future<void> _handleEditSubmit() async {
    if (_editingTable == null) return;

    // Validaciones básicas
    if (_tableNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El número de mesa es obligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_capacityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La capacidad es obligatoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tableNumber = int.tryParse(_tableNumberController.text.trim());
    if (tableNumber == null || tableNumber <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El número de mesa debe ser un número válido mayor a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final capacity = int.tryParse(_capacityController.text.trim());
    if (capacity == null || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La capacidad debe ser un número válido mayor a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedStatus == null || _selectedStatus!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El estado es obligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = await _tableService.updateTable(
        tableId: _editingTable!.id,
        tableNumber: tableNumber.toString(),
        capacity: capacity,
        status: _selectedStatus!, // Usar el estado seleccionado
        storeId: _editingTable!.storeId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mesa actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Recargar la lista
          await _loadAllTables();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar mesa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Cancelar edición
  void _cancelEditing() {
    setState(() {
      _editingTable = null;
      _tableNumberController.clear();
      _capacityController.clear();
      _selectedStatus = null;
    });
  }

  // Eliminar una mesa
  Future<void> _deleteTable(TableInfo table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar la mesa ${table.tableNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _tableService.deleteTable(table.id);
      
      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          
          // Recargar la lista de mesas
          await _loadAllTables();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar mesa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Obtener nombre de estado para mostrar
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'free':
        return 'Libre';
      case 'occupied':
        return 'Ocupada';
      case 'reserved':
        return 'Reservada';
      default:
        return status;
    }
  }

  // Obtener icono de estado
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'free':
        return Icons.check_circle_outline;
      case 'occupied':
        return Icons.person;
      case 'reserved':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  // Obtener color de estado
  Color _getStatusColor(String status) {
    switch (status) {
      case 'free':
        return Colors.green;
      case 'occupied':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Mesas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadAllTables,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por tienda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Consumer<StoreProvider>(
              builder: (context, storeProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filtrar por tienda:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStoreId,
                          hint: Text(
                            _showAllStores ? 'Todas las tiendas' : 'Seleccionar tienda',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'all',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.store,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Todas las tiendas'),
                                ],
                              ),
                            ),
                            ...storeProvider.stores.map((store) {
                              return DropdownMenuItem<String>(
                                value: store.id,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.store,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        store.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              _selectedStoreId = value;
                            });
                            _applyFilter();
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Lista de mesas
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredTables.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTables.length,
                        itemBuilder: (context, index) {
                          final table = _filteredTables[index];
                          return _buildTableCard(table);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Construir estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              _showAllStores ? 'No hay mesas registradas' : 'No hay mesas en esta tienda',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _showAllStores 
                  ? 'Las mesas aparecerán aquí cuando se registren'
                  : 'Selecciona otra tienda o registra una nueva mesa',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/register-table');
              },
              icon: const Icon(Icons.add),
              label: const Text('Registrar Mesa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construir tarjeta de mesa
  Widget _buildTableCard(TableInfo table) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(table.status).withOpacity(0.1),
          child: Icon(
            _getStatusIcon(table.status),
            color: _getStatusColor(table.status),
          ),
        ),
        title: Text(
          'Mesa ${table.tableNumber}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capacidad: ${table.capacity} personas'),
            if (table.storeName != null)
              Text(
                'Tienda: ${table.storeName}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            Text(
              _getStatusDisplayName(table.status),
              style: TextStyle(
                color: _getStatusColor(table.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _startEditingTable(table);
            } else if (value == 'delete') {
              _deleteTable(table);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
