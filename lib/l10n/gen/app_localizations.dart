import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'TaskFlow'**
  String get appName;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @tasksTab.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTab;

  /// No description provided for @notificationsTab.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Get Your Tasks Done'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'View your assigned work, track progress, and stay productive on the go.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Stay Organized'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Review task details and checklists, then add optional notes and evidence when you finish.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Secure & Reliable'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in credentials are stored securely. Focus on your assigned work.'**
  String get onboardingDesc3;

  /// No description provided for @authNotReady.
  ///
  /// In en, this message translates to:
  /// **'Authentication API will be implemented in Phase 2.'**
  String get authNotReady;

  /// No description provided for @fieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password.'**
  String get fieldsRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Make TaskFlow yours'**
  String get settingsHeadline;

  /// No description provided for @settingsSubhead.
  ///
  /// In en, this message translates to:
  /// **'Personalize your app appearance and language.'**
  String get settingsSubhead;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose how TaskFlow looks on this device.'**
  String get appearanceHelp;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used in the app.'**
  String get languageHelp;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @legalAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & About'**
  String get legalAboutTitle;

  /// No description provided for @legalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get legalTerms;

  /// No description provided for @legalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get legalPrivacy;

  /// No description provided for @legalAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get legalAbout;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get legalTermsTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalAboutScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'About TaskFlow'**
  String get legalAboutScreenTitle;

  /// No description provided for @legalBrowserHelper.
  ///
  /// In en, this message translates to:
  /// **'Open this page in your browser to view the latest published content.'**
  String get legalBrowserHelper;

  /// No description provided for @legalOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get legalOpenInBrowser;

  /// No description provided for @legalOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this page in a browser.'**
  String get legalOpenFailed;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionTitle;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @uploadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo…'**
  String get uploadingPhoto;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload profile photo.'**
  String get profilePhotoUploadFailed;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarNoTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks on this day'**
  String get calendarNoTasksTitle;

  /// No description provided for @calendarNoTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'Pick another day or swipe to change the month.'**
  String get calendarNoTasksMessage;

  /// No description provided for @calendarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load tasks for this month.'**
  String get calendarLoadError;

  /// No description provided for @calendarOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get calendarOverdue;

  /// No description provided for @calendarDueAt.
  ///
  /// In en, this message translates to:
  /// **'Due {time}'**
  String calendarDueAt(String time);

  /// No description provided for @calendarStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts {time}'**
  String calendarStartsAt(String time);

  /// No description provided for @calendarTaskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tasks} =1{1 task} other{{count} tasks}}'**
  String calendarTaskCount(int count);

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @commentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get commentsEmptyTitle;

  /// No description provided for @commentsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Ask a question or share an update with your supervisor.'**
  String get commentsEmptyMessage;

  /// No description provided for @commentsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load comments.'**
  String get commentsLoadFailed;

  /// No description provided for @commentsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load newer comments'**
  String get commentsLoadMore;

  /// No description provided for @commentsLoadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more. Tap to retry'**
  String get commentsLoadMoreFailed;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment…'**
  String get commentHint;

  /// No description provided for @commentSend.
  ///
  /// In en, this message translates to:
  /// **'Send comment'**
  String get commentSend;

  /// No description provided for @commentSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send your comment. Please try again.'**
  String get commentSendFailed;

  /// No description provided for @commentYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get commentYou;

  /// No description provided for @commentRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get commentRoleAdmin;

  /// No description provided for @commentRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get commentRoleManager;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} min ago}}'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Yesterday} other{{count} days ago}}'**
  String timeDaysAgo(int count);

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Task updates, reminders and comments will appear here.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications.'**
  String get notificationsLoadError;

  /// No description provided for @notificationTaskUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This task is no longer assigned to you.'**
  String get notificationTaskUnavailable;

  /// No description provided for @notificationsUnreadLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Notifications, 1 unread} other{Notifications, {count} unread}}'**
  String notificationsUnreadLabel(int count);

  /// No description provided for @notificationsGroupToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsGroupToday;

  /// No description provided for @notificationsGroupYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsGroupYesterday;

  /// No description provided for @notificationsGroupEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsGroupEarlier;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsMarkAllReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not mark notifications as read. Please try again.'**
  String get notificationsMarkAllReadFailed;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your day at a glance'**
  String get homeHeadline;

  /// No description provided for @homeDueTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get homeDueTodayTitle;

  /// No description provided for @homeDueTodayEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today'**
  String get homeDueTodayEmptyTitle;

  /// No description provided for @homeDueTodayEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You have no unfinished tasks due today.'**
  String get homeDueTodayEmptyMessage;

  /// No description provided for @homeRecentTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent tasks'**
  String get homeRecentTasksTitle;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorOffline;

  /// No description provided for @errorCertificate.
  ///
  /// In en, this message translates to:
  /// **'Secure connection failed.'**
  String get errorCertificate;

  /// No description provided for @errorCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get errorCancelled;

  /// No description provided for @photoTake.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photoTake;

  /// No description provided for @photoChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoChoose;

  /// No description provided for @legalLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this page. Check your connection and retry.'**
  String get legalLoadFailed;

  /// No description provided for @passwordHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Password help'**
  String get passwordHelpTitle;

  /// No description provided for @passwordHelpHeading.
  ///
  /// In en, this message translates to:
  /// **'Password reset is not available in the app yet'**
  String get passwordHelpHeading;

  /// No description provided for @passwordHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Please contact your organization administrator for help accessing your account.'**
  String get passwordHelpBody;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your workspace.'**
  String get loginSubtitle;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @kpiAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get kpiAssigned;

  /// No description provided for @kpiInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get kpiInProgress;

  /// No description provided for @kpiDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get kpiDueToday;

  /// No description provided for @kpiOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get kpiOverdue;

  /// No description provided for @kpiCompletedWeek.
  ///
  /// In en, this message translates to:
  /// **'Completed this week'**
  String get kpiCompletedWeek;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile.'**
  String get profileLoadFailed;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile.'**
  String get profileUpdateFailed;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change password.'**
  String get changePasswordFailed;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get passwordChanged;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @taskActivity.
  ///
  /// In en, this message translates to:
  /// **'Task activity'**
  String get taskActivity;

  /// No description provided for @activeTasks.
  ///
  /// In en, this message translates to:
  /// **'Active tasks'**
  String get activeTasks;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTasks;

  /// No description provided for @completeTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete task'**
  String get completeTaskTitle;

  /// No description provided for @completeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Wrap up your work'**
  String get completeHeadline;

  /// No description provided for @completeSubhead.
  ///
  /// In en, this message translates to:
  /// **'Review the checklist, add any optional evidence, then submit.'**
  String get completeSubhead;

  /// No description provided for @photoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded successfully.'**
  String get photoUploaded;

  /// No description provided for @photoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the photo. Please try again.'**
  String get photoUploadFailed;

  /// No description provided for @filesUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the selected files. Please try again.'**
  String get filesUploadFailed;

  /// No description provided for @filesSelectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not select or upload the files. Please try again.'**
  String get filesSelectFailed;

  /// No description provided for @completeRequiredFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete the required items before submitting.'**
  String get completeRequiredFirst;

  /// No description provided for @submitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit the task. Please try again.'**
  String get submitFailed;

  /// No description provided for @completionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Task completion submitted.'**
  String get completionSubmitted;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksSubhead.
  ///
  /// In en, this message translates to:
  /// **'Your assigned work, all in one place.'**
  String get tasksSubhead;

  /// No description provided for @tasksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get tasksEmptyTitle;

  /// No description provided for @tasksEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tasks assigned to you will show up here.'**
  String get tasksEmptyMessage;

  /// No description provided for @tasksNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching loaded tasks'**
  String get tasksNoMatchTitle;

  /// No description provided for @tasksNoMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter.'**
  String get tasksNoMatchMessage;

  /// No description provided for @tasksRetryLoading.
  ///
  /// In en, this message translates to:
  /// **'Retry loading tasks'**
  String get tasksRetryLoading;

  /// No description provided for @tasksLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get tasksLoadMore;

  /// No description provided for @taskDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get taskDetailsTitle;

  /// No description provided for @noAttachments.
  ///
  /// In en, this message translates to:
  /// **'No attachments yet'**
  String get noAttachments;

  /// No description provided for @attachmentOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this attachment.'**
  String get attachmentOpenFailed;

  /// No description provided for @requiredChecklist.
  ///
  /// In en, this message translates to:
  /// **'Required checklist'**
  String get requiredChecklist;

  /// No description provided for @photosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosTitle;

  /// No description provided for @filesTitle.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get filesTitle;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @addFile.
  ///
  /// In en, this message translates to:
  /// **'Add file'**
  String get addFile;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note about the completed work'**
  String get notesHint;

  /// No description provided for @submitCompletion.
  ///
  /// In en, this message translates to:
  /// **'Submit completion'**
  String get submitCompletion;

  /// No description provided for @waitForUploads.
  ///
  /// In en, this message translates to:
  /// **'Please wait for uploads to finish before submitting.'**
  String get waitForUploads;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @startTask.
  ///
  /// In en, this message translates to:
  /// **'Start task'**
  String get startTask;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dayTomorrow;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueAtTime.
  ///
  /// In en, this message translates to:
  /// **'Due {time}'**
  String dueAtTime(String time);

  /// No description provided for @checklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklistTitle;

  /// No description provided for @taskInformation.
  ///
  /// In en, this message translates to:
  /// **'Task information'**
  String get taskInformation;

  /// No description provided for @deadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadlineLabel;

  /// No description provided for @noDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get noDeadline;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @attachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentsTitle;

  /// No description provided for @completionNotes.
  ///
  /// In en, this message translates to:
  /// **'Completion notes'**
  String get completionNotes;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @statusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get statusAssigned;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @searchTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchTasksHint;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Enter a name with at least 2 characters.'**
  String get nameTooShort;

  /// No description provided for @overdueDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d overdue'**
  String overdueDays(int days);

  /// No description provided for @splashErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the app'**
  String get splashErrorTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Work. Assigned. Done.'**
  String get splashTagline;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your tasks, wherever you are'**
  String get loginTagline;

  /// No description provided for @homeMyProgress.
  ///
  /// In en, this message translates to:
  /// **'My progress'**
  String get homeMyProgress;

  /// No description provided for @homeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeThisWeek;

  /// No description provided for @homeThisWeekValue.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String homeThisWeekValue(int done, int total);

  /// No description provided for @homeThisWeekCaption.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get homeThisWeekCaption;

  /// No description provided for @homeOnTimeRate.
  ///
  /// In en, this message translates to:
  /// **'On-time rate'**
  String get homeOnTimeRate;

  /// No description provided for @homeOnTimeCaption.
  ///
  /// In en, this message translates to:
  /// **'finished before deadline'**
  String get homeOnTimeCaption;

  /// No description provided for @homePriorityBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Priority breakdown'**
  String get homePriorityBreakdown;

  /// No description provided for @homeGreetingNamed.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String homeGreetingNamed(String greeting, String name);

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Getting your workspace ready…'**
  String get splashLoading;

  /// No description provided for @roleWorker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get roleWorker;

  /// No description provided for @profileActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profileActive;

  /// No description provided for @profileInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get profileInactive;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance, legal and session'**
  String get profileSettingsSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
