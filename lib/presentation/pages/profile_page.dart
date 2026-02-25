import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/youtube_icons.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
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
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.gear, size: 22),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              SizedBox(height: 16.h),
              _buildAccountChips(),
              SizedBox(height: 24.h),
              _buildHistorySection(),
              SizedBox(height: 24.h),
              _buildPlaylistsSection(),
              SizedBox(height: 24.h),
              _buildVideoActions(context),
              SizedBox(height: 16.h),
              Divider(height: 1.h, color: Colors.grey[200]),
              SizedBox(height: 8.h),
              _buildPremiumActions(context),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundImage: const CachedNetworkImageProvider(
              'https://picsum.photos/id/1027/200/200',
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shithin Cp',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '@shithincp1484',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '  •  ',
                      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                    ),
                    Text(
                      'View channel',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16.sp,
                      color: Colors.black87,
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

  Widget _buildAccountChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildChip(FontAwesomeIcons.idBadge, 'Switch account'),
          SizedBox(width: 8.w),
          _buildChip(FontAwesomeIcons.google, 'Google Account'),
          SizedBox(width: 8.w),
          _buildChip(FontAwesomeIcons.userSecret, 'Turn on Incognito'),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.black87),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 160.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              _buildHistoryShortCard(
                'Shorts',
                '16 watched',
                'https://picsum.photos/id/237/200/300',
              ),
              SizedBox(width: 12.w),
              _buildHistoryLiveCard(
                '🔴Live Street Food🔴',
                'Chinese Streetfood',
                'https://picsum.photos/id/1080/300/200',
              ),
              SizedBox(width: 12.w),
              _buildHistoryShortCard(
                'Shorts',
                '9 watched',
                'https://picsum.photos/id/1025/200/300',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryShortCard(
    String title,
    String subtitle,
    String imageUrl,
  ) {
    return SizedBox(
      width: 140.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 100.h,
                  width: 140.w,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 6.h,
                right: 6.w,
                child: SvgPicture.string(
                  YoutubeIcons.shortsFilled,
                  width: 18.sp,
                  height: 18.sp,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
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
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
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
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLiveCard(String title, String subtitle, String imageUrl) {
    return SizedBox(
      width: 180.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 100.h,
                  width: 180.w,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 6.h,
                right: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.wifi,
                        color: Colors.white,
                        size: 10.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
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
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Playlists',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Icon(FontAwesomeIcons.plus, size: 20.sp, color: Colors.black),
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
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
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              _buildPlaylistCard(
                'Liked videos',
                'Private',
                'https://picsum.photos/id/292/300/200',
                FontAwesomeIcons.thumbsUp,
                '915',
              ),
              SizedBox(width: 12.w),
              _buildPlaylistCard(
                'Watch later',
                'Private',
                'https://picsum.photos/id/28/300/200',
                FontAwesomeIcons.clock,
                '41',
              ),
            ],
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
                  color: Colors.black.withOpacity(0.5),
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
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
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
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoActions(BuildContext context) {
    return Column(
      children: [
        _buildListTile(FontAwesomeIcons.circlePlay, 'Your videos'),
        _buildListTile(
          FontAwesomeIcons.download,
          'Downloads',
          onTap: () => context.push('/library/downloads'),
        ),
        _buildListTile(FontAwesomeIcons.film, 'Movies'),
      ],
    );
  }

  Widget _buildPremiumActions(BuildContext context) {
    return Column(
      children: [
        _buildListTile(FontAwesomeIcons.youtube, 'Get YouTube Premium'),
        _buildListTile(FontAwesomeIcons.clockRotateLeft, 'Time watched'),
        _buildListTile(FontAwesomeIcons.circleQuestion, 'Help & feedback'),
        _buildListTile(
          FontAwesomeIcons.arrowRightFromBracket,
          'Sign out',
          onTap: () {
            context.read<AuthBloc>().add(LogoutRequested());
          },
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            SizedBox(
              width: 24.w,
              child: Icon(icon, size: 20.sp, color: Colors.black87),
            ),
            SizedBox(width: 20.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
