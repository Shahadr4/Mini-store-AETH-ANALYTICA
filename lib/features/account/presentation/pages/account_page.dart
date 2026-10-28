import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../provider/theme_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Log out?',
      message: 'You will need to log in again to continue shopping.',
      confirmLabel: 'Log out',
    );
    if (confirmed && context.mounted) {
      // The router sends the user to Login and clears the back stack.
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthProvider, User?>((auth) => auth.user);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProfileHeader(user: user),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null) ...[
                  Text('Profile', style: context.textStyles.titleMedium),
                  const SizedBox(height: AppSpacing.s),
                  _DetailsCard(user: user),
                  const SizedBox(height: AppSpacing.l),
                ],
                Text('Preferences', style: context.textStyles.titleMedium),
                const SizedBox(height: AppSpacing.s),
                const _ThemeCard(),
                const SizedBox(height: AppSpacing.l),
                AppButton(
                  label: 'Logout',
                  icon: Icons.logout_rounded,
                  outlined: true,
                  destructive: true,
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final onPrimary = context.colors.onPrimary;
    return BrandHeader(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.m,
        AppSpacing.screenPadding,
        AppSpacing.l,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account',
                style: context.textStyles.titleLarge!.copyWith(
                  color: onPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Container(
              width: 104,
              height: 104,
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.surface,
                boxShadow: context.softShadow,
              ),
              child: ClipOval(child: AppNetworkImage(url: user?.image)),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              user?.fullName ?? 'Guest',
              style: context.textStyles.titleLarge!.copyWith(color: onPrimary),
            ),
            if (user != null)
              Text(
                '@${user!.username}',
                style: context.captionStyle.copyWith(
                  color: onPrimary.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      children: [
        _InfoTile(
          icon: Icons.person_outline_rounded,
          label: 'Full name',
          value: user.fullName,
        ),
        const Divider(),
        _InfoTile(
          icon: Icons.alternate_email_rounded,
          label: 'Username',
          value: user.username,
        ),
        const Divider(),
        _InfoTile(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: user.email,
        ),
        const Divider(),
        _InfoTile(
          icon: Icons.wc_rounded,
          label: 'Gender',
          value: _capitalize(user.gender),
        ),
      ],
    ),
  );

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.s),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Icon(icon, size: 20, color: context.colors.primary),
      ),
    ),
    title: Text(label, style: context.captionStyle),
    subtitle: Text(value, style: context.textStyles.bodyMedium),
  );
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard();

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Consumer<ThemeProvider>(
      builder: (context, theme, _) => SwitchListTile(
        secondary: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.s),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Icon(
              Icons.dark_mode_outlined,
              size: 20,
              color: context.colors.primary,
            ),
          ),
        ),
        title: const Text('Dark mode'),
        value: theme.mode == ThemeMode.dark,
        onChanged: theme.setDarkMode,
      ),
    ),
  );
}
