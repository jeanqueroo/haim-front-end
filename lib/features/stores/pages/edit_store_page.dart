import 'package:flutter/material.dart';
import '../../../features/users/services/user_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/country_dropdown_form_field.dart';
import '../services/store_service.dart';

class EditStorePage extends StatefulWidget {
  final String storeId;
  final StoreInfo storeInfo;

  const EditStorePage({
    super.key,
    required this.storeId,
    required this.storeInfo,
  });

  @override
  State<EditStorePage> createState() => _EditStorePageState();
}

class _EditStorePageState extends State<EditStorePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final UserService _userService = UserService();
  final StoreService _storeService = StoreService();
  String? _selectedStoreType;
  String? _selectedCountry;
  String? _selectedUserId;
  List<UserInfo> _users = [];
  List<UserInfo> _filteredUsers = [];
  bool _isSubmitting = false;
  bool _isLoadingUsers = false;
  final TextEditingController _userSearchController = TextEditingController();
  String _userDisplayText = '';

  // Lista de tipos de tienda con localización
  List<Map<String, String>> _getStoreTypes(AppLocalizations l10n) {
    final isSpanish = l10n.locale.languageCode == 'es';
    
    return [
      {'key': 'truck', 'value': isSpanish ? 'Camión' : 'Truck'},
      {'key': 'store', 'value': l10n.store},
      {'key': 'supermarket', 'value': isSpanish ? 'Supermercado' : 'Supermarket'},
      {'key': 'restaurant', 'value': isSpanish ? 'Restaurante' : 'Restaurant'},
      {'key': 'other', 'value': l10n.other},
    ];
  }

  // Obtener etiquetas localizadas
  Map<String, String> _getLocalizedLabels(AppLocalizations l10n) {
    final isSpanish = l10n.locale.languageCode == 'es';
    
    return {
      'storeType': isSpanish ? 'Tipo de tienda' : 'Store Type',
      'selectStoreType': isSpanish ? 'Selecciona un tipo de tienda' : 'Select a store type',
      'storeName': isSpanish ? 'Nombre de la tienda' : 'Store Name',
      'storeNameHint': isSpanish ? 'Ej: Mi Tienda Favorita' : 'Ex: My Favorite Store',
      'storeAddress': isSpanish ? 'Dirección de la tienda' : 'Store Address',
      'storeAddressHint': isSpanish ? 'Ej: Calle Principal 123' : 'Ex: Main Street 123',
      'storeCountry': isSpanish ? 'País' : 'Country',
      'storeCountryHint': isSpanish ? 'Selecciona el país' : 'Select country',
      'storePhone': isSpanish ? 'Número de teléfono' : 'Phone Number',
      'storePhoneHint': isSpanish ? 'Ej: +1 234 567 8900' : 'Ex: +1 234 567 8900',
      'responsibleUser': isSpanish ? 'Usuario responsable' : 'Responsible User',
      'searchUser': isSpanish ? 'Buscar y seleccionar usuario' : 'Search and select user',
      'updateStore': isSpanish ? 'Actualizar Tienda' : 'Update Store',
      'updating': isSpanish ? 'Actualizando...' : 'Updating...',
      'resetForm': isSpanish ? 'Restaurar valores originales' : 'Reset to original values',
    };
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  void _loadStoreData() {
    // Cargar los datos de la tienda en el formulario
    _storeNameController.text = widget.storeInfo.name;
    _addressController.text = widget.storeInfo.address;
    _phoneController.text = widget.storeInfo.phone;
    
    // Validar que el tipo de tienda sea válido usando tipos predefinidos
    final validTypeKeys = ['truck', 'store', 'supermarket', 'restaurant', 'other'];
    
    if (validTypeKeys.contains(widget.storeInfo.type)) {
      _selectedStoreType = widget.storeInfo.type;
    } else {
      // Si el tipo no es válido, usar 'other' como fallback
      _selectedStoreType = 'other';
    }
    
    _selectedCountry = widget.storeInfo.country;
    _selectedUserId = widget.storeInfo.responsibleUserId;
    
    // Buscar el usuario responsable para mostrarlo en el campo de búsqueda
    if (_selectedUserId != null && _users.isNotEmpty) {
      final user = _users.firstWhere(
        (u) => u.id == _selectedUserId,
        orElse: () => UserInfo(
          id: '',
          firstName: 'Usuario',
          lastName: 'Desconocido',
          email: '',
          address: '',
          country: '',
          age: 0,
          gender: '',
          roles: [],
        ),
      );
      _userDisplayText = '${user.firstName} ${user.lastName} (${user.email})';
      _userSearchController.text = _userDisplayText;
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final users = await _userService.getAllUsers(context: context);
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoadingUsers = false;
      });
      
      // Cargar datos de la tienda después de cargar usuarios
      _loadStoreData();
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
          final email = user.email.toLowerCase();
          final searchQuery = query.toLowerCase();
          return fullName.contains(searchQuery) || email.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _clearUserSelection() {
    setState(() {
      _selectedUserId = null;
      _userDisplayText = '';
      _userSearchController.clear();
      _filteredUsers = _users;
    });
  }

  /// Valida el formato de teléfono según el país
  bool _isValidPhoneForCountry(String phone, String country) {
    switch (country.toLowerCase()) {
      case 'spain':
      case 'es':
        // España: +34, 9 dígitos, puede tener espacios o guiones
        // Ejemplos: +34 123 456 789, +34123456789, 123 456 789
        final spainRegex = RegExp(r'^(\+34\s?)?[6-9]\d{2}\s?\d{3}\s?\d{3}$');
        return spainRegex.hasMatch(phone);
      
      case 'unitedstates':
      case 'us':
      case 'usa':
        // Estados Unidos: +1, 10 dígitos, puede tener espacios, guiones o paréntesis
        // Ejemplos: +1 (123) 456-7890, +1 123 456 7890, (123) 456-7890, 123-456-7890
        final usRegex = RegExp(r'^(\+1\s?)?(\([0-9]{3}\)\s?[0-9]{3}-[0-9]{4}|[0-9]{3}-[0-9]{3}-[0-9]{4}|[0-9]{3}\s[0-9]{3}\s[0-9]{4}|[0-9]{10})$');
        return usRegex.hasMatch(phone);
      
      default:
        // Para otros países, usar validación genérica
        final genericRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$');
        return genericRegex.hasMatch(phone);
    }
  }

  /// Obtiene el formato esperado de teléfono para un país
  String _getPhoneFormatForCountry(String country) {
    switch (country.toLowerCase()) {
      case 'spain':
      case 'es':
        return 'Formato España: +34 123 456 789 o 123 456 789';
      case 'unitedstates':
      case 'us':
      case 'usa':
        return 'Formato USA: +1 (123) 456-7890 o (123) 456-7890';
      default:
        return 'Formato: +1 234 567 8900';
    }
  }

  Future<void> _handleUpdate() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Llamar al servicio para actualizar la tienda
      final result = await _storeService.updateStore(
        storeId: widget.storeId,
        name: _storeNameController.text,
        type: _selectedStoreType!,
        address: _addressController.text,
        country: _selectedCountry!,
        phone: _phoneController.text,
        responsibleUserId: _selectedUserId!,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      if (result.isSuccess) {
        // Obtener información del usuario seleccionado para el mensaje
        final selectedUser = _users.firstWhere(
          (user) => user.id == _selectedUserId,
          orElse: () => UserInfo(
            id: '',
            firstName: 'Usuario',
            lastName: 'Desconocido',
            email: '',
            address: '',
            country: '',
            age: 0,
            gender: '',
            roles: [],
          ),
        );

        // Obtener información del país seleccionado
        final l10n = AppLocalizations.of(context);
        String selectedCountryName;
        switch (_selectedCountry) {
          case 'spain':
            selectedCountryName = l10n.spain;
            break;
          case 'unitedStates':
            selectedCountryName = l10n.unitedStates;
            break;
          default:
            selectedCountryName = _selectedCountry ?? 'País no seleccionado';
        }

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.message}\nDirección: ${_addressController.text}\nPaís: $selectedCountryName\nTeléfono: ${_phoneController.text}\nResponsable: ${selectedUser.firstName} ${selectedUser.lastName}'),
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
    // Restaurar los valores originales de la tienda
    _storeNameController.text = widget.storeInfo.name;
    _addressController.text = widget.storeInfo.address;
    _phoneController.text = widget.storeInfo.phone;
    
    // Validar que el tipo de tienda sea válido usando tipos predefinidos
    final validTypeKeys = ['truck', 'store', 'supermarket', 'restaurant', 'other'];
    
    setState(() {
      if (validTypeKeys.contains(widget.storeInfo.type)) {
        _selectedStoreType = widget.storeInfo.type;
      } else {
        _selectedStoreType = 'other';
      }
      _selectedCountry = widget.storeInfo.country;
      _selectedUserId = widget.storeInfo.responsibleUserId;
    });
    
    // Restaurar el usuario responsable en el campo de búsqueda
    if (_selectedUserId != null && _users.isNotEmpty) {
      final user = _users.firstWhere(
        (u) => u.id == _selectedUserId,
        orElse: () => UserInfo(
          id: '',
          firstName: 'Usuario',
          lastName: 'Desconocido',
          email: '',
          address: '',
          country: '',
          age: 0,
          gender: '',
          roles: [],
        ),
      );
      _userDisplayText = '${user.firstName} ${user.lastName} (${user.email})';
      _userSearchController.text = _userDisplayText;
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
    final storeTypes = _getStoreTypes(l10n);
    final labels = _getLocalizedLabels(l10n);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(labels['updateStore']!),
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
                  // Icono de tienda
                  Icon(
                    Icons.edit,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  Text(
                    'Editar tienda: ${widget.storeInfo.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Modifica la información de la tienda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo: Nombre de la tienda
                  TextFormField(
                    controller: _storeNameController,
                    decoration: InputDecoration(
                      labelText: labels['storeName'],
                      hintText: labels['storeNameHint'],
                      prefixIcon: const Icon(Icons.store_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                      if (input.isEmpty) return 'El nombre de la tienda es obligatorio';
                      if (input.length < 3) return 'El nombre debe tener al menos 3 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: Tipo de tienda (Dropdown)
                  DropdownButtonFormField<String>(
                    value: _selectedStoreType != null && storeTypes.any((type) => type['key'] == _selectedStoreType) 
                        ? _selectedStoreType 
                        : null,
                    decoration: InputDecoration(
                      labelText: labels['storeType'],
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    items: storeTypes.map((Map<String, String> type) {
                      return DropdownMenuItem<String>(
                        value: type['key'],
                        child: Text(type['value']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStoreType = newValue;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return labels['selectStoreType'];
                      }
                      return null;
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),

                  // Campo: Dirección de la tienda
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: labels['storeAddress'],
                      hintText: labels['storeAddressHint'],
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                      if (input.isEmpty) return 'La dirección es obligatoria';
                      if (input.length < 10) return 'La dirección debe tener al menos 10 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: País
                  CountryDropdownFormField(
                    value: _selectedCountry,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCountry = newValue;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona un país';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: labels['storeCountry'],
                      prefixIcon: const Icon(Icons.public),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo: Número de teléfono
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: labels['storePhone'],
                      hintText: _selectedCountry != null 
                          ? _getPhoneFormatForCountry(_selectedCountry!)
                          : labels['storePhoneHint'],
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                      if (input.isEmpty) return 'El número de teléfono es obligatorio';
                      
                      // Validar formato de teléfono según el país seleccionado
                      if (_selectedCountry != null) {
                        if (!_isValidPhoneForCountry(input, _selectedCountry!)) {
                          return _getPhoneFormatForCountry(_selectedCountry!);
                        }
                      } else {
                        // Validación genérica si no hay país seleccionado
                        final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$');
                        if (!phoneRegex.hasMatch(input)) {
                          return 'Formato de teléfono inválido';
                        }
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: Usuario responsable con búsqueda
                  Autocomplete<UserInfo>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return _filteredUsers;
                      }
                      return _filteredUsers.where((user) {
                        final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
                        final email = user.email.toLowerCase();
                        final searchQuery = textEditingValue.text.toLowerCase();
                        return fullName.contains(searchQuery) || email.contains(searchQuery);
                      }).toList();
                    },
                    displayStringForOption: (UserInfo user) => '${user.firstName} ${user.lastName} (${user.email})',
                    onSelected: (UserInfo user) {
                      setState(() {
                        _selectedUserId = user.id;
                        _userSearchController.text = '${user.firstName} ${user.lastName} (${user.email})';
                      });
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      // Sincronizar el controlador interno con nuestro texto de usuario
                      if (_userDisplayText.isNotEmpty && textEditingController.text != _userDisplayText) {
                        textEditingController.text = _userDisplayText;
                      }
                      
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: labels['responsibleUser'],
                          hintText: _isLoadingUsers ? 'Cargando usuarios...' : labels['searchUser'],
                          prefixIcon: _isLoadingUsers 
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
                                    _clearUserSelection();
                                  },
                                )
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _userSearchController.text = value;
                          _filterUsers(value);
                        },
                        validator: (String? value) {
                          if (_selectedUserId == null || _selectedUserId!.isEmpty) {
                            return 'Selecciona un usuario responsable';
                          }
                          return null;
                        },
                      );
                    },
                    optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<UserInfo> onSelected, Iterable<UserInfo> options) {
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
                                final UserInfo user = options.elementAt(index);
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text('${user.firstName} ${user.lastName}'),
                                  subtitle: Text(user.email),
                                  onTap: () => onSelected(user),
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
                      label: Text(_isSubmitting ? labels['updating']! : labels['updateStore']!),
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
