// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'YouTube Clone';

  @override
  String get home => 'Home';

  @override
  String get shorts => 'Shorts';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get library => 'You';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get signOut => 'Sign out';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get name => 'Name';

  @override
  String get handle => 'Handle';

  @override
  String get save => 'SAVE';

  @override
  String get cancel => 'CANCEL';

  @override
  String get history => 'History';

  @override
  String get playlists => 'Playlists';

  @override
  String get viewAll => 'View all';

  @override
  String get yourVideos => 'Your videos';

  @override
  String get downloads => 'Downloads';

  @override
  String get getPremium => 'Get YouTube Premium';

  @override
  String get timeWatched => 'Time watched';

  @override
  String get helpFeedback => 'Help & feedback';

  @override
  String get search => 'Search';

  @override
  String get create => 'Create';

  @override
  String get createShort => 'Create a Short';

  @override
  String get uploadVideo => 'Upload a video';

  @override
  String get goLive => 'Go Live';

  @override
  String get createPost => 'Create a post';

  @override
  String get switchAccount => 'Switch account';

  @override
  String get googleAccount => 'Google Account';

  @override
  String get incognito => 'Turn on Incognito';

  @override
  String get deleteDownloads => 'Delete Downloads';

  @override
  String deleteSelectedVideos(int count) {
    return 'Delete $count selected videos?';
  }

  @override
  String get noDownloadsYet => 'No downloads yet';

  @override
  String get videosAppearHere => 'Videos you download will appear here';

  @override
  String get availableStorage => 'Available Storage';

  @override
  String gbFree(String count) {
    return '$count GB Free';
  }

  @override
  String get usedByYoutube => 'Used by YouTube';

  @override
  String get freeSpace => 'Free Space';

  @override
  String get videoEncrypted => 'Video • Encrypted';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get delete => 'Delete';

  @override
  String get useDeviceTheme => 'Use device theme';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';
}
