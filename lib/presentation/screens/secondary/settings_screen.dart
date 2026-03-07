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

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAppInfo = ref.watch(packageInfoProvider);
    final repository = ref.watch(repositoryProvider);
    final appRouter = ref.watch(appRouterProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // * App Bar
          CustomSliverAppBarScreens(
            tileText: AppLocalizations.of(context)!.settingsAppBarTitle
          ),

         SliverList(
          delegate: SliverChildListDelegate([

            // * Banner for donations
            Dismissible(
              key: UniqueKey(),
              child: const _DonationBanner(),
            ),

            // * Appearance section
            SectionTitle(
              title: AppLocalizations.of(context)!.settingsAppearance,
            ),

            CustomListTile(
              title: AppLocalizations.of(context)!.settingsAppearanceLT1,
              subTitle: AppLocalizations.of(context)!.settingsAppearanceLST1,
              leadingWidget: const Icon(Hicon.paletteBold),
              onTap: () => appRouter.push(AppRoutes.appearanceTheme),
            ),

            const Gap(AppSpacing.lg),

            // * About section
            SectionTitle(
              title: AppLocalizations.of(context)!.settingsAbout,
            ),

            CustomListTile(
              title: packageAppInfo.value?.appName ?? 'Error Package Name',
              subTitle: AppLocalizations.of(context)!.settingsAboutLST1,
              leadingWidget: const Icon(Hicon.stickerBold),
              onTap: () => appRouter.push(AppRoutes.aboutPackage),
            ),

            CustomListTile(
              title: Environment.dashName,
              subTitle: AppLocalizations.of(context)!.settingsAboutLST2,
              leadingWidget: const Icon(Hicon.graphBold),
              onTap: () => appRouter.push(AppRoutes.aboutDashboard),
            ),

            const Gap(AppSpacing.lg),

            // * Legal section
            SectionTitle(
              title: AppLocalizations.of(context)!.settingsLegal,
            ),

            CustomListTile(
              title: AppLocalizations.of(context)!.settingsLegalLT1,
              subTitle: AppLocalizations.of(context)!.settingsLegalLST1,
              leadingWidget: const Icon(Hicon.documentAlignLeft4Bold),
              trailingIcon: Hicon.linkBold,
              onTap: () => repository.launchExternalApp(Environment.externalLinkTermsAndConditions),
            ),

            CustomListTile(
              title: AppLocalizations.of(context)!.settingsLegalLT2,
              subTitle: AppLocalizations.of(context)!.settingsLegalLST2,
              leadingWidget: const Icon(Hicon.documentAlignLeft4Bold),
              trailingIcon: Hicon.linkBold,
              onTap: () => repository.launchExternalApp(Environment.externalLinkPrivacyPolicy),
            ),

            const Gap(AppSpacing.lg),

            // * Licenses section
            SectionTitle(
              title: AppLocalizations.of(context)!.settingsLicences,
            ),

            CustomListTile(
              title: AppLocalizations.of(context)!.settingsLicencesLT1,
              subTitle: AppLocalizations.of(context)!.settingsLicencesLST1,
              leadingWidget: const Icon(Hicon.award2Bold),
              onTap: () => appRouter.push(AppRoutes.licensesOpenSource),
            ),

            const Gap(AppSpacing.lg),

            // * Version information section
            SectionTitle(
              title: AppLocalizations.of(context)!.settingsVersions
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              title: Text(packageAppInfo.value?.appName ?? 'Error Package Name'),
              subtitle: Text(packageAppInfo.value?.packageVersion ?? 'Error Package Version'),
              leading: const Icon(Hicon.informationCircleBold),
            ),

            const ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              title: Text(Environment.dashName),
              subtitle: Text(Environment.dashVersion),
              leading: Icon(Hicon.informationCircleBold),
            ),
          ])
        )
        ],
      ),
    );
  }
}

// * Dismissible donation banner
class _DonationBanner extends ConsumerWidget {
  const _DonationBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(repositoryProvider);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        color: colors.primaryContainer,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Hicon.heart2Bold,
              color: colors.onPrimaryContainer,
            ),

            const Gap(AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    AppLocalizations.of(context)!.donations,
                    style: textStyles.titleMedium!.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),

                  Text(
                    AppLocalizations.of(context)!.donationsNote,
                    style: textStyles.bodySmall!.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),

                  const Gap(AppSpacing.sm),

                  CustomButton.outlined(
                    height: 48,
                    text: AppLocalizations.of(context)!.donationsButton,
                    onPressed: () => repository.launchExternalApp(Environment.externalLinkBuyMeACoffe),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
