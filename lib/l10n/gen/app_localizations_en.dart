// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TaskFlow';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get homeTab => 'Home';

  @override
  String get tasksTab => 'Tasks';

  @override
  String get notificationsTab => 'Notifications';

  @override
  String get profileTab => 'Profile';

  @override
  String get onboardingTitle1 => 'Get Your Tasks Done';

  @override
  String get onboardingDesc1 =>
      'View your assigned work, track progress, and stay productive on the go.';

  @override
  String get onboardingTitle2 => 'Stay Organized';

  @override
  String get onboardingDesc2 =>
      'Review task details and checklists, then add optional notes and evidence when you finish.';

  @override
  String get onboardingTitle3 => 'Secure & Reliable';

  @override
  String get onboardingDesc3 =>
      'Your sign-in credentials are stored securely. Focus on your assigned work.';

  @override
  String get authNotReady =>
      'Authentication API will be implemented in Phase 2.';

  @override
  String get fieldsRequired => 'Please enter both email and password.';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHeadline => 'Make TaskFlow yours';

  @override
  String get settingsSubhead => 'Personalize your app appearance and language.';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceHelp => 'Choose how TaskFlow looks on this device.';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageHelp => 'Choose the language used in the app.';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get legalAboutTitle => 'Legal & About';

  @override
  String get legalTerms => 'Terms';

  @override
  String get legalPrivacy => 'Privacy';

  @override
  String get legalAbout => 'About';

  @override
  String get legalTermsTitle => 'Terms of service';

  @override
  String get legalPrivacyTitle => 'Privacy policy';

  @override
  String get legalAboutScreenTitle => 'About TaskFlow';

  @override
  String get legalBrowserHelper =>
      'Open this page in your browser to view the latest published content.';

  @override
  String get legalOpenInBrowser => 'Open in browser';

  @override
  String get legalOpenFailed => 'Could not open this page in a browser.';

  @override
  String get accountTitle => 'Account';

  @override
  String get sessionTitle => 'Session';

  @override
  String get logOut => 'Log out';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get uploadingPhoto => 'Uploading photo…';

  @override
  String get profilePhotoUpdated => 'Profile photo updated.';

  @override
  String get profilePhotoUploadFailed => 'Could not upload profile photo.';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarNoTasksTitle => 'No tasks on this day';

  @override
  String get calendarNoTasksMessage =>
      'Pick another day or swipe to change the month.';

  @override
  String get calendarLoadError => 'Could not load tasks for this month.';

  @override
  String get calendarOverdue => 'Overdue';

  @override
  String calendarDueAt(String time) {
    return 'Due $time';
  }

  @override
  String calendarStartsAt(String time) {
    return 'Starts $time';
  }

  @override
  String calendarTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'No tasks',
    );
    return '$_temp0';
  }

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get retry => 'Try again';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsEmptyTitle => 'No comments yet';

  @override
  String get commentsEmptyMessage =>
      'Ask a question or share an update with your supervisor.';

  @override
  String get commentsLoadFailed => 'Could not load comments.';

  @override
  String get commentsLoadMore => 'Load newer comments';

  @override
  String get commentsLoadMoreFailed => 'Couldn\'t load more. Tap to retry';

  @override
  String get commentHint => 'Write a comment…';

  @override
  String get commentSend => 'Send comment';

  @override
  String get commentSendFailed =>
      'Could not send your comment. Please try again.';

  @override
  String get commentYou => 'You';

  @override
  String get commentRoleAdmin => 'Admin';

  @override
  String get commentRoleManager => 'Manager';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'Yesterday',
    );
    return '$_temp0';
  }

  @override
  String get notificationsEmptyTitle => 'You\'re all caught up';

  @override
  String get notificationsEmptyMessage =>
      'Task updates, reminders and comments will appear here.';

  @override
  String get notificationsLoadError => 'Could not load notifications.';

  @override
  String get notificationTaskUnavailable =>
      'This task is no longer assigned to you.';

  @override
  String notificationsUnreadLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications, $count unread',
      one: 'Notifications, 1 unread',
    );
    return '$_temp0';
  }

  @override
  String get notificationsGroupToday => 'Today';

  @override
  String get notificationsGroupYesterday => 'Yesterday';

  @override
  String get notificationsGroupEarlier => 'Earlier';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsMarkAllReadFailed =>
      'Could not mark notifications as read. Please try again.';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeHeadline => 'Your day at a glance';

  @override
  String get homeDueTodayTitle => 'Due today';

  @override
  String get homeDueTodayEmptyTitle => 'Nothing due today';

  @override
  String get homeDueTodayEmptyMessage =>
      'You have no unfinished tasks due today.';

  @override
  String get homeRecentTasksTitle => 'Recent tasks';

  @override
  String get homeViewAll => 'View all';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorTimeout => 'Connection timed out. Please try again.';

  @override
  String get errorOffline =>
      'No internet connection. Please check your network.';

  @override
  String get errorCertificate => 'Secure connection failed.';

  @override
  String get errorCancelled => 'Request cancelled.';

  @override
  String get photoTake => 'Take a photo';

  @override
  String get photoChoose => 'Choose from gallery';

  @override
  String get legalLoadFailed =>
      'Unable to load this page. Check your connection and retry.';

  @override
  String get passwordHelpTitle => 'Password help';

  @override
  String get passwordHelpHeading =>
      'Password reset is not available in the app yet';

  @override
  String get passwordHelpBody =>
      'Please contact your organization administrator for help accessing your account.';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue to your workspace.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get kpiAssigned => 'Assigned';

  @override
  String get kpiInProgress => 'In progress';

  @override
  String get kpiDueToday => 'Due today';

  @override
  String get kpiOverdue => 'Overdue';

  @override
  String get kpiCompletedWeek => 'Completed this week';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get profileLoadFailed => 'Could not load profile.';

  @override
  String get fullName => 'Full name';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get profileUpdateFailed => 'Could not update profile.';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordFailed => 'Could not change password.';

  @override
  String get passwordChanged => 'Password changed.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get taskActivity => 'Task activity';

  @override
  String get activeTasks => 'Active tasks';

  @override
  String get completedTasks => 'Completed';

  @override
  String get completeTaskTitle => 'Complete task';

  @override
  String get completeHeadline => 'Wrap up your work';

  @override
  String get completeSubhead =>
      'Review the checklist, add any optional evidence, then submit.';

  @override
  String get photoUploaded => 'Photo uploaded successfully.';

  @override
  String get photoUploadFailed =>
      'Could not upload the photo. Please try again.';

  @override
  String get filesUploadFailed =>
      'Could not upload the selected files. Please try again.';

  @override
  String get filesSelectFailed =>
      'Could not select or upload the files. Please try again.';

  @override
  String get completeRequiredFirst =>
      'Complete the required items before submitting.';

  @override
  String get submitFailed => 'Could not submit the task. Please try again.';

  @override
  String get completionSubmitted => 'Task completion submitted.';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksSubhead => 'Your assigned work, all in one place.';

  @override
  String get tasksEmptyTitle => 'No tasks yet';

  @override
  String get tasksEmptyMessage => 'Tasks assigned to you will show up here.';

  @override
  String get tasksNoMatchTitle => 'No matching loaded tasks';

  @override
  String get tasksNoMatchMessage => 'Try a different search or filter.';

  @override
  String get tasksRetryLoading => 'Retry loading tasks';

  @override
  String get tasksLoadMore => 'Load more';

  @override
  String get taskDetailsTitle => 'Task details';

  @override
  String get noAttachments => 'No attachments yet';

  @override
  String get attachmentOpenFailed => 'Could not open this attachment.';

  @override
  String get requiredChecklist => 'Required checklist';

  @override
  String get photosTitle => 'Photos';

  @override
  String get filesTitle => 'Files';

  @override
  String get notesTitle => 'Notes';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get addFile => 'Add file';

  @override
  String get notesHint => 'Add a note about the completed work';

  @override
  String get submitCompletion => 'Submit completion';

  @override
  String get waitForUploads =>
      'Please wait for uploads to finish before submitting.';

  @override
  String get optional => 'Optional';

  @override
  String get startTask => 'Start task';

  @override
  String get dayToday => 'Today';

  @override
  String get dayTomorrow => 'Tomorrow';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String dueAtTime(String time) {
    return 'Due $time';
  }

  @override
  String get checklistTitle => 'Checklist';

  @override
  String get taskInformation => 'Task information';

  @override
  String get deadlineLabel => 'Deadline';

  @override
  String get noDeadline => 'No deadline';

  @override
  String get locationLabel => 'Location';

  @override
  String get attachmentsTitle => 'Attachments';

  @override
  String get completionNotes => 'Completion notes';

  @override
  String get filterAll => 'All';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get searchTasksHint => 'Search tasks...';

  @override
  String get nameTooShort => 'Enter a name with at least 2 characters.';

  @override
  String overdueDays(int days) {
    return '${days}d overdue';
  }

  @override
  String get splashErrorTitle => 'Couldn\'t start the app';

  @override
  String get splashTagline => 'Work. Assigned. Done.';

  @override
  String get loginTagline => 'Manage your tasks, wherever you are';

  @override
  String get homeMyProgress => 'My progress';

  @override
  String get homeThisWeek => 'This week';

  @override
  String homeThisWeekValue(int done, int total) {
    return '$done of $total';
  }

  @override
  String get homeThisWeekCaption => 'completed';

  @override
  String get homeOnTimeRate => 'On-time rate';

  @override
  String get homeOnTimeCaption => 'finished before deadline';

  @override
  String get homePriorityBreakdown => 'Priority breakdown';

  @override
  String homeGreetingNamed(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get splashLoading => 'Getting your workspace ready…';

  @override
  String get roleWorker => 'Worker';

  @override
  String get profileActive => 'Active';

  @override
  String get profileInactive => 'Inactive';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileSettingsSubtitle => 'Language, appearance and more';
}
