import 'package:flutter/material.dart';
import '../../../features/stores/services/store_service.dart';
import '../../../l10n/app_localizations.dart';
import '../services/table_service.dart';

class RegisterTablePage extends StatefulWidget {
  const RegisterTablePage({super.key});

  @override
  State<RegisterTablePage> createState() => _RegisterTablePageState();
}

class _RegisterTablePageState extends State<RegisterTablePage> {
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
    return [
      {'key': 'available', 'value': l10n.available},
      {'key': 'occupied', 'value': l10n.occupied},
      {'key': 'reserved', 'value': l10n.reserved},
      {'key': 'maintenance', 'value': l10n.maintenance},
    ];
  }

  // Obtener etiquetas localizadas
  Map<String, String> _getLocalizedLabels(AppLocalizations l10n) {
    return {
      'tableNumber': l10n.tableNumber,
      'tableNumberHint': l10n.tableNumberHint,
      'capacity': l10n.capacity,
      'capacityHint': l10n.capacityHint,
      'status': l10n.tableStatus,
      'selectStatus': l10n.selectStatus,
      'store': l10n.storeLabel,
      'searchStore': l10n.searchStore,
      'registerTable': l10n.registerTable,
      'registering': l10n.registering,
      'clearForm': l10n.clearForm,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _capacityController.dispose();
    _storeSearchController.dispose();
    super.dispose();
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

  Future<void> _handleRegister() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Llamar al servicio para registrar la mesa
      final result = await _tableService.registerTable(
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

        // Limpiar formulario inmediatamente después del registro exitoso
        _clearForm(showConfirmation: false);
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

  void _clearForm({bool showConfirmation = true}) {
    // Limpiar todos los controladores de texto
    _tableNumberController.clear();
    _capacityController.clear();
    
    // Limpiar selección de tienda
    _clearStoreSelection();
    
    // Resetear todos los estados del formulario
    setState(() {
      _selectedStatus = null;
      _isSubmitting = false;
    });
    
    // Resetear el estado del formulario (valida y limpia errores)
    _formKey.currentState?.reset();
    
    // Limpiar el foco de cualquier campo
    FocusScope.of(context).unfocus();
    
    // Mostrar mensaje de confirmación solo si se solicita
    if (showConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Formulario limpiado correctamente'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tableStatuses = _getTableStatuses(l10n);
    final labels = _getLocalizedLabels(l10n);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(labels['registerTable']!),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    Icons.table_restaurant,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  Text(
                    l10n.registerNewTable,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.completeTableInfo,
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
                      if (input.isEmpty) return l10n.tableNumberRequired;
                      
                      final number = int.tryParse(input);
                      if (number == null) return l10n.tableNumberValidation;
                      if (number <= 0) return l10n.tableNumberPositive;
                      
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
                      if (input.isEmpty) return l10n.capacityRequired;
                      
                      final capacity = int.tryParse(input);
                      if (capacity == null) return l10n.capacityValidation;
                      if (capacity <= 0) return l10n.capacityPositive;
                      if (capacity > 20) return l10n.capacityMax;
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: Estado de la mesa (Dropdown)
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
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
                            return l10n.selectStore;
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

                  // Botón de registro
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleRegister,
                      icon: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(_isSubmitting ? labels['registering']! : labels['registerTable']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón para limpiar formulario
                  TextButton.icon(
                    onPressed: _clearForm,
                    icon: const Icon(Icons.clear),
                    label: Text(labels['clearForm']!),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
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
