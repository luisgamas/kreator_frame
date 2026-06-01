// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

// 🌎 Project imports:
import 'package:kreator_frame/config/config.dart';
import 'package:kreator_frame/l10n/app_localizations.dart';
import 'package:kreator_frame/presentation/providers/providers.dart';
import 'package:kreator_frame/presentation/widgets/widgets.dart';

class AboutDashboardScreen extends ConsumerWidget {
  const AboutDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;
    final navOps = ref.watch(externalNavigationProvider.notifier);

    // * Widget view
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // * App Bar
          CustomSliverAppBarScreens(
            tileText: AppLocalizations.of(context)!.settingsAboutLST2
          ),

          // * Data
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // * Profile header
                const ProfileHeader(
                  imagePath: Environment.iconDashboardLogo,
                  title: Environment.dashName,
                  subtitle: 'Dashboard',
                  showVerifiedBadge: true,
                ),

                const Gap(AppSpacing.xl),

                // * About Dashboard
                Text(
                  AppLocalizations.of(context)!.aboutDashboard,
                ),

                const Gap(AppSpacing.xl),

                // * Social media links
                SocialMediaButtonList(
                  onTwitterPressed: () =>
                      navOps.launchExternalApp(Environment.externalLinkTwitter),
                  onInstagramPressed: () =>
                      navOps.launchExternalApp(Environment.externalLinkInstagram),
                  onPersonalSitePressed: () =>
                      navOps.launchExternalApp(Environment.externalLinkWebsite),
                ),

                const Gap(AppSpacing.xl),

                // * Copyright
                Text(
                  'Copyright © Luis Gamas - Kreator Frame 2022',
                  style: textStyles.titleSmall,
                  textAlign: TextAlign.center,
                ),

                const Gap(AppSpacing.md),

              ])
            ),
          ),
        ],
      )
    );
  }
}
