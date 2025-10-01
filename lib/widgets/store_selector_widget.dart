import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../features/stores/services/store_service.dart';
import '../features/auth/providers/auth_provider.dart';

class StoreSelectorWidget extends StatelessWidget {
  final bool showLabel;
  final bool compact;

  const StoreSelectorWidget({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final selectedStore = storeProvider.selectedStore;
        
        if (selectedStore == null) {
          return _buildNoStoreSelected(context, storeProvider);
        }

        return _buildStoreSelected(context, storeProvider, selectedStore);
      },
    );
  }

  Widget _buildNoStoreSelected(BuildContext context, StoreProvider storeProvider) {
    return InkWell(
      onTap: () => _showStoreSelector(context, storeProvider),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store_outlined,
              size: compact ? 16 : 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 8),
            if (showLabel) ...[
              Text(
                'Seleccionar Tienda',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: compact ? 12 : 14,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.arrow_drop_down,
              size: compact ? 16 : 20,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSelected(BuildContext context, StoreProvider storeProvider, StoreInfo store) {
    return InkWell(
      onTap: () => _showStoreSelector(context, storeProvider),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStoreIcon(store.type),
              size: compact ? 16 : 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            if (showLabel) ...[
              Flexible(
                child: Text(
                  store.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.arrow_drop_down,
              size: compact ? 16 : 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStoreSelector(BuildContext context, StoreProvider storeProvider) async {
    // Recargar tiendas antes de mostrar el selector para asegurar que estén actualizadas
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await storeProvider.loadStores(authProvider: authProvider);
    await storeProvider.showStoreSelector(context);
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
}

// Widget para mostrar la tienda seleccionada en el AppBar
class StoreAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const StoreAppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 2),
          StoreSelectorWidget(
            showLabel: false,
            compact: true,
          ),
        ],
      ),
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);
}
