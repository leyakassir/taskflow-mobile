// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'TaskFlow';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'دخول';

  @override
  String get homeTab => 'الرئيسية';

  @override
  String get tasksTab => 'المهام';

  @override
  String get notificationsTab => 'الإشعارات';

  @override
  String get profileTab => 'الملف الشخصي';

  @override
  String get onboardingTitle1 => 'أنجز مهامك';

  @override
  String get onboardingDesc1 =>
      'اطّلع على مهامك وتابع تقدمك وحافظ على إنتاجيتك أينما كنت.';

  @override
  String get onboardingTitle2 => 'حافظ على تنظيمك';

  @override
  String get onboardingDesc2 =>
      'راجع تفاصيل المهام وقوائم التحقق، وأضف ملاحظاتك وأدلتك الاختيارية عند إتمام العمل.';

  @override
  String get onboardingTitle3 => 'آمن وموثوق';

  @override
  String get onboardingDesc3 =>
      'تُحفظ بيانات تسجيل الدخول بأمان. ركّز على المهام المسندة إليك.';

  @override
  String get authNotReady => 'خدمة تسجيل الدخول غير متاحة حالياً.';

  @override
  String get fieldsRequired => 'يرجى إدخال البريد الإلكتروني وكلمة المرور.';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get genericError => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsHeadline => 'خصص TaskFlow حسب تفضيلاتك';

  @override
  String get settingsSubhead => 'خصص مظهر التطبيق ولغته.';

  @override
  String get appearanceTitle => 'المظهر';

  @override
  String get appearanceHelp => 'اختر مظهر TaskFlow على هذا الجهاز.';

  @override
  String get appearanceSystem => 'النظام';

  @override
  String get appearanceLight => 'فاتح';

  @override
  String get appearanceDark => 'داكن';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageHelp => 'اختر اللغة المستخدمة في التطبيق.';

  @override
  String get languageSystem => 'النظام';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get legalAboutTitle => 'معلومات وشروط';

  @override
  String get legalTerms => 'الشروط';

  @override
  String get legalPrivacy => 'الخصوصية';

  @override
  String get legalAbout => 'حول التطبيق';

  @override
  String get legalTermsTitle => 'شروط الخدمة';

  @override
  String get legalPrivacyTitle => 'سياسة الخصوصية';

  @override
  String get legalAboutScreenTitle => 'حول TaskFlow';

  @override
  String get legalBrowserHelper =>
      'افتح هذه الصفحة في المتصفح للاطلاع على أحدث المحتوى المنشور.';

  @override
  String get legalOpenInBrowser => 'فتح في المتصفح';

  @override
  String get legalOpenFailed => 'تعذر فتح هذه الصفحة في المتصفح.';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get sessionTitle => 'الجلسة';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get changeProfilePhoto => 'تغيير صورة الملف الشخصي';

  @override
  String get uploadingPhoto => 'جارٍ رفع الصورة…';

  @override
  String get profilePhotoUpdated => 'تم تحديث صورة الملف الشخصي.';

  @override
  String get profilePhotoUploadFailed => 'تعذر رفع صورة الملف الشخصي.';

  @override
  String get calendarTitle => 'التقويم';

  @override
  String get calendarNoTasksTitle => 'لا توجد مهام في هذا اليوم';

  @override
  String get calendarNoTasksMessage => 'اختر يوماً آخر أو اسحب لتغيير الشهر.';

  @override
  String get calendarLoadError => 'تعذر تحميل مهام هذا الشهر.';

  @override
  String get calendarOverdue => 'متأخرة';

  @override
  String calendarDueAt(String time) {
    return 'موعد التسليم $time';
  }

  @override
  String calendarStartsAt(String time) {
    return 'تبدأ $time';
  }

  @override
  String calendarTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      many: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: 'لا توجد مهام',
    );
    return '$_temp0';
  }

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get priorityMedium => 'متوسطة';

  @override
  String get priorityHigh => 'عالية';

  @override
  String get priorityUrgent => 'عاجلة';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get commentsTitle => 'التعليقات';

  @override
  String get commentsEmptyTitle => 'لا توجد تعليقات بعد';

  @override
  String get commentsEmptyMessage => 'اطرح سؤالاً أو شارك تحديثاً مع مشرفك.';

  @override
  String get commentsLoadFailed => 'تعذر تحميل التعليقات.';

  @override
  String get commentsLoadMore => 'تحميل التعليقات الأحدث';

  @override
  String get commentsLoadMoreFailed => 'تعذر التحميل. اضغط لإعادة المحاولة';

  @override
  String get commentHint => 'اكتب تعليقاً…';

  @override
  String get commentSend => 'إرسال التعليق';

  @override
  String get commentSendFailed => 'تعذر إرسال تعليقك. حاول مرة أخرى.';

  @override
  String get commentYou => 'أنت';

  @override
  String get commentRoleAdmin => 'مسؤول';

  @override
  String get commentRoleManager => 'مدير';

  @override
  String get timeJustNow => 'الآن';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      few: 'منذ $count دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count ساعة',
      few: 'منذ $count ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوماً',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
      one: 'أمس',
    );
    return '$_temp0';
  }

  @override
  String get notificationsEmptyTitle => 'لا جديد لديك';

  @override
  String get notificationsEmptyMessage =>
      'ستظهر هنا تحديثات المهام والتذكيرات والتعليقات.';

  @override
  String get notificationsLoadError => 'تعذر تحميل الإشعارات.';

  @override
  String get notificationTaskUnavailable => 'لم تعد هذه المهمة مسندة إليك.';

  @override
  String notificationsUnreadLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الإشعارات، $count إشعاراً غير مقروء',
      few: 'الإشعارات، $count إشعارات غير مقروءة',
      two: 'الإشعارات، إشعاران غير مقروءين',
      one: 'الإشعارات، إشعار واحد غير مقروء',
    );
    return '$_temp0';
  }

  @override
  String get notificationsGroupToday => 'اليوم';

  @override
  String get notificationsGroupYesterday => 'أمس';

  @override
  String get notificationsGroupEarlier => 'سابقاً';

  @override
  String get notificationsMarkAllRead => 'تعليم الكل كمقروء';

  @override
  String get notificationsMarkAllReadFailed =>
      'تعذر تعليم الإشعارات كمقروءة. حاول مرة أخرى.';

  @override
  String get homeGreetingMorning => 'صباح الخير';

  @override
  String get homeGreetingAfternoon => 'مساء الخير';

  @override
  String get homeGreetingEvening => 'مساء الخير';

  @override
  String get homeHeadline => 'يومك في لمحة';

  @override
  String get homeDueTodayTitle => 'مستحقة اليوم';

  @override
  String get homeDueTodayEmptyTitle => 'لا شيء مستحق اليوم';

  @override
  String get homeDueTodayEmptyMessage =>
      'ليست لديك مهام غير منجزة مستحقة اليوم.';

  @override
  String get homeRecentTasksTitle => 'المهام الأخيرة';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get errorTitle => 'حدث خطأ ما';

  @override
  String get errorTimeout => 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';

  @override
  String get errorOffline => 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';

  @override
  String get errorCertificate => 'فشل الاتصال الآمن.';

  @override
  String get errorCancelled => 'تم إلغاء الطلب.';

  @override
  String get photoTake => 'التقاط صورة';

  @override
  String get photoChoose => 'اختيار من المعرض';

  @override
  String get legalLoadFailed =>
      'تعذّر تحميل هذه الصفحة. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get passwordHelpTitle => 'مساعدة كلمة المرور';

  @override
  String get passwordHelpHeading =>
      'إعادة تعيين كلمة المرور غير متاحة في التطبيق بعد';

  @override
  String get passwordHelpBody =>
      'يرجى التواصل مع مسؤول مؤسستك للمساعدة في الوصول إلى حسابك.';

  @override
  String get loginWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة إلى مساحة عملك.';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get kpiAssigned => 'مُسندة';

  @override
  String get kpiInProgress => 'قيد التنفيذ';

  @override
  String get kpiDueToday => 'مستحقة اليوم';

  @override
  String get kpiOverdue => 'متأخرة';

  @override
  String get kpiCompletedWeek => 'مكتملة هذا الأسبوع';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get profileLoadFailed => 'تعذّر تحميل الملف الشخصي.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get profileUpdateFailed => 'تعذّر تحديث الملف الشخصي.';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changePasswordFailed => 'تعذّر تغيير كلمة المرور.';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get taskActivity => 'نشاط المهام';

  @override
  String get activeTasks => 'المهام النشطة';

  @override
  String get completedTasks => 'المكتملة';

  @override
  String get completeTaskTitle => 'إنهاء المهمة';

  @override
  String get completeHeadline => 'أنهِ عملك';

  @override
  String get completeSubhead =>
      'راجع قائمة المهام، وأضف أي أدلة اختيارية، ثم أرسل.';

  @override
  String get photoUploaded => 'تم رفع الصورة بنجاح.';

  @override
  String get photoUploadFailed => 'تعذّر رفع الصورة. يرجى المحاولة مرة أخرى.';

  @override
  String get filesUploadFailed =>
      'تعذّر رفع الملفات المحددة. يرجى المحاولة مرة أخرى.';

  @override
  String get filesSelectFailed =>
      'تعذّر اختيار الملفات أو رفعها. يرجى المحاولة مرة أخرى.';

  @override
  String get completeRequiredFirst => 'أكمل العناصر المطلوبة قبل الإرسال.';

  @override
  String get submitFailed => 'تعذّر إرسال المهمة. يرجى المحاولة مرة أخرى.';

  @override
  String get completionSubmitted => 'تم إرسال إنهاء المهمة.';

  @override
  String get tasksTitle => 'المهام';

  @override
  String get tasksSubhead => 'أعمالك المُسندة في مكان واحد.';

  @override
  String get tasksEmptyTitle => 'لا توجد مهام بعد';

  @override
  String get tasksEmptyMessage => 'ستظهر هنا المهام المُسندة إليك.';

  @override
  String get tasksNoMatchTitle => 'لا توجد مهام مطابقة';

  @override
  String get tasksNoMatchMessage => 'جرّب بحثًا أو تصفية مختلفة.';

  @override
  String get tasksRetryLoading => 'إعادة تحميل المهام';

  @override
  String get tasksLoadMore => 'تحميل المزيد';

  @override
  String get taskDetailsTitle => 'تفاصيل المهمة';

  @override
  String get noAttachments => 'لا توجد مرفقات بعد';

  @override
  String get attachmentOpenFailed => 'تعذّر فتح هذا المرفق.';

  @override
  String get requiredChecklist => 'قائمة المهام المطلوبة';

  @override
  String get photosTitle => 'الصور';

  @override
  String get filesTitle => 'الملفات';

  @override
  String get notesTitle => 'الملاحظات';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get addFile => 'إضافة ملف';

  @override
  String get notesHint => 'أضف ملاحظة حول العمل المنجز';

  @override
  String get submitCompletion => 'إرسال الإنهاء';

  @override
  String get waitForUploads => 'يرجى انتظار انتهاء الرفع قبل الإرسال.';

  @override
  String get optional => 'اختياري';

  @override
  String get startTask => 'بدء المهمة';

  @override
  String get dayToday => 'اليوم';

  @override
  String get dayTomorrow => 'غدًا';

  @override
  String get dayYesterday => 'أمس';

  @override
  String get dueTomorrow => 'مستحقة غدًا';

  @override
  String dueAtTime(String time) {
    return 'مستحقة $time';
  }

  @override
  String get checklistTitle => 'قائمة المهام';

  @override
  String get taskInformation => 'معلومات المهمة';

  @override
  String get deadlineLabel => 'الموعد النهائي';

  @override
  String get noDeadline => 'بلا موعد نهائي';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get attachmentsTitle => 'المرفقات';

  @override
  String get completionNotes => 'ملاحظات الإنهاء';

  @override
  String get filterAll => 'الكل';

  @override
  String get statusAssigned => 'مُسندة';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusOverdue => 'متأخرة';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get searchTasksHint => 'ابحث في المهام...';

  @override
  String get nameTooShort => 'أدخل اسمًا لا يقل عن حرفين.';

  @override
  String overdueDays(int days) {
    return 'متأخرة $days يوم';
  }

  @override
  String get splashErrorTitle => 'تعذّر تشغيل التطبيق';

  @override
  String get splashTagline => 'عمل. إسناد. إنجاز.';

  @override
  String get loginTagline => 'أدِر مهامك أينما كنت';

  @override
  String get homeMyProgress => 'تقدّمي';

  @override
  String get homeThisWeek => 'هذا الأسبوع';

  @override
  String homeThisWeekValue(int done, int total) {
    return '$done من $total';
  }

  @override
  String get homeThisWeekCaption => 'مكتملة';

  @override
  String get homeOnTimeRate => 'نسبة الالتزام بالموعد';

  @override
  String get homeOnTimeCaption => 'أُنجزت قبل الموعد';

  @override
  String get homePriorityBreakdown => 'توزيع الأولويات';

  @override
  String homeGreetingNamed(String greeting, String name) {
    return '$greeting، $name';
  }

  @override
  String get splashLoading => 'جارٍ تجهيز مساحة عملك…';

  @override
  String get roleWorker => 'عامل';

  @override
  String get profileActive => 'نشط';

  @override
  String get profileInactive => 'غير نشط';

  @override
  String get profilePreferences => 'التفضيلات';

  @override
  String get profileSettingsSubtitle => 'المظهر والشؤون القانونية والجلسة';
}
