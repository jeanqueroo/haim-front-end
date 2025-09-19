import 'package:flutter/material.dart';

class RegisterStorePage extends StatefulWidget {
  const RegisterStorePage({super.key});

  @override
  State<RegisterStorePage> createState() => _RegisterStorePageState();
}

class _RegisterStorePageState extends State<RegisterStorePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _staffCountController = TextEditingController();
  String? _selectedStoreType;
  bool _isSubmitting = false;

  // Lista de tipos de tienda
  static const List<String> _storeTypes = [
    'Truck',
    'Store',
    'Supermercado',
    'Restaurant',
    'Otro',
  ];

  @override
  void dispose() {
    _storeNameController.dispose();
    _staffCountController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simular proceso de registro
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tienda "${_storeNameController.text}" registrada exitosamente'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Limpiar formulario después del registro exitoso
    _clearForm();
  }

  void _clearForm() {
    _storeNameController.clear();
    _staffCountController.clear();
    setState(() {
      _selectedStoreType = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Tienda'),
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
                  // Icono de tienda
                  Icon(
                    Icons.store,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  Text(
                    'Registra tu tienda',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa la información de tu tienda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo: Nombre de la tienda
                  TextFormField(
                    controller: _storeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la tienda',
                      hintText: 'Ej: Mi Tienda Favorita',
                      prefixIcon: Icon(Icons.store_outlined),
                      border: OutlineInputBorder(),
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
                    value: _selectedStoreType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de tienda',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _storeTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStoreType = newValue;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona un tipo de tienda';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: Cantidad de personal
                  TextFormField(
                    controller: _staffCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de personal',
                      hintText: 'Ej: 5',
                      prefixIcon: Icon(Icons.people_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                      if (input.isEmpty) return 'La cantidad de personal es obligatoria';
                      
                      final int? staffCount = int.tryParse(input);
                      if (staffCount == null) return 'Ingresa un número válido';
                      if (staffCount < 1) return 'Debe ser al menos 1 persona';
                      if (staffCount > 1000) return 'El número parece muy alto';
                      
                      return null;
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
                          : const Icon(Icons.add_business),
                      label: Text(_isSubmitting ? 'Registrando...' : 'Registrar Tienda'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón para limpiar formulario
                  TextButton.icon(
                    onPressed: _isSubmitting ? null : _clearForm,
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar formulario'),
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

