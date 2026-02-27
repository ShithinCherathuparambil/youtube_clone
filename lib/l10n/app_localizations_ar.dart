// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'يوتيوب كلون';

  @override
  String get home => 'الرئيسية';

  @override
  String get shorts => 'شورتس';

  @override
  String get subscriptions => 'الاشتراكات';

  @override
  String get library => 'أنت';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get name => 'الاسم';

  @override
  String get handle => 'المعرف';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get history => 'السجل';

  @override
  String get playlists => 'قوائم التشغيل';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get yourVideos => 'فيديوهاتك';

  @override
  String get downloads => 'التنزيلات';

  @override
  String get getPremium => 'الحصول على يوتيوب بريميوم';

  @override
  String get timeWatched => 'وقت المشاهدة';

  @override
  String get helpFeedback => 'المساعدة والتعليقات';

  @override
  String get search => 'بحث';

  @override
  String get create => 'إنشاء';

  @override
  String get createShort => 'إنشاء فيديو قصير';

  @override
  String get uploadVideo => 'تحميل فيديو';

  @override
  String get goLive => 'بث مباشر';

  @override
  String get createPost => 'إنشاء مشاركة';

  @override
  String get switchAccount => 'تبديل الحساب';

  @override
  String get googleAccount => 'حساب جوجل';

  @override
  String get incognito => 'تفعيل وضع التصفح المتخفي';

  @override
  String get deleteDownloads => 'حذف التنزيلات';

  @override
  String deleteSelectedVideos(int count) {
    return 'هل تريد حذف $count من الفيديوهات المختارة؟';
  }

  @override
  String get noDownloadsYet => 'لا يوجد تنزيلات بعد';

  @override
  String get videosAppearHere => 'ستظهر الفيديوهات التي قمت بتنزيلها هنا';

  @override
  String get availableStorage => 'المساحة المتوفرة';

  @override
  String gbFree(String count) {
    return '$count جيجابايت متوفرة';
  }

  @override
  String get usedByYoutube => 'مستخدم بواسطة YouTube';

  @override
  String get freeSpace => 'المساحة الحرة';

  @override
  String get videoEncrypted => 'فيديو • مشفر';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get resume => 'استئناف';

  @override
  String get delete => 'حذف';

  @override
  String get useDeviceTheme => 'استخدام ثيم الجهاز';

  @override
  String get lightTheme => 'الثيم الفاتح';

  @override
  String get darkTheme => 'الثيم الغامق';
}
