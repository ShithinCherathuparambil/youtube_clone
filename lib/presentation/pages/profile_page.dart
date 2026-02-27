import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_clone/l10n/app_localizations.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/usecases/get_playlists.dart';
import '../../injection_container.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/profile/profile_cubit.dart';
import '../bloc/watch_history/watch_history_cubit.dart';
import '../../domain/entities/video.dart';

class ProfilePage extends StatefulWidget {
  static const route = '/library';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Playlist> _playlists = [];
  bool _isLoadingPlaylists = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

  Future<void> _fetchPlaylists() async {
    final getPlaylists = sl<GetPlaylists>();
    final result = await getPlaylists('UC_x5XG1OV2P6uZZ5FSM9Ttw');

    if (!mounted) return;

    result.fold((failure) => setState(() => _isLoadingPlaylists = false), (
      playlists,
    ) {
      setState(() {
        _playlists = playlists;
        _isLoadingPlaylists = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<WatchHistoryCubit>()..loadHistory(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/auth');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          key: const PageStorageKey<String>('profile'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Theme.of(context).iconTheme.color,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.chromecast, size: 22),
                onPressed: () {},
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.bell, size: 22),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 10.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '9+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 22),
                onPressed: () => context.push('/search'),
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.gear, size: 22),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              String name = 'Shithin Cp';
              String handle = '@shithincp1484';
              String? imagePath;

              if (state is ProfileLoaded) {
                name = state.name;
                handle = state.handle;
                imagePath = state.profileImagePath;
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context, name, handle, imagePath),
                    SizedBox(height: 16.h),
                    _buildAccountChips(context),
                    SizedBox(height: 24.h),
                    _buildHistorySection(context),
                    SizedBox(height: 24.h),
                    _buildPlaylistsSection(context),
                    SizedBox(height: 24.h),
                    _buildVideoActions(context),
                    SizedBox(height: 16.h),
                    Divider(height: 1.h, color: Theme.of(context).dividerColor),
                    SizedBox(height: 8.h),
                    _buildPremiumActions(context),
                    SizedBox(height: 40.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String handle,
    String? imagePath,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundImage: imagePath != null
                ? FileImage(File(imagePath)) as ImageProvider
                : const CachedNetworkImageProvider(
                    'https://picsum.photos/id/1027/200/200',
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        handle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.87),
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '  •  ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.87),
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push(
                        '/edit-profile',
                        extra: {
                          'name': name,
                          'handle': handle,
                          'imagePath': imagePath,
                        },
                      ),
                      child: Row(
                        children: [
                          Text(
                            l10n.editProfile,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.87),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16.sp,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withValues(alpha: 0.87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountChips(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildChip(FontAwesomeIcons.idBadge, l10n.switchAccount),
          SizedBox(width: 8.w),
          _buildChip(FontAwesomeIcons.google, l10n.googleAccount),
          SizedBox(width: 8.w),
          _buildChip(FontAwesomeIcons.userSecret, l10n.incognito),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.87),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.history,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  l10n.viewAll,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 180.h,
          child: BlocBuilder<WatchHistoryCubit, WatchHistoryState>(
            builder: (context, state) {
              if (state is WatchHistoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is WatchHistoryLoaded) {
                if (state.history.isEmpty) {
                  return Center(
                    child: Text(
                      'No watch history yet',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: state.history.length,
                  itemBuilder: (context, index) {
                    final video = state.history[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: _buildHistoryVideoCard(video),
                    );
                  },
                );
              }
              if (state is WatchHistoryError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryVideoCard(Video video) {
    return GestureDetector(
      onTap: () => context.push('/watch', extra: video),
      child: SizedBox(
        width: 140.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    height: 80.h,
                    width: 140.w,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 4.h,
                  right: 4.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _formatDuration(video.duration),
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              video.title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              video.channelName,
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds == 0) return '';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildPlaylistsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.playlists,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.plus,
                    size: 20.sp,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      l10n.viewAll,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 160.h,
          child: _isLoadingPlaylists
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlists[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: _buildPlaylistCard(
                        playlist.title,
                        playlist.channelTitle,
                        playlist.thumbnailUrl,
                        FontAwesomeIcons.list,
                        playlist.itemCount.toString(),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPlaylistCard(
    String title,
    String subtitle,
    String imageUrl,
    IconData overlayIcon,
    String overlayText,
  ) {
    return SizedBox(
      width: 160.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 90.h,
                  width: 160.w,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 90.h,
                width: 160.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(overlayIcon, color: Colors.white, size: 24.sp),
                    SizedBox(height: 4.h),
                    Text(
                      overlayText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                FontAwesomeIcons.ellipsisVertical,
                size: 14.sp,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildListTile(FontAwesomeIcons.circlePlay, l10n.yourVideos),
        _buildListTile(
          FontAwesomeIcons.download,
          l10n.downloads,
          onTap: () => context.push('/library/downloads'),
        ),
        _buildListTile(FontAwesomeIcons.film, 'Movies'),
      ],
    );
  }

  Widget _buildPremiumActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildListTile(FontAwesomeIcons.youtube, l10n.getPremium),
        _buildListTile(FontAwesomeIcons.clockRotateLeft, l10n.timeWatched),
        _buildListTile(FontAwesomeIcons.circleQuestion, l10n.helpFeedback),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              SizedBox(
                width: 24.w,
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              SizedBox(width: 20.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
