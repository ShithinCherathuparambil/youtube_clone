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
import '../bloc/download/download_manager_cubit.dart';
import '../bloc/download/download_manager_state.dart';
import '../../domain/entities/download_item.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
        builder: (context, downloadState) {
          final activeDownloads = downloadState.downloads
              .where(
                (d) =>
                    d.status == DownloadStatus.downloading ||
                    d.status == DownloadStatus.encrypting,
              )
              .length;

          return BottomNavigationBar(
            currentIndex: currentIndex > 2
                ? currentIndex
                : (currentIndex < 2
                      ? currentIndex
                      : 0), // Adjust for the center "+" button which isn't a real nav item in the bar
            // Actually, the currentIndex from navigationShell includes the "add" branch if defined.
            // Let's look at the Row implementation and reproduce it.
            // The shell has branches: 0:Home, 1:Shorts, 2:Add, 3:Subs, 4:Library

            // Re-evaluating: Material BottomNavigationBar doesn't easily support a custom center button in the middle of items.
            // However, the task was to "Refactor to use BottomNavigationBar widget".
            // If I use BottomNavigationBar, I might have to handle the "Add" button differently or use a custom Row but call it BottomNavigationBar?
            // No, usually BottomNavigationBar is preferred for accessibility.
            // I'll use a custom Row but ensure it follows the standards, OR I'll use BottomNavigationBar and accept the "Add" as an item.
            // YouTube actually has "Add" as a center item.

            // Let's stick to the Row-based custom implementation but make it look and feel like a standard one with better state management.
            // Wait, I promised "Refactor to use BottomNavigationBar widget".
            // I'll use a BottomNavigationBar with 5 items, and the middle one will be "Create".
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 11.sp,
            unselectedFontSize: 11.sp,
            selectedItemColor: isDark ? Colors.white : theme.iconTheme.color,
            unselectedItemColor: isDark ? Colors.white : theme.iconTheme.color,
            backgroundColor: isDark
                ? Colors.black
                : theme.scaffoldBackgroundColor,
            onTap: onTap,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 26.sp),
                activeIcon: Icon(Icons.home, size: 26.sp),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.string(
                  YoutubeIcons.shortsOutline,
                  height: 24.sp,
                  width: 24.sp,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : theme.iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
                activeIcon: SvgPicture.string(
                  YoutubeIcons.shortsFilled,
                  height: 24.sp,
                  width: 24.sp,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : theme.iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
                label: l10n.shorts,
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white : theme.iconTheme.color!,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    FontAwesomeIcons.plus,
                    size: 22.sp,
                    color: isDark ? Colors.white : theme.iconTheme.color,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.subscriptions_outlined, size: 24.sp),
                activeIcon: Icon(Icons.subscriptions, size: 24.sp),
                label: l10n.subscriptions,
              ),
              BottomNavigationBarItem(
                icon: Badge.count(
                  count: activeDownloads,
                  isLabelVisible: activeDownloads > 0,
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, profileState) {
                      String? imagePath;
                      if (profileState is ProfileLoaded) {
                        imagePath = profileState.profileImagePath;
                      }
                      if (imagePath != null) {
                        return CircleAvatar(
                          radius: 13.r,
                          backgroundImage: FileImage(File(imagePath)),
                        );
                      }
                      return Icon(FontAwesomeIcons.folder, size: 22.sp);
                    },
                  ),
                ),
                activeIcon: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, profileState) {
                    String? imagePath;
                    if (profileState is ProfileLoaded) {
                      imagePath = profileState.profileImagePath;
                    }
                    if (imagePath != null) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.white
                                : theme.iconTheme.color!,
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 11.5.r,
                          backgroundImage: FileImage(File(imagePath)),
                        ),
                      );
                    }
                    return Icon(FontAwesomeIcons.folder, size: 22.sp);
                  },
                ),
                label: l10n.library,
              ),
            ],
          );
        },
      ),
    );
  }
}

// _NavItem removed in favor of BottomNavigationBarItem

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
