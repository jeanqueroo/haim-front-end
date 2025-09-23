import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CountryDropdownFormField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final String? labelText;
  final InputDecoration? decoration;
  final List<String>? countries;

  const CountryDropdownFormField({
    super.key,
    this.value,
    this.onChanged,
    this.validator,
    this.labelText,
    this.decoration,
    this.countries,
  });

  static const List<String> _defaultCountryKeys = [
    'spain',
    'unitedStates',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final countryKeys = countries ?? _defaultCountryKeys;

    return DropdownButtonFormField<String>(
      value: value,
      decoration: decoration ?? InputDecoration(
        labelText: labelText ?? l10n.country,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.flag),
      ),
      items: countryKeys.map((countryKey) {
        String translatedCountry;
        switch (countryKey) {
          case 'spain':
            translatedCountry = l10n.spain;
            break;
          case 'unitedStates':
            translatedCountry = l10n.unitedStates;
            break;
          default:
            translatedCountry = countryKey; // Fallback to original value
        }
        
        return DropdownMenuItem<String>(
          value: countryKey,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(translatedCountry),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
