import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile/profile_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_clone/l10n/app_localizations.dart';
import '../../core/constants/youtube_icons.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      _showCreateBottomSheet(context);
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _YoutubeBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}

class _YoutubeBottomNavBar extends StatelessWidget {
  const _YoutubeBottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAppDark = Theme.of(context).brightness == Brightness.dark;

    // Support user request: if light theme is selected, use light colors even on Shorts.
    // If dark theme is selected, use dark colors.
    // However, usually Shorts stays dark. Let's make it follow the app theme as requested.
    final useDarkTheme =
        isAppDark; // Removed '|| isShorts' to honor light theme choice

    final bgColor = useDarkTheme
        ? Colors.black
        : Theme.of(context).scaffoldBackgroundColor;
    final itemColor = useDarkTheme
        ? Colors.white
        : Theme.of(context).iconTheme.color!;
    final borderColor = useDarkTheme
        ? Colors.grey[800]!
        : Theme.of(context).dividerColor;

    return Container(
      color: bgColor,
      child: SafeArea(
        top: false,
        child: Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: borderColor, width: 0.5)),
          ),
          child: Row(
            children: [
              _NavItem(
                index: 0,
                currentIndex: currentIndex,
                activeIcon: Icons.home,
                inactiveIcon: Icons.home_outlined,
                label: l10n.home,
                isDark: useDarkTheme,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                currentIndex: currentIndex,
                activeSvg: YoutubeIcons.shortsFilled,
                inactiveSvg: YoutubeIcons.shortsOutline,
                label: l10n.shorts,
                isDark: useDarkTheme,
                onTap: onTap,
              ),
              Expanded(
                child: InkWell(
                  onTap: () => onTap(2),
                  child: Center(
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: itemColor, width: 1.2),
                      ),
                      child: Icon(
                        FontAwesomeIcons.plus,
                        size: 24.sp,
                        color: itemColor,
                      ),
                    ),
                  ),
                ),
              ),
              _NavItem(
                index: 3,
                currentIndex: currentIndex,
                activeIcon: Icons.subscriptions,
                inactiveIcon: Icons.subscriptions_outlined,
                label: l10n.subscriptions,
                isDark: useDarkTheme,
                onTap: onTap,
              ),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  String? imagePath;
                  if (state is ProfileLoaded) {
                    imagePath = state.profileImagePath;
                  }
                  return _NavItem(
                    index: 4,
                    currentIndex: currentIndex,
                    activeIcon: FontAwesomeIcons.folder,
                    inactiveIcon: FontAwesomeIcons.folder,
                    avatarUrl: imagePath,
                    isLocalImage: imagePath != null,
                    label: l10n.library,
                    isDark: useDarkTheme,
                    onTap: onTap,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    this.activeIcon,
    this.inactiveIcon,
    this.activeSvg,
    this.inactiveSvg,
    this.avatarUrl,
    this.isLocalImage = false,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final String? activeSvg;
  final String? inactiveSvg;
  final String? avatarUrl;
  final bool isLocalImage;
  final String label;
  final bool isDark;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    final itemColor = isDark
        ? Colors.white
        : Theme.of(context).iconTheme.color!;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (avatarUrl != null)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(color: itemColor, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 13.sp,
                  backgroundImage: isLocalImage
                      ? FileImage(File(avatarUrl!)) as ImageProvider
                      : NetworkImage(
                          avatarUrl ?? 'https://picsum.photos/id/1027/100/100',
                        ),
                ),
              )
            else if (activeSvg != null && inactiveSvg != null)
              SvgPicture.string(
                selected ? activeSvg! : inactiveSvg!,
                height: 24.sp,
                width: 24.sp,
                colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
              )
            else
              Icon(
                selected ? activeIcon : inactiveIcon,
                size: 26.sp,
                color: itemColor,
              ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: itemColor,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateBottomSheet extends StatelessWidget {
  const _CreateBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            _CreateActionItem(
              iconSvg: YoutubeIcons.shortsOutline,
              iconColor: Theme.of(context).iconTheme.color!,
              label: 'Create a Short',
              onTap: () => Navigator.pop(context),
            ),
            _CreateActionItem(
              iconData: FontAwesomeIcons.arrowUpFromBracket,
              iconColor: Theme.of(context).iconTheme.color!,
              label: 'Upload a video',
              onTap: () => Navigator.pop(context),
            ),
            _CreateActionItem(
              iconData: FontAwesomeIcons.satelliteDish,
              iconColor: Theme.of(context).iconTheme.color!,
              label: 'Go Live',
              onTap: () => Navigator.pop(context),
            ),
            _CreateActionItem(
              iconData: FontAwesomeIcons.pen,
              iconColor: Theme.of(context).iconTheme.color!,
              label: 'Create a post',
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _CreateActionItem extends StatelessWidget {
  const _CreateActionItem({
    this.iconData,
    this.iconSvg,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData? iconData;
  final String? iconSvg;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: iconSvg != null
                    ? SvgPicture.string(
                        iconSvg!,
                        width: 22.sp,
                        height: 22.sp,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(iconData, size: 18.sp, color: iconColor),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
