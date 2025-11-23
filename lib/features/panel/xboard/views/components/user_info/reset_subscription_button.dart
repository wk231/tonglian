import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/subscription.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class ResetSubscriptionButton extends ConsumerWidget {
  const ResetSubscriptionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return ElevatedButton(
      onPressed: () => Subscription.resetSubscription(context, ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/mine_purchase.png', width: 17, height: 17),
          const SizedBox(width: 6),
          Text(
            t.userInfo.resetSubscription,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
