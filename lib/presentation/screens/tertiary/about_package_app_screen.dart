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
import 'package:kreator_frame/shared/utils/utils.dart';

class AboutPackageAppScreen extends ConsumerWidget {
  const AboutPackageAppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAppInfo = ref.watch(packageInfoProvider);
    final colors = Theme.of(context).colorScheme;
    final navOps = ref.watch(externalNavigationProvider.notifier);
    final packageName = packageAppInfo.value?.appName ?? 'Error Package Name';


    // * Widget view
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // * App Bar
          CustomSliverAppBarScreens(
            tileText: AppLocalizations.of(context)!.settingsAboutLST1
          ),

          // * Data
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // * Profile header
                ProfileHeader(
                  imagePath: AssetPaths.iconPackageLogo,
                  title: packageName,
                  subtitle: AppLocalizations.of(context)!.byDeveloper(EnvVars.userDeveloperName),
                  showVerifiedBadge: EnvVars.userDeveloperName == AppInfo.appDeveloper,
                ),

                const Gap(AppSpacing.xl),

                // * About Package App
                Text(
                  AppLocalizations.of(context)!.aboutPackage(EnvVars.userDeveloperName, packageName),
                ),

                const Gap(AppSpacing.xl),

                // * Social media links
                SocialMediaButtonList(
                  onTwitterPressed: () {
                    EnvVars.userTwitterUrl != 'NA' && EnvVars.userTwitterUrl != 'Error TWITTER'
                    ? navOps.launchExternalApp(EnvVars.userTwitterUrl)
                    : SnackbarHelpers.showError(
                      context: context,
                      message: AppLocalizations.of(context)!.errorMessage,
                      color: colors
                    );
                  },
                  onInstagramPressed: () {
                    EnvVars.userInstagramUrl != 'NA' && EnvVars.userInstagramUrl != 'Error INSTAGRAM'
                    ? navOps.launchExternalApp(EnvVars.userInstagramUrl)
                    : SnackbarHelpers.showError(
                      context: context,
                      message: AppLocalizations.of(context)!.errorMessage,
                      color: colors
                    );
                  },
                  onPersonalSitePressed: () {
                    EnvVars.userPlayStoreUrl != 'NA' && EnvVars.userPlayStoreUrl != 'Error GOOGLE_PLAY_STORE'
                    ? navOps.launchExternalApp(EnvVars.userPlayStoreUrl)
                    : SnackbarHelpers.showError(
                      context: context,
                      message: AppLocalizations.of(context)!.errorMessage,
                      color: colors
                    );
                  },
                ),

                const Gap(AppSpacing.md),

              ])
            ),
          )

        ],
      ),
    );
  }
}
