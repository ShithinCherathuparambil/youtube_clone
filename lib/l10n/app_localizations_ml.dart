// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'യൂട്യൂബ് ക്ലോൺ';

  @override
  String get home => 'ഹോം';

  @override
  String get shorts => 'ഷോർട്ട്സ്';

  @override
  String get subscriptions => 'സബ്സ്ക്രിപ്ഷനുകൾ';

  @override
  String get library => 'നിങ്ങൾ';

  @override
  String get settings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get appearance => 'കാഴ്ച';

  @override
  String get language => 'ഭാഷ';

  @override
  String get signOut => 'പുറത്തുകടക്കുക';

  @override
  String get editProfile => 'പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യുക';

  @override
  String get name => 'പേര്';

  @override
  String get handle => 'ഹാൻഡിൽ';

  @override
  String get save => 'സേവ് ചെയ്യുക';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get history => 'ചരിത്രം';

  @override
  String get playlists => 'പ്ലേലിസ്റ്റുകൾ';

  @override
  String get viewAll => 'എല്ലാം കാണുക';

  @override
  String get yourVideos => 'നിങ്ങളുടെ വീഡിയോകൾ';

  @override
  String get downloads => 'ഡൗൺലോഡുകൾ';

  @override
  String get getPremium => 'യൂട്യൂബ് പ്രീമിയം നേടുക';

  @override
  String get timeWatched => 'കണ്ട സമയം';

  @override
  String get helpFeedback => 'സഹായവും ഫീഡ്‌ബാക്കും';

  @override
  String get search => 'തിരയുക';

  @override
  String get create => 'ഉണ്ടാക്കുക';

  @override
  String get createShort => 'ഒരു ഷോർട്ട് ഉണ്ടാക്കുക';

  @override
  String get uploadVideo => 'ഒരു വീഡിയോ അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get goLive => 'ലൈവ് പോകുക';

  @override
  String get createPost => 'ഒരു പോസ്റ്റ് സൃഷ്ടിക്കുക';

  @override
  String get switchAccount => 'അക്കൗണ്ട് മാറ്റുക';

  @override
  String get googleAccount => 'ഗൂഗിൾ അക്കൗണ്ട്';

  @override
  String get incognito => 'ഇൻകോഗ്നിറ്റോ ഓൺ ചെയ്യുക';

  @override
  String get deleteDownloads => 'ഡൗൺലോഡുകൾ നീക്കംചെയ്യുക';

  @override
  String deleteSelectedVideos(int count) {
    return '$count തിരഞ്ഞെടുത്ത വീഡിയോകൾ ഇല്ലാതാക്കണോ?';
  }

  @override
  String get noDownloadsYet => 'ഡൗൺലോഡുകൾ ഒന്നുമില്ല';

  @override
  String get videosAppearHere =>
      'നിങ്ങൾ ഡൗൺലോഡ് ചെയ്യുന്ന വീഡിയോകൾ ഇവിടെ കാണാം';

  @override
  String get availableStorage => 'ലഭ്യമായ സ്റ്റോറേജ്';

  @override
  String gbFree(String count) {
    return '$count GB ബാക്കിയുണ്ട്';
  }

  @override
  String get usedByYoutube => 'YouTube ഉപയോഗിക്കുന്നത്';

  @override
  String get freeSpace => 'ബാക്കിയുള്ള സ്ഥലം';

  @override
  String get videoEncrypted => 'വീഡിയോ • എൻക്രിപ്റ്റ് ചെയ്തത്';

  @override
  String get pause => 'നിർത്തുക';

  @override
  String get resume => 'തുടരുക';

  @override
  String get delete => 'നീക്കംചെയ്യുക';

  @override
  String get useDeviceTheme => 'ഉപകരണ തീം ഉപയോഗിക്കുക';

  @override
  String get lightTheme => 'ലൈറ്റ് തീം';

  @override
  String get darkTheme => 'ഡാർക്ക് തീം';
}
