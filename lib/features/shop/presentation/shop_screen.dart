import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/coin_chip.dart';
import '../../auth/domain/player_profile.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/shop_item.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  Future<void> _buy(BuildContext context, WidgetRef ref, ShopItem item) async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .purchase(item.id, item.price);
      if (context.mounted) context.showSnack(S.purchased);
    } catch (error) {
      if (context.mounted) context.showError(error);
    }
  }

  void _equip(WidgetRef ref, ShopItem item) {
    final notifier = ref.read(authControllerProvider.notifier);
    if (item.category == ShopCategory.cardSkins) {
      notifier.equipCardSkin(item.id);
    } else if (item.category == ShopCategory.tableThemes) {
      notifier.equipTableTheme(item.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.shopTitle),
        actions: [
          if (profile != null)
            Padding(
              padding: const EdgeInsets.only(right: Insets.m),
              child: Center(child: CoinChip(coins: profile.coins)),
            ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(Insets.l),
                children: [
                  Text(
                    S.shopSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Insets.m),
                  for (final category in ShopCategory.values)
                    _CategorySection(
                      category: category,
                      profile: profile,
                      onBuy: (item) => _buy(context, ref, item),
                      onEquip: (item) => _equip(ref, item),
                    ),
                ],
              ),
            ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.profile,
    required this.onBuy,
    required this.onEquip,
  });
  final ShopCategory category;
  final PlayerProfile profile;
  final ValueChanged<ShopItem> onBuy;
  final ValueChanged<ShopItem> onEquip;

  @override
  Widget build(BuildContext context) {
    final items = Shop.byCategory(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.s),
          child: Text(
            Shop.categoryLabel(category),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisExtent: 176,
            crossAxisSpacing: Insets.s,
            mainAxisSpacing: Insets.s,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final owned = profile.ownedItems.contains(item.id);
            final equipped =
                (item.category == ShopCategory.cardSkins &&
                    profile.cardSkinId == item.id) ||
                (item.category == ShopCategory.tableThemes &&
                    profile.tableThemeId == item.id);
            return _ItemCard(
              item: item,
              owned: owned,
              equipped: equipped,
              affordable: profile.coins >= item.price,
              onBuy: () => onBuy(item),
              onEquip: () => onEquip(item),
            );
          },
        ),
        const SizedBox(height: Insets.m),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.affordable,
    required this.onBuy,
    required this.onEquip,
  });
  final ShopItem item;
  final bool owned;
  final bool equipped;
  final bool affordable;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [item.previewA, item.previewB],
                ),
              ),
              child: Center(
                child: Text(
                  item.emoji ?? '🎁',
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Insets.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: Insets.xs),
                _ActionButton(
                  item: item,
                  owned: owned,
                  equipped: equipped,
                  affordable: affordable,
                  onBuy: onBuy,
                  onEquip: onEquip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.affordable,
    required this.onBuy,
    required this.onEquip,
  });
  final ShopItem item;
  final bool owned;
  final bool equipped;
  final bool affordable;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    if (equipped) {
      return _StatusPill(label: S.equipped, icon: Icons.check_rounded);
    }
    if (owned) {
      if (!item.isEquippable) {
        return _StatusPill(label: S.ownedLabel, icon: Icons.check_rounded);
      }
      return SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: onEquip,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
          child: Text(S.equip),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: affordable ? onBuy : null,
        style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
        child: Text('🪙 ${item.price}'),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Corners.s),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: scheme.onSecondaryContainer),
          const SizedBox(width: Insets.xs),
          Text(label, style: TextStyle(color: scheme.onSecondaryContainer)),
        ],
      ),
    );
  }
}
