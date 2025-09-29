import 'package:flutter/material.dart';
import '../../../features/stores/services/store_service.dart';
import '../../../l10n/app_localizations.dart';
import '../services/table_service.dart';

class EditTablePage extends StatefulWidget {
  final String tableId;
  final TableInfo tableInfo;

  const EditTablePage({
    super.key,
    required this.tableId,
    required this.tableInfo,
  });

  @override
  State<EditTablePage> createState() => _EditTablePageState();
}

class _EditTablePageState extends State<EditTablePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final StoreService _storeService = StoreService();
  final TableService _tableService = TableService();
  String? _selectedStatus;
  String? _selectedStoreId;
  List<StoreInfo> _stores = [];
  List<StoreInfo> _filteredStores = [];
  bool _isSubmitting = false;
  bool _isLoadingStores = false;
  final TextEditingController _storeSearchController = TextEditingController();

  // Lista de estados de mesa con localización
  List<Map<String, String>> _getTableStatuses(AppLocalizations l10n) {
    final isSpanish = l10n.locale.languageCode == 'es';
    
    return [
      {'key': 'available', 'value': isSpanish ? 'Disponible' : 'Available'},
      {'key': 'occupied', 'value': isSpanish ? 'Ocupada' : 'Occupied'},
      {'key': 'reserved', 'value': isSpanish ? 'Reservada' : 'Reserved'},
      {'key': 'maintenance', 'value': isSpanish ? 'Mantenimiento' : 'Maintenance'},
    ];
  }

  // Obtener etiquetas localizadas
  Map<String, String> _getLocalizedLabels(AppLocalizations l10n) {
    final isSpanish = l10n.locale.languageCode == 'es';
    
    return {
      'tableNumber': isSpanish ? 'Número de mesa' : 'Table Number',
      'tableNumberHint': isSpanish ? 'Ej: 1, 2, 3...' : 'Ex: 1, 2, 3...',
      'capacity': isSpanish ? 'Capacidad' : 'Capacity',
      'capacityHint': isSpanish ? 'Ej: 4, 6, 8...' : 'Ex: 4, 6, 8...',
      'status': isSpanish ? 'Estado de la mesa' : 'Table Status',
      'selectStatus': isSpanish ? 'Selecciona un estado' : 'Select a status',
      'store': isSpanish ? 'Tienda' : 'Store',
      'searchStore': isSpanish ? 'Buscar y seleccionar tienda' : 'Search and select store',
      'updateTable': isSpanish ? 'Actualizar Mesa' : 'Update Table',
      'updating': isSpanish ? 'Actualizando...' : 'Updating...',
      'resetForm': isSpanish ? 'Restaurar valores originales' : 'Reset to original values',
    };
  }

  @override
  void initState() {
    super.initState();
    _loadStores();
    _loadTableData();
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _capacityController.dispose();
    _storeSearchController.dispose();
    super.dispose();
  }

  void _loadTableData() {
    // Cargar los datos de la mesa en el formulario
    _tableNumberController.text = widget.tableInfo.tableNumber.toString();
    _capacityController.text = widget.tableInfo.capacity.toString();
    
    // Validar que el estado de la mesa sea válido usando estados predefinidos
    final validStatusKeys = ['available', 'occupied', 'reserved', 'maintenance'];
    
    if (validStatusKeys.contains(widget.tableInfo.status)) {
      _selectedStatus = widget.tableInfo.status;
    } else {
      // Si el estado no es válido, usar 'available' como fallback
      _selectedStatus = 'available';
    }
    
    _selectedStoreId = widget.tableInfo.storeId;
    
    // Buscar la tienda responsable para mostrarla en el campo de búsqueda
    if (_selectedStoreId != null && _stores.isNotEmpty) {
      final store = _stores.firstWhere(
        (s) => s.id == _selectedStoreId,
        orElse: () => StoreInfo(
          id: '',
          name: 'Tienda Desconocida',
          type: '',
          address: '',
          country: '',
          phone: '',
          responsibleUserId: '',
        ),
      );
      _storeSearchController.text = '${store.name} - ${store.address}';
    }
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoadingStores = true;
    });

    try {
      final stores = await _storeService.getAllStores();
      setState(() {
        _stores = stores;
        _filteredStores = stores;
        _isLoadingStores = false;
      });
      
      // Cargar datos de la mesa después de cargar tiendas
      _loadTableData();
    } catch (e) {
      setState(() {
        _isLoadingStores = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tiendas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterStores(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStores = _stores;
      } else {
        _filteredStores = _stores.where((store) {
          final storeName = store.name.toLowerCase();
          final searchQuery = query.toLowerCase();
          return storeName.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _clearStoreSelection() {
    setState(() {
      _selectedStoreId = null;
      _storeSearchController.clear();
      _filteredStores = _stores;
    });
  }

  Future<void> _handleUpdate() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Llamar al servicio para actualizar la mesa
      final result = await _tableService.updateTable(
        tableId: widget.tableId,
        tableNumber: _tableNumberController.text,
        capacity: int.parse(_capacityController.text),
        status: _selectedStatus!,
        storeId: _selectedStoreId!,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      if (result.isSuccess) {
        // Obtener información de la tienda seleccionada para el mensaje
        final selectedStore = _stores.firstWhere(
          (store) => store.id == _selectedStoreId,
          orElse: () => StoreInfo(
            id: '',
            name: 'Tienda Desconocida',
            type: '',
            address: '',
            country: '',
            phone: '',
            responsibleUserId: '',
          ),
        );

        // Obtener información del estado seleccionado
        final l10n = AppLocalizations.of(context);
        String selectedStatusName;
        switch (_selectedStatus) {
          case 'available':
            selectedStatusName = l10n.locale.languageCode == 'es' ? 'Disponible' : 'Available';
            break;
          case 'occupied':
            selectedStatusName = l10n.locale.languageCode == 'es' ? 'Ocupada' : 'Occupied';
            break;
          case 'reserved':
            selectedStatusName = l10n.locale.languageCode == 'es' ? 'Reservada' : 'Reserved';
            break;
          case 'maintenance':
            selectedStatusName = l10n.locale.languageCode == 'es' ? 'Mantenimiento' : 'Maintenance';
            break;
          default:
            selectedStatusName = _selectedStatus ?? 'Estado no seleccionado';
        }

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.message}\nMesa #${_tableNumberController.text}\nCapacidad: ${_capacityController.text} personas\nEstado: $selectedStatusName\nTienda: ${selectedStore.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Regresar a la página anterior
        Navigator.pop(context, true);
      } else {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      // Mostrar mensaje de error inesperado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _resetToOriginal() {
    // Restaurar los valores originales de la mesa
    _tableNumberController.text = widget.tableInfo.tableNumber.toString();
    _capacityController.text = widget.tableInfo.capacity.toString();
    
    // Validar que el estado de la mesa sea válido usando estados predefinidos
    final validStatusKeys = ['available', 'occupied', 'reserved', 'maintenance'];
    
    setState(() {
      if (validStatusKeys.contains(widget.tableInfo.status)) {
        _selectedStatus = widget.tableInfo.status;
      } else {
        _selectedStatus = 'available';
      }
      _selectedStoreId = widget.tableInfo.storeId;
    });
    
    // Restaurar la tienda responsable en el campo de búsqueda
    if (_selectedStoreId != null && _stores.isNotEmpty) {
      final store = _stores.firstWhere(
        (s) => s.id == _selectedStoreId,
        orElse: () => StoreInfo(
          id: '',
          name: 'Tienda Desconocida',
          type: '',
          address: '',
          country: '',
          phone: '',
          responsibleUserId: '',
        ),
      );
      _storeSearchController.text = '${store.name} - ${store.address}';
    }
    
    // Resetear el estado del formulario
    _formKey.currentState?.reset();
    
    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Formulario restaurado a los valores originales'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tableStatuses = _getTableStatuses(l10n);
    final labels = _getLocalizedLabels(l10n);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(labels['updateTable']!),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _resetToOriginal,
            icon: const Icon(Icons.restore),
            tooltip: labels['resetForm'],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Icono de mesa
                  Icon(
                    Icons.edit,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  Text(
                    'Editar mesa: #${widget.tableInfo.tableNumber}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Modifica la información de la mesa',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo: Número de mesa
                  TextFormField(
                    controller: _tableNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: labels['tableNumber'],
                      hintText: labels['tableNumberHint'],
                      prefixIcon: const Icon(Icons.table_restaurant_outlined),
                      border: const OutlineInputBorder(),
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
                  const SizedBox(height: 16),

                  // Campo: Capacidad
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: labels['capacity'],
                      hintText: labels['capacityHint'],
                      prefixIcon: const Icon(Icons.people_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                      if (input.isEmpty) return 'La capacidad es obligatoria';
                      
                      final capacity = int.tryParse(input);
                      if (capacity == null) return 'La capacidad debe ser un número válido';
                      if (capacity <= 0) return 'La capacidad debe ser mayor a 0';
                      if (capacity > 20) return 'La capacidad no puede ser mayor a 20 personas';
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: Estado de la mesa (Dropdown)
                  DropdownButtonFormField<String>(
                    value: _selectedStatus != null && tableStatuses.any((status) => status['key'] == _selectedStatus) 
                        ? _selectedStatus 
                        : null,
                    decoration: InputDecoration(
                      labelText: labels['status'],
                      prefixIcon: const Icon(Icons.info_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    items: tableStatuses.map((Map<String, String> status) {
                      return DropdownMenuItem<String>(
                        value: status['key'],
                        child: Text(status['value']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return labels['selectStatus'];
                      }
                      return null;
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),

                  // Campo: Tienda con búsqueda
                  Autocomplete<StoreInfo>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return _filteredStores;
                      }
                      return _filteredStores.where((store) {
                        final storeName = store.name.toLowerCase();
                        final searchQuery = textEditingValue.text.toLowerCase();
                        return storeName.contains(searchQuery);
                      }).toList();
                    },
                    displayStringForOption: (StoreInfo store) => '${store.name} - ${store.address}',
                    onSelected: (StoreInfo store) {
                      setState(() {
                        _selectedStoreId = store.id;
                        _storeSearchController.text = '${store.name} - ${store.address}';
                      });
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: labels['store'],
                          hintText: _isLoadingStores ? 'Cargando tiendas...' : labels['searchStore'],
                          prefixIcon: _isLoadingStores 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search),
                          suffixIcon: textEditingController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    textEditingController.clear();
                                    _clearStoreSelection();
                                  },
                                )
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _storeSearchController.text = value;
                          _filterStores(value);
                        },
                        validator: (String? value) {
                          if (_selectedStoreId == null || _selectedStoreId!.isEmpty) {
                            return 'Selecciona una tienda';
                          }
                          return null;
                        },
                      );
                    },
                    optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<StoreInfo> onSelected, Iterable<StoreInfo> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final StoreInfo store = options.elementAt(index);
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: const Icon(Icons.store, color: Colors.white),
                                  ),
                                  title: Text(store.name),
                                  subtitle: Text(store.address),
                                  onTap: () => onSelected(store),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón de actualización
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleUpdate,
                      icon: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSubmitting ? labels['updating']! : labels['updateTable']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón para restaurar valores originales
                  TextButton.icon(
                    onPressed: _resetToOriginal,
                    icon: const Icon(Icons.restore),
                    label: Text(labels['resetForm']!),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
