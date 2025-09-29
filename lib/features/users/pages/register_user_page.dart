import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../../settings/services/language_service.dart';
import '../../stores/services/store_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/country_dropdown_form_field.dart';

class RegisterUserPage extends StatefulWidget {
  final StoreInfo? preSelectedStore;
  
  const RegisterUserPage({
    super.key,
    this.preSelectedStore,
  });

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _gender; // "M" | "F" | "Otro"
  String _selectedCountry = 'spain';
 
  final List<String> _allRoles = <String>["admin", "vendedor", "user"];
  final Set<String> _selectedRoles = <String>{};

  bool _isSubmitting = false;
  bool _isCheckingEmail = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailAvailability() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() { _isCheckingEmail = true; });
    
    try {
      final isAvailable = await _userService.isEmailAvailable(email);
      if (!mounted) return;
      
      if (!isAvailable) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.emailAlreadyRegistered),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorCheckingEmail}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() { _isCheckingEmail = false; });
    }
  }

  Future<void> _handleSubmit() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) return;
    final l10n = AppLocalizations.of(context);
    
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectGender)),
      );
      return;
    }
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAtLeastOneRole)),
      );
      return;
    }

    setState(() { _isSubmitting = true; });
    try {
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
      
      final result = await _userService.registerUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        country: countryForServer,
        age: int.parse(_ageController.text.trim()),
        gender: _gender!,
        roles: _selectedRoles.toList(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.unexpectedError}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageService = context.watch<LanguageService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerUser),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: l10n.selectLanguage,
            onSelected: (String languageCode) {
              languageService.changeLanguageByCode(languageCode);
            },
            itemBuilder: (BuildContext context) {
              return languageService.availableLanguages.map((language) {
                return PopupMenuItem<String>(
                  value: language['code']!,
                  child: Row(
                    children: [
                      Icon(
                        language['code'] == languageService.currentLocale.languageCode
                            ? Icons.check
                            : null,
                        color: language['code'] == languageService.currentLocale.languageCode
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text('${language['flag']} ${language['name']}'),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    border: const OutlineInputBorder(),
                    suffixIcon: _isCheckingEmail
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: _isSubmitting ? null : _checkEmailAvailability,
                            tooltip: l10n.checkEmailAvailability,
                          ),
                  ),
                  validator: (String? v) {
                    final String input = (v ?? '').trim();
                    if (input.isEmpty) return l10n.required;
                    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(input)) return l10n.invalidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? v) {
                    final String input = (v ?? '');
                    if (input.isEmpty) return l10n.required;
                    if (input.length < 6) return l10n.passwordMinLength;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: l10n.firstName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? v) {
                    if ((v ?? '').trim().isEmpty) return l10n.required;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: l10n.lastName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? v) {
                    if ((v ?? '').trim().isEmpty) return l10n.required;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: l10n.address,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? v) {
                    if ((v ?? '').trim().isEmpty) return l10n.required;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CountryDropdownFormField(
                  value: _selectedCountry,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCountry = value!;
                    });
                  },
                  validator: (String? v) {
                    if (v == null || v.isEmpty) return l10n.required;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.age,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? v) {
                    final String val = (v ?? '').trim();
                    if (val.isEmpty) return l10n.required;
                    final int? n = int.tryParse(val);
                    if (n == null) return l10n.mustBeNumber;
                    if (n <= 0) return l10n.mustBeGreaterThanZero;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem(value: 'M', child: Text(l10n.male)),
                    DropdownMenuItem(value: 'F', child: Text(l10n.female)),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.gender,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (String? v) => setState(() { _gender = v; }),
                ),
                const SizedBox(height: 12),
                Text(l10n.roles, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                 Wrap(
                   spacing: 8,
                   children: _allRoles.map((String role) {
                     final bool selected = _selectedRoles.contains(role);
                     String roleText = role;
                     switch (role) {
                       case 'admin':
                         roleText = l10n.admin;
                         break;
                       case 'vendedor':
                         roleText = l10n.vendedor;
                         break;
                       case 'user':
                         roleText = l10n.user;
                         break;
                     }
                     return FilterChip(
                       label: Text(roleText),
                       selected: selected,
                       onSelected: (bool v) {
                         setState(() {
                           if (v) {
                             _selectedRoles.add(role);
                           } else {
                             _selectedRoles.remove(role);
                           }
                         });
                       },
                     );
                   }).toList(),
                 ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.person_add_alt_1),
                     label: Text(_isSubmitting ? l10n.registering : l10n.register),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


