import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/store_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageService = context.watch<LanguageService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de idioma
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        l10n.language,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.selectLanguageDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lista de idiomas disponibles
                  ...languageService.availableLanguages.map((language) {
                    final isSelected = language['code'] == languageService.currentLocale.languageCode;
                    return ListTile(
                      leading: Text(
                        language['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        language['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                      onTap: () {
                        languageService.changeLanguageByCode(language['code']!);
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Sección de tienda
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, color: Colors.orange),
                      const SizedBox(width: 12),
                      Text(
                        'Tienda de Trabajo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selecciona la tienda en la que quieres trabajar. Esta configuración se aplicará a toda la aplicación.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<StoreProvider>(
                    builder: (context, storeProvider, child) {
                      final selectedStore = storeProvider.selectedStore;
                      
                      if (selectedStore == null) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.store_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No hay tienda seleccionada',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Selecciona una tienda para comenzar a trabajar',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  // Recargar tiendas antes de mostrar el selector
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  await storeProvider.loadStores(authProvider: authProvider);
                                  await storeProvider.showStoreSelector(context);
                                },
                                icon: const Icon(Icons.store),
                                label: const Text('Seleccionar Tienda'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: Icon(
                                    _getStoreIcon(selectedStore.type),
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedStore.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getStoreTypeName(selectedStore.type),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                      if (selectedStore.address.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          selectedStore.address,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      // Recargar tiendas antes de mostrar el selector
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      await storeProvider.loadStores(authProvider: authProvider);
                                      await storeProvider.showStoreSelector(context);
                                    },
                                    icon: const Icon(Icons.swap_horiz),
                                    label: const Text('Cambiar Tienda'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                      side: BorderSide(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      storeProvider.clearStore();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Tienda deseleccionada'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Deseleccionar'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Información adicional
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        l10n.information,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.currentLanguage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          languageService.currentLanguageFlag,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          languageService.currentLanguageName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.languageChangeNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStoreIcon(String type) {
    switch (type.toLowerCase()) {
      case 'truck':
        return Icons.local_shipping;
      case 'store':
        return Icons.store;
      case 'supermarket':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.business;
    }
  }

  String _getStoreTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'truck':
        return 'Camión';
      case 'store':
        return 'Tienda';
      case 'supermarket':
        return 'Supermercado';
      case 'restaurant':
        return 'Restaurante';
      default:
        return 'Otro';
    }
  }
}
