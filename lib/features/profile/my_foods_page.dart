import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_view.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../products/product_repository.dart';
import '../products/widgets/food_tile.dart';

/// List of the user's own foods.
///
/// Tap → product page (to see the rating and add it to the diary). The menu
/// of each food offers "Bearbeiten" and "Löschen".
class MyFoodsPage extends ConsumerWidget {
  const MyFoodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final foods = ref.watch(ownFoodsProvider);
    final hasFoods = foods.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myFoodsTitle)),
      // The empty state has its own button; one is enough.
      floatingActionButton: hasFoods
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: Text(l10n.myFoodsCreate),
              onPressed: () => context.push(Routes.newFood()),
            )
          : null,
      body: switch (foods) {
        AsyncData(value: final foods) when foods.isEmpty => StatusView(
          icon: Icons.kitchen_outlined,
          title: l10n.myFoodsEmpty,
          message: l10n.myFoodsEmptyText,
          actionLabel: l10n.myFoodsCreate,
          onAction: () => context.push(Routes.newFood()),
        ),
        AsyncData(value: final foods) => ListView(
          // Room for the floating button.
          padding: const EdgeInsets.only(bottom: Spacing.belowFab),
          children: [for (final food in foods) _OwnFoodRow(food: food)],
        ),
        AsyncError() => StatusView(
          icon: Icons.error_outline,
          title: l10n.errorGeneric,
          actionLabel: l10n.actionRetry,
          onAction: () => ref.invalidate(ownFoodsProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

enum _FoodAction { edit, delete }

class _OwnFoodRow extends ConsumerWidget {
  const _OwnFoodRow({required this.food});

  final Food food;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.foodFormDeleteTitle(food.name)),
        content: Text(l10n.foodFormDeleteText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(productRepositoryProvider).deleteOwnFood(food.id);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.foodFormDeleted(food.name))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: FoodTile.food(
            food,
            onTap: () => context.push(Routes.food(food.id)),
          ),
        ),
        PopupMenuButton<_FoodAction>(
          tooltip: l10n.myFoodsMore(food.name),
          onSelected: (action) => switch (action) {
            _FoodAction.edit => context.push(Routes.editFood(food.id)),
            _FoodAction.delete => _delete(context, ref),
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _FoodAction.edit,
              child: Text(l10n.actionEdit),
            ),
            PopupMenuItem(
              value: _FoodAction.delete,
              child: Text(l10n.actionDelete),
            ),
          ],
        ),
      ],
    );
  }
}
