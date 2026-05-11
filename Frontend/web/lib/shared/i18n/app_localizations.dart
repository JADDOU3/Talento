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
/// import 'i18n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account to continue.'**
  String get loginSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullName;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'GENDER'**
  String get gender;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Enter the Forest (Login) →'**
  String get loginButton;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your child\'s learning journey today.'**
  String get signupSubtitle;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Plant the Seed (Sign Up) →'**
  String get signupButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @nurturingTomorrow.
  ///
  /// In en, this message translates to:
  /// **'NURTURING TOMORROW'**
  String get nurturingTomorrow;

  /// No description provided for @trustedByEducators.
  ///
  /// In en, this message translates to:
  /// **'4.9/5  •  Trusted by global educators'**
  String get trustedByEducators;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 TALENTO KIDS'**
  String get copyright;

  /// No description provided for @aesEncrypted.
  ///
  /// In en, this message translates to:
  /// **'AES-256 ENCRYPTED'**
  String get aesEncrypted;

  /// No description provided for @coppaCompliant.
  ///
  /// In en, this message translates to:
  /// **'COPPA COMPLIANT'**
  String get coppaCompliant;

  /// No description provided for @gdprSecured.
  ///
  /// In en, this message translates to:
  /// **'GDPR SECURED'**
  String get gdprSecured;

  /// No description provided for @welcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to your'**
  String get welcomeBackTitle;

  /// No description provided for @learningGarden.
  ///
  /// In en, this message translates to:
  /// **'learning garden.'**
  String get learningGarden;

  /// No description provided for @welcomeBackDesc.
  ///
  /// In en, this message translates to:
  /// **'Continue cultivating curiosity and resilience through our research-backed pedagogical ecosystem.'**
  String get welcomeBackDesc;

  /// No description provided for @everyChild.
  ///
  /// In en, this message translates to:
  /// **'Every child is a '**
  String get everyChild;

  /// No description provided for @hiddenForest.
  ///
  /// In en, this message translates to:
  /// **'hidden forest'**
  String get hiddenForest;

  /// No description provided for @untappedPotential.
  ///
  /// In en, this message translates to:
  /// **'of untapped potential.'**
  String get untappedPotential;

  /// No description provided for @signupDesc.
  ///
  /// In en, this message translates to:
  /// **'Join over 50,000 families cultivating curiosity and resilience through our research-backed pedagogical ecosystem.'**
  String get signupDesc;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreated;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender'**
  String get pleaseSelectGender;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @navPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get navPricing;

  /// No description provided for @navBlog.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get navBlog;

  /// No description provided for @navLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get navLogin;

  /// No description provided for @navSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get navSignUp;

  /// No description provided for @heroBadge.
  ///
  /// In en, this message translates to:
  /// **'UNLOCKING CHILDHOOD POTENTIAL'**
  String get heroBadge;

  /// No description provided for @heroTitle1.
  ///
  /// In en, this message translates to:
  /// **'Nurture the'**
  String get heroTitle1;

  /// No description provided for @heroTitle2.
  ///
  /// In en, this message translates to:
  /// **'Genius'**
  String get heroTitle2;

  /// No description provided for @heroTitle3.
  ///
  /// In en, this message translates to:
  /// **'Within.'**
  String get heroTitle3;

  /// No description provided for @heroDesc.
  ///
  /// In en, this message translates to:
  /// **'Thoughtfully curated kits designed by educators to spark lifelong curiosity, critical thinking, and a love for the natural world.'**
  String get heroDesc;

  /// No description provided for @heroExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Kits'**
  String get heroExplore;

  /// No description provided for @heroLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn Our Story'**
  String get heroLearn;

  /// No description provided for @journeyTitle.
  ///
  /// In en, this message translates to:
  /// **'How Your Journey Begins'**
  String get journeyTitle;

  /// No description provided for @journeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We simplify the science of learning into three organic steps for families.'**
  String get journeySubtitle;

  /// No description provided for @journeyCard1Title.
  ///
  /// In en, this message translates to:
  /// **'Select Your Theme'**
  String get journeyCard1Title;

  /// No description provided for @journeyCard1Desc.
  ///
  /// In en, this message translates to:
  /// **'Choose from Biology, Engineering, or Fine Arts curated for specific age milestones.'**
  String get journeyCard1Desc;

  /// No description provided for @journeyCard2Title.
  ///
  /// In en, this message translates to:
  /// **'Delivered Monthly'**
  String get journeyCard2Title;

  /// No description provided for @journeyCard2Desc.
  ///
  /// In en, this message translates to:
  /// **'Eco-friendly kits arrive at your doorstep packed with everything needed for discovery.'**
  String get journeyCard2Desc;

  /// No description provided for @journeyCard3Title.
  ///
  /// In en, this message translates to:
  /// **'Guided Exploration'**
  String get journeyCard3Title;

  /// No description provided for @journeyCard3Desc.
  ///
  /// In en, this message translates to:
  /// **'Interactive guides help parents and kids bond over experiments and storytelling.'**
  String get journeyCard3Desc;

  /// No description provided for @beyondBadge.
  ///
  /// In en, this message translates to:
  /// **'MINDSET DISCOVERY'**
  String get beyondBadge;

  /// No description provided for @beyondTitle.
  ///
  /// In en, this message translates to:
  /// **'Beyond Knowledge.\nBuilding Character.'**
  String get beyondTitle;

  /// No description provided for @beyondFeature1Title.
  ///
  /// In en, this message translates to:
  /// **'Growth Mindset'**
  String get beyondFeature1Title;

  /// No description provided for @beyondFeature1Desc.
  ///
  /// In en, this message translates to:
  /// **'We teach children that mistakes are just another step in the grand experiment of learning.'**
  String get beyondFeature1Desc;

  /// No description provided for @beyondFeature2Title.
  ///
  /// In en, this message translates to:
  /// **'Nature Connection'**
  String get beyondFeature2Title;

  /// No description provided for @beyondFeature2Desc.
  ///
  /// In en, this message translates to:
  /// **'Materials are sourced ethically, teaching kids to respect the forest as much as they learn from it.'**
  String get beyondFeature2Desc;

  /// No description provided for @beyondFeature3Title.
  ///
  /// In en, this message translates to:
  /// **'Critical Reasoning'**
  String get beyondFeature3Title;

  /// No description provided for @beyondFeature3Desc.
  ///
  /// In en, this message translates to:
  /// **'Our kits don\'t give answers; they provide the tools for children to ask the right questions.'**
  String get beyondFeature3Desc;

  /// No description provided for @footerCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 TALENTO KIDS. ROOTED IN CURIOSITY.'**
  String get footerCopyright;

  /// No description provided for @footerSustainability.
  ///
  /// In en, this message translates to:
  /// **'SUSTAINABILITY'**
  String get footerSustainability;

  /// No description provided for @footerShipping.
  ///
  /// In en, this message translates to:
  /// **'SHIPPING'**
  String get footerShipping;

  /// No description provided for @footerReturns.
  ///
  /// In en, this message translates to:
  /// **'RETURNS'**
  String get footerReturns;

  /// No description provided for @footerPrivacy.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY POLICY'**
  String get footerPrivacy;

  /// No description provided for @footerContact.
  ///
  /// In en, this message translates to:
  /// **'CONTACT US'**
  String get footerContact;

  /// No description provided for @footerAccessibility.
  ///
  /// In en, this message translates to:
  /// **'ACCESSIBILITY'**
  String get footerAccessibility;

  /// No description provided for @explorationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Curated Explorations'**
  String get explorationsTitle;

  /// No description provided for @explorationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Our most loved kits this season.'**
  String get explorationsSubtitle;

  /// No description provided for @explorationsViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All Kits'**
  String get explorationsViewAll;

  /// No description provided for @card1Title.
  ///
  /// In en, this message translates to:
  /// **'The Botanist Pro'**
  String get card1Title;

  /// No description provided for @card1Desc.
  ///
  /// In en, this message translates to:
  /// **'Discover the secrets of the forest floor through seed preservation and soil analysis.'**
  String get card1Desc;

  /// No description provided for @card1Button.
  ///
  /// In en, this message translates to:
  /// **'Get This Kit'**
  String get card1Button;

  /// No description provided for @card2Title.
  ///
  /// In en, this message translates to:
  /// **'Avian Architect'**
  String get card2Title;

  /// No description provided for @card2Desc.
  ///
  /// In en, this message translates to:
  /// **'Build, paint, and observe. A first look into structural engineering and wildlife.'**
  String get card2Desc;

  /// No description provided for @card3Title.
  ///
  /// In en, this message translates to:
  /// **'Prism Mastery'**
  String get card3Title;

  /// No description provided for @card3Desc.
  ///
  /// In en, this message translates to:
  /// **'Unlock the physics of light and color with our experimental optics kit.'**
  String get card3Desc;

  /// No description provided for @featuredBadge.
  ///
  /// In en, this message translates to:
  /// **'THE EDUCATORS CHOICE'**
  String get featuredBadge;

  /// No description provided for @featuredTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Talent\nLibrary'**
  String get featuredTitle;

  /// No description provided for @featuredDesc.
  ///
  /// In en, this message translates to:
  /// **'Access our full curriculum of 24 kits delivered over two years of developmental growth.'**
  String get featuredDesc;

  /// No description provided for @featuredButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe & Save 20%'**
  String get featuredButton;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get language;
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
