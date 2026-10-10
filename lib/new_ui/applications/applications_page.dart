import 'dart:async';

import 'package:dsm_helper/new_ui/applications/application_catalog.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_controller.dart';
import 'package:dsm_helper/new_ui/applications/application_favorites_store.dart';
import 'package:dsm_helper/new_ui/applications/application_launcher_tile.dart';
import 'package:dsm_helper/providers/init_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef ApplicationFavoritesControllerFactory =
    ApplicationFavoritesController Function();

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({
    super.key,
    required this.onOpenNotifications,
    required this.onOpenApplication,
    this.connectionStatusText,
    this.catalog = const ModernApplicationCatalog(),
    this.favoritesControllerFactory,
  });

  final VoidCallback onOpenNotifications;
  final ValueChanged<ModernApplicationId> onOpenApplication;
  final String? connectionStatusText;
  final ModernApplicationCatalog catalog;
  final ApplicationFavoritesControllerFactory? favoritesControllerFactory;

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  late final ApplicationFavoritesController _favoritesController =
      widget.favoritesControllerFactory?.call() ??
          ApplicationFavoritesController(
            store: SpUtilApplicationFavoritesStore(),
          );

  @override
  void initState() {
    super.initState();
    unawaited(_favoritesController.load());
  }

  @override
  void dispose() {
    _favoritesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot =
        widget.catalog.build(context.watch<InitDataProvider>().initData);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Flexible(
              child: Text(
                '应用',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.connectionStatusText != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.connectionStatusText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            key: const Key('new-ui-notifications'),
            tooltip: '通知',
            onPressed: widget.onOpenNotifications,
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _favoritesController,
        builder: (context, _) {
          final byId = <ModernApplicationId, ModernApplicationItem>{
            for (final item in snapshot.items) item.id: item,
          };
          final favoriteItems = _favoritesController
              .visibleFor(snapshot.items)
              .map((id) => byId[id])
              .whereType<ModernApplicationItem>()
              .toList(growable: false);

          return ListView(
            key: const Key('applications-scroll'),
            padding: const EdgeInsets.all(16),
            children: [
              Text('常用', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (favoriteItems.isEmpty)
                Text(
                  '暂无常用应用',
                  style: theme.textTheme.bodySmall,
                )
              else
                _ApplicationGrid(
                  key: const Key('favorite-applications-grid'),
                  items: favoriteItems,
                  onOpenApplication: widget.onOpenApplication,
                ),
              const SizedBox(height: 24),
              Text('全部应用', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (snapshot.availability ==
                  ApplicationCatalogAvailability.unavailable)
                Text(
                  '应用数据暂不可用',
                  style: theme.textTheme.bodySmall,
                )
              else if (snapshot.items.isEmpty)
                Text(
                  '没有可用应用',
                  style: theme.textTheme.bodySmall,
                )
              else
                _ApplicationGrid(
                  key: const Key('all-applications-grid'),
                  items: snapshot.items,
                  onOpenApplication: widget.onOpenApplication,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ApplicationGrid extends StatelessWidget {
  const _ApplicationGrid({
    super.key,
    required this.items,
    required this.onOpenApplication,
  });

  final List<ModernApplicationItem> items;
  final ValueChanged<ModernApplicationId> onOpenApplication;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: key,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 104,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return ApplicationLauncherTile(
          item: item,
          onTap: () => onOpenApplication(item.id),
          onLongPress: () {},
        );
      },
    );
  }
}
