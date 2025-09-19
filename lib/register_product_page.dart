import 'package:flutter/material.dart';

class RegisterProductPage extends StatefulWidget {
  final String selectedStore;
  
  const RegisterProductPage({
    super.key,
    required this.selectedStore,
  });

  @override
  State<RegisterProductPage> createState() => _RegisterProductPageState();
}

class _RegisterProductPageState extends State<RegisterProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  
  String? _selectedCategory;
  bool _isSubmitting = false;

  // Lista de categorías de productos
  static const List<String> _categories = [
    'Alimentación',
    'Ropa y Accesorios',
    'Electrónicos',
    'Hogar y Jardín',
    'Salud y Belleza',
    'Deportes',
    'Libros y Papelería',
    'Juguetes',
    'Automotriz',
    'Otros',
  ];

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
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
        content: Text('Producto "${_productNameController.text}" registrado exitosamente en ${widget.selectedStore}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Limpiar formulario después del registro exitoso
    _clearForm();
  }

  void _clearForm() {
    _productNameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _stockController.clear();
    setState(() {
      _selectedCategory = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Producto'),
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
                  // Icono de producto
                  Icon(
                    Icons.inventory_2,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  Text(
                    'Registrar Producto',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tienda: ${widget.selectedStore}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Completa la información del producto',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo: Nombre del producto
                  TextFormField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                      hintText: 'Ej: Camiseta de algodón',
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                      if (input.isEmpty) return 'El nombre del producto es obligatorio';
                      if (input.length < 3) return 'El nombre debe tener al menos 3 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: Categoría del producto
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría del producto',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona una categoría';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: Precio
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      hintText: 'Ej: 25.99',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                      if (input.isEmpty) return 'El precio es obligatorio';
                      
                      final double? price = double.tryParse(input);
                      if (price == null) return 'Ingresa un precio válido';
                      if (price <= 0) return 'El precio debe ser mayor a 0';
                      if (price > 999999) return 'El precio parece muy alto';
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: Stock
                  TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad en stock',
                      hintText: 'Ej: 50',
                      prefixIcon: Icon(Icons.inventory),
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                      if (input.isEmpty) return 'La cantidad en stock es obligatoria';
                      
                      final int? stock = int.tryParse(input);
                      if (stock == null) return 'Ingresa un número válido';
                      if (stock < 0) return 'El stock no puede ser negativo';
                      if (stock > 10000) return 'El stock parece muy alto';
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo: Descripción
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción del producto',
                      hintText: 'Describe las características del producto...',
                      prefixIcon: Icon(Icons.description_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String input = (value ?? '').trim();
                      if (input.isEmpty) return 'La descripción es obligatoria';
                      if (input.length < 10) return 'La descripción debe tener al menos 10 caracteres';
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
                          : const Icon(Icons.add_shopping_cart),
                      label: Text(_isSubmitting ? 'Registrando...' : 'Registrar Producto'),
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
