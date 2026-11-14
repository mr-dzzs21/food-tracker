import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/bottom_cta_bar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/card_list.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/page_header.dart';
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
      appBar: PageHeader(title: l10n.myFoodsTitle),
      // The empty state has its own button; one is enough.
      bottomNavigationBar: hasFoods
          ? BottomCtaBar(
              child: CtaButton(
                icon: Icons.add_rounded,
                label: l10n.myFoodsCreate,
                onPressed: () => context.push(Routes.newFood()),
              ),
            )
          : null,
      body: switch (foods) {
        AsyncData(value: final foods) when foods.isEmpty => StatusView(
          icon: Icons.kitchen_rounded,
          title: l10n.myFoodsEmpty,
          message: l10n.myFoodsEmptyText,
          actionLabel: l10n.myFoodsCreate,
          onAction: () => context.push(Routes.newFood()),
        ),
        AsyncData(value: final foods) => ListView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.l,
            Spacing.s,
            Spacing.l,
            Spacing.xl,
          ),
          children: [
            CardGroup(
              children: [for (final food in foods) _OwnFoodRow(food: food)],
            ),
          ],
        ),
        AsyncError() => StatusView(
          icon: Icons.error_outline_rounded,
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
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.foodFormDeleteTitle(food.name),
      message: l10n.foodFormDeleteText,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(productRepositoryProvider).deleteOwnFood(food.id);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.foodFormDeleted(food.name))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FoodTile.food(
      food,
      onTap: () => context.push(Routes.food(food.id)),
      trailing: PopupMenuButton<_FoodAction>(
        tooltip: l10n.myFoodsMore(food.name),
        icon: const Icon(Icons.more_horiz_rounded),
        onSelected: (action) => switch (action) {
          _FoodAction.edit => context.push(Routes.editFood(food.id)),
          _FoodAction.delete => _delete(context, ref),
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: _FoodAction.edit, child: Text(l10n.actionEdit)),
          PopupMenuItem(
            value: _FoodAction.delete,
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}
