import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/country_dropdown_form_field.dart';

class EditUserPage extends StatefulWidget {
  final UserInfo user;

  const EditUserPage({
    super.key,
    required this.user,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _ageController;
  
  String _selectedGender = 'M';
  String _selectedCountry = 'spain';
  List<String> _selectedRoles = [];
  bool _isSubmitting = false;

  final List<String> _genderOptions = ['M', 'F'];
  final List<String> _availableRoles = ['admin', 'vendedor', 'user'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _addressController = TextEditingController(text: widget.user.address);
    _ageController = TextEditingController(text: widget.user.age.toString());
    
    // Map gender values from server to dropdown values
    String userGender = widget.user.gender.toLowerCase();
    if (userGender == 'masculino' || userGender == 'male' || userGender == 'm') {
      userGender = 'M';
    } else if (userGender == 'femenino' || userGender == 'female' || userGender == 'f') {
      userGender = 'F';
    } else {
      // Default to 'M' for any other value including 'otro', 'other', etc.
      userGender = 'M';
    }
    _selectedGender = userGender;
    
    // Map country values to keys
    String userCountry = widget.user.country;
    if (userCountry == 'Estados Unidos' || userCountry == 'United States' || userCountry == 'USA' || userCountry == 'US') {
      userCountry = 'unitedStates';
    } else if (userCountry == 'España' || userCountry == 'Spain' || userCountry == 'ES') {
      userCountry = 'spain';
    } else {
      // Default to 'spain' for any other value
      userCountry = 'spain';
    }
    _selectedCountry = userCountry;
    
    _selectedRoles = List.from(widget.user.roles);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.editUser ?? 'Edit User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSubmitting ? null : _handleSubmit,
            tooltip: l10n?.save ?? 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información personal
              _buildSectionHeader(l10n?.personalInformation ?? 'Personal Information'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: l10n?.firstName ?? 'First Name',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n?.firstNameRequired ?? 'First name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: l10n?.lastName ?? 'Last Name',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n?.lastNameRequired ?? 'Last name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n?.email ?? 'Email',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n?.emailRequired ?? 'Email is required';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return l10n?.invalidEmail ?? 'Invalid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Edad y Género
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: l10n?.age ?? 'Age',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n?.ageRequired ?? 'Age is required';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age <= 0) {
                          return l10n?.invalidAge ?? 'Invalid age';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        labelText: l10n?.gender ?? 'Gender',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: _genderOptions.map((gender) {
                        String displayText;
                        IconData icon;
                        switch (gender) {
                          case 'M':
                            displayText = l10n?.male ?? 'Male';
                            icon = Icons.male;
                            break;
                          case 'F':
                            displayText = l10n?.female ?? 'Female';
                            icon = Icons.female;
                            break;
                          default:
                            displayText = l10n?.male ?? 'Male';
                            icon = Icons.male;
                        }
                        
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Row(
                            children: [
                              Icon(icon, size: 20),
                              const SizedBox(width: 8),
                              Text(displayText),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n?.selectGender ?? 'Select gender';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Dirección
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n?.address ?? 'Address',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n?.addressRequired ?? 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // País
              CountryDropdownFormField(
                value: _selectedCountry,
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n?.countryRequired ?? 'Country is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Roles
              _buildSectionHeader(l10n?.roles ?? 'Roles'),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableRoles.map((role) {
                  final isSelected = _selectedRoles.contains(role);
                  String roleText;
                  Color roleColor;
                  
                  switch (role) {
                    case 'admin':
                      roleText = l10n?.admin ?? 'Administrator';
                      roleColor = Colors.red;
                      break;
                    case 'vendedor':
                      roleText = l10n?.vendedor ?? 'Salesperson';
                      roleColor = Colors.blue;
                      break;
                    case 'user':
                      roleText = l10n?.user ?? 'User';
                      roleColor = Colors.green;
                      break;
                    default:
                      roleText = role;
                      roleColor = Colors.grey;
                  }
                  
                  return FilterChip(
                    label: Text(roleText),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRoles.add(role);
                        } else {
                          _selectedRoles.remove(role);
                        }
                      });
                    },
                    selectedColor: roleColor.withOpacity(0.3),
                    checkmarkColor: roleColor,
                    labelStyle: TextStyle(
                      color: isSelected ? roleColor : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  icon: _isSubmitting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSubmitting ? l10n?.saving ?? 'Saving...' : l10n?.save ?? 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.rolesRequired ?? 'At least one role is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Map dropdown values to server format
      String genderForServer = _selectedGender == 'M' ? 'masculino' : 'femenino';
      
      // Map country key to full country name for server
      String countryForServer;
      switch (_selectedCountry) {
        case 'spain':
          countryForServer = 'España';
          break;
        case 'unitedStates':
          countryForServer = 'Estados Unidos';
          break;
        default:
          countryForServer = 'España';
      }
      
      final result = await _userService.updateUser(
        userId: widget.user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        country: countryForServer,
        age: int.parse(_ageController.text.trim()),
        gender: genderForServer,
        roles: _selectedRoles,
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Retorna true para indicar éxito
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
            content: Text('${AppLocalizations.of(context)?.errorUpdatingUser ?? 'Error updating user'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
