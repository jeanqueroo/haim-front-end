import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/table_service.dart';
import '../../../providers/store_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class RegisterTablePage extends StatefulWidget {
  const RegisterTablePage({super.key});

  @override
  State<RegisterTablePage> createState() => _RegisterTablePageState();
}

class _RegisterTablePageState extends State<RegisterTablePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TableService _tableService = TableService();

  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  
  bool _isSubmitting = false;
  // El estado siempre será 'free' para nuevas mesas
  static const String _defaultStatus = 'free';
  
  // Lista de mesas existentes
  List<TableInfo> _existingTables = [];
  bool _isLoadingTables = false;
  String? _lastLoadedStoreId;
  
  // Variables para edición
  TableInfo? _editingTable;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // El estado siempre será 'free' para nuevas mesas
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }


  void _clearForm() {
    _tableNumberController.clear();
    _capacityController.clear();
    _isSubmitting = false;
    _formKey.currentState?.reset();
    FocusScope.of(context).unfocus();
  }

  // Limpiar lista de mesas cuando se cambie de tienda
  void _clearTablesList() {
    setState(() {
      _existingTables = [];
      _lastLoadedStoreId = null;
    });
  }

  // Iniciar edición de una mesa
  void _startEditingTable(TableInfo table) {
    setState(() {
      _editingTable = table;
      _isEditing = true;
      _tableNumberController.text = table.tableNumber.toString();
      _capacityController.text = table.capacity.toString();
    });
  }

  // Cancelar edición
  void _cancelEditing() {
    setState(() {
      _editingTable = null;
      _isEditing = false;
      _tableNumberController.clear();
      _capacityController.clear();
    });
  }

  // Cargar mesas existentes de la tienda
  Future<void> _loadExistingTables(String storeId) async {
    setState(() {
      _isLoadingTables = true;
      _existingTables = []; // Limpiar lista mientras carga
    });

    try {
      final tables = await _tableService.getTablesByStore(storeId);
      setState(() {
        _existingTables = tables;
        _isLoadingTables = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTables = false;
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
          final storeProvider = Provider.of<StoreProvider>(context, listen: false);
          if (storeProvider.selectedStore != null) {
            await _loadExistingTables(storeProvider.selectedStore!.id);
          }
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

  Future<void> _handleSubmit() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;

    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final selectedStore = storeProvider.selectedStore;

    // Validar que se haya seleccionado una tienda
    if (selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una tienda desde el selector superior'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('${_isEditing ? 'Editando' : 'Registrando'} mesa: ${_tableNumberController.text}, Capacidad: ${_capacityController.text}, Tienda: ${selectedStore.id}');
    
    setState(() { _isSubmitting = true; });
    
    try {
      final TableRegistrationResult result;
      
      if (_isEditing && _editingTable != null) {
        // Editar mesa existente
        result = await _tableService.updateTable(
          tableId: _editingTable!.id,
          tableNumber: _tableNumberController.text.trim(),
          capacity: int.parse(_capacityController.text.trim()),
          status: _editingTable!.status, // Mantener el estado actual
          storeId: selectedStore.id,
        );
      } else {
        // Registrar nueva mesa
        result = await _tableService.registerTable(
          tableNumber: _tableNumberController.text.trim(),
          capacity: int.parse(_capacityController.text.trim()),
          status: _defaultStatus, // Siempre 'free' para nuevas mesas
          storeId: selectedStore.id,
        );
      }

      if (!mounted) return;

      print('Resultado del registro: ${result.isSuccess}, Mensaje: ${result.message}');
      
      if (result.isSuccess) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.message} - Mesa ${_tableNumberController.text} ${_isEditing ? 'actualizada' : 'registrada'} exitosamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Limpiar los campos del formulario
        if (_isEditing) {
          _cancelEditing();
        } else {
          _clearForm();
        }
        
        // Recargar la lista de mesas
        print('Recargando lista de mesas...');
        await _loadExistingTables(selectedStore.id);
      } else {
        print('Error en el registro: ${result.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Excepción al registrar mesa: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar mesa: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
    }
  }

  InputDecoration _getInputDecoration(String labelText, {String? hintText, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final selectedStore = storeProvider.selectedStore;
        
        // Limpiar lista si no hay tienda seleccionada
        if (selectedStore == null && _lastLoadedStoreId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _clearTablesList();
          });
        }
        
        // Si no hay tienda seleccionada, mostrar pantalla de selección
        if (selectedStore == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Seleccionar Tienda'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: _buildStoreSelectionBody(context, storeProvider),
          );
        }

        // Si hay tienda seleccionada, mostrar formulario de registro
        // Cargar mesas cuando se selecciona una tienda diferente
        if (selectedStore.id != _lastLoadedStoreId && !_isLoadingTables) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadExistingTables(selectedStore.id);
            _lastLoadedStoreId = selectedStore.id;
          });
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Registrar Mesa'),
                const SizedBox(height: 2),
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
              IconButton(
                onPressed: () {
                  // Limpiar tienda seleccionada para volver a la selección
                  storeProvider.clearStore();
                },
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Cambiar Tienda',
              ),
              IconButton(
                onPressed: _clearForm,
                icon: const Icon(Icons.clear),
                tooltip: 'Limpiar formulario',
              ),
            ],
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de tienda
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.store,
                      size: 48,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      storeProvider.selectedStore?.name ?? 'Seleccionar Tienda',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      storeProvider.selectedStore != null 
                          ? 'Registrar nueva mesa para esta tienda'
                          : 'Selecciona una tienda para registrar la mesa',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => storeProvider.showStoreSelector(context),
                      icon: const Icon(Icons.store),
                      label: Text(storeProvider.selectedStore != null ? 'Cambiar Tienda' : 'Seleccionar Tienda'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              // Lista de mesas existentes
              _buildExistingTablesSection(),

              const SizedBox(height: 32),

              // Título del formulario
              Text(
                _isEditing ? 'Editar Mesa' : 'Información de la Mesa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 24),


                  // Campo: Número de mesa
                  TextFormField(
                    controller: _tableNumberController,
                    keyboardType: TextInputType.number,
                decoration: _getInputDecoration(
                  'Número de Mesa',
                  hintText: 'Ej: 1, 2, 3...',
                  prefixIcon: Icons.table_restaurant_outlined,
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                  if (input.isEmpty) return 'El número de mesa es obligatorio';
                      
                      final number = int.tryParse(input);
                  if (number == null) return 'El número de mesa debe ser un número válido';
                  if (number <= 0) return 'El número de mesa debe ser mayor a 0';
                      
                      return null;
                    },
                  ),
              const SizedBox(height: 20),

                  // Campo: Capacidad
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                decoration: _getInputDecoration(
                  'Capacidad (personas)',
                  hintText: 'Ej: 2, 4, 6...',
                  prefixIcon: Icons.people_outline,
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                  if (input.isEmpty) return 'La capacidad es obligatoria';
                  
                  final number = int.tryParse(input);
                  if (number == null) return 'La capacidad debe ser un número válido';
                  if (number <= 0) return 'La capacidad debe ser mayor a 0';
                  if (number > 20) return 'La capacidad no puede ser mayor a 20';
                      
                      return null;
                    },
                  ),
              const SizedBox(height: 20),

              // Campo: Estado (Solo lectura)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado de la Mesa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            _isEditing ? _getStatusIcon(_editingTable!.status) : _getStatusIcon('free'),
                            size: 20,
                            color: _isEditing ? _getStatusColor(_editingTable!.status) : _getStatusColor('free'),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isEditing ? _getStatusDisplayName(_editingTable!.status) : 'Libre',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEditing 
                        ? 'El estado actual de la mesa no se puede modificar'
                        : 'El estado se establece automáticamente como "Libre" para nuevas mesas',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // Botones de acción
              Row(
                children: [
                  if (_isEditing) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _cancelEditing,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _clearForm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Limpiar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Registrando...'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _isEditing ? 'Actualizar Mesa' : 'Registrar Mesa',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  // Método para construir la pantalla de selección de tienda
  Widget _buildStoreSelectionBody(BuildContext context, StoreProvider storeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Selecciona una Tienda',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Elige la tienda donde quieres registrar la nueva mesa',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton.icon(
                  onPressed: () async {
                    // Recargar tiendas con el contexto de autenticación actual
                    await storeProvider.loadStores(authProvider: authProvider);
                    await storeProvider.showStoreSelector(context);
                  },
                  icon: const Icon(Icons.store),
                  label: const Text('Seleccionar Tienda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Después de seleccionar la tienda, podrás registrar la nueva mesa',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Construir la sección de mesas existentes
  Widget _buildExistingTablesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.table_restaurant,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Mesas Registradas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (_isLoadingTables)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                onPressed: () {
                  final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                  if (storeProvider.selectedStore != null) {
                    _loadExistingTables(storeProvider.selectedStore!.id);
                  }
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar lista',
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_isLoadingTables)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_existingTables.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.table_restaurant_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No hay mesas registradas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Las mesas que registres aparecerán aquí',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _existingTables.length,
            itemBuilder: (context, index) {
              final table = _existingTables[index];
              return _buildTableCard(table);
            },
          ),
      ],
    );
  }

  // Construir tarjeta de mesa individual
  Widget _buildTableCard(TableInfo table) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
}