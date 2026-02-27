// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'यूट्यूब क्लोन';

  @override
  String get home => 'होम';

  @override
  String get shorts => 'शॉर्ट्स';

  @override
  String get subscriptions => 'सदस्यता';

  @override
  String get library => 'आप';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get appearance => 'दिखावट';

  @override
  String get language => 'भाषा';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get name => 'नाम';

  @override
  String get handle => 'हैंडल';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get history => 'इतिहास';

  @override
  String get playlists => 'प्लेलिस्ट';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get yourVideos => 'आपके वीडियो';

  @override
  String get downloads => 'डाउनलोड';

  @override
  String get getPremium => 'यूट्यूब प्रीमियम प्राप्त करें';

  @override
  String get timeWatched => 'देखा गया समय';

  @override
  String get helpFeedback => 'सहायता और प्रतिक्रिया';

  @override
  String get search => 'खोजें';

  @override
  String get create => 'बनाएं';

  @override
  String get createShort => 'शॉर्ट बनाएं';

  @override
  String get uploadVideo => 'वीडियो अपलोड करें';

  @override
  String get goLive => 'लाइव जाएं';

  @override
  String get createPost => 'पोस्ट बनाएं';

  @override
  String get switchAccount => 'खाता बदलें';

  @override
  String get googleAccount => 'Google खाता';

  @override
  String get incognito => 'गुप्त मोड चालू करें';

  @override
  String get deleteDownloads => 'डाउनलोड हटाएं';

  @override
  String deleteSelectedVideos(int count) {
    return '$count चयनित वीडियो हटाएं?';
  }

  @override
  String get noDownloadsYet => 'अभी तक कोई डाउनलोड नहीं है';

  @override
  String get videosAppearHere =>
      'आपके द्वारा डाउनलोड किए गए वीडियो यहां दिखाई देंगे';

  @override
  String get availableStorage => 'उपलब्ध संग्रहण';

  @override
  String gbFree(String count) {
    return '$count GB खाली';
  }

  @override
  String get usedByYoutube => 'YouTube द्वारा उपयोग किया गया';

  @override
  String get freeSpace => 'खाली जगह';

  @override
  String get videoEncrypted => 'वीडियो • एन्क्रिप्टेड';

  @override
  String get pause => 'रोकें';

  @override
  String get resume => 'फिर से शुरू करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get useDeviceTheme => 'उपकरण थीम का उपयोग करें';

  @override
  String get lightTheme => 'लाइट थीम';

  @override
  String get darkTheme => 'डार्क थीम';
}
