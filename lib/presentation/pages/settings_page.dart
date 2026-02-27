import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_clone/l10n/app_localizations.dart';
import '../bloc/theme/theme_cubit.dart';
import '../bloc/language/language_cubit.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';

class SettingsPage extends StatelessWidget {
  static const route = '/settings';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: TextStyle(fontSize: 18.sp)),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'General'),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return ListTile(
                leading: const Icon(FontAwesomeIcons.circleHalfStroke),
                title: Text(l10n.appearance),
                subtitle: Text(_getThemeName(context, themeMode)),
                onTap: () => _showThemeDialog(context, themeMode),
              );
            },
          ),
          BlocBuilder<LanguageCubit, Locale?>(
            builder: (context, currentLocale) {
              final languageName = currentLocale != null
                  ? context.read<LanguageCubit>().getLanguageName(currentLocale)
                  : 'System Default';
              return ListTile(
                leading: const Icon(FontAwesomeIcons.globe),
                title: Text(l10n.language),
                subtitle: Text(languageName),
                onTap: () => _showLanguageDialog(context, currentLocale),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Account'),
          ListTile(
            leading: const Icon(FontAwesomeIcons.arrowRightFromBracket),
            title: Text(l10n.signOut),
            onTap: () => _showLogoutDialog(context),
          ),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          ListTile(title: const Text('YouTube Terms of Service'), onTap: () {}),
          ListTile(title: const Text('Privacy Policy'), onTap: () {}),
          ListTile(title: const Text('Open source licenses'), onTap: () {}),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'App version: 1.0.0(1)',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.system:
        return l10n.useDeviceTheme;
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
    }
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appearance),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              l10n.useDeviceTheme,
              ThemeMode.system,
              currentMode,
            ),
            _buildThemeOption(
              context,
              l10n.lightTheme,
              ThemeMode.light,
              currentMode,
            ),
            _buildThemeOption(
              context,
              l10n.darkTheme,
              ThemeMode.dark,
              currentMode,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, Locale? currentLocale) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: LanguageCubit.supportedLocales.length,
            itemBuilder: (context, index) {
              final locale = LanguageCubit.supportedLocales[index];
              return _buildLanguageOption(
                context,
                context.read<LanguageCubit>().getLanguageName(locale),
                locale,
                currentLocale ?? const Locale('en'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    Locale locale,
    Locale currentLocale,
  ) {
    return RadioListTile<Locale>(
      title: Text(title),
      value: locale,
      groupValue: currentLocale,
      onChanged: (value) {
        if (value != null) {
          context.read<LanguageCubit>().setLocale(value);
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    ThemeMode mode,
    ThemeMode currentMode,
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: mode,
      groupValue: currentMode,
      onChanged: (value) {
        if (value != null) {
          context.read<ThemeCubit>().setThemeMode(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOut),
        content: const Text(
          'Are you sure you want to sign out?',
        ), // Localize this too if needed
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(context); // Close settings page
            },
            child: Text(
              l10n.signOut.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
