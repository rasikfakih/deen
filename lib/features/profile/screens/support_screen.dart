import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass/deen_glass_app_bar.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? AppColors.darkBackgroundSemantic
          : AppColors.lightBackground,
      appBar: const DeenGlassAppBar(title: 'Support Deen'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spaceLG,
          kToolbarHeight + AppSpacing.spaceLG,
          AppSpacing.spaceLG,
          100,
        ),
        children: [
          Text(
            'Deen is 100 percent free and open source',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'Maintained by Rasik Fakih',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'There are no ads, no paywalls, and no data selling. Server costs for the Quran CDN, audio streaming, and optional sync are paid out of pocket to keep the app free for everyone, forever.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLG),
          Text(
            'Your support is a Sadaqah Jariyah. Every donation helps us cover infrastructure and keep the project sustainable without ever charging users.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _openUrl('https://github.com/sponsors/rasikfakih'),
              icon: const Icon(Icons.favorite_border),
              label: const Text('Support on GitHub Sponsors'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spaceMD,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _openUrl('https://buy.stripe.com/test_placeholder'),
              icon: const Icon(Icons.payment_outlined),
              label: const Text('Donate via Stripe'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spaceMD,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXL),
          Text(
            'Thank you for helping keep Deen free for every person on earth.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            'JazakAllahu Khairan for your generosity.',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
