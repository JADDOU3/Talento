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

  /// No description provided for @yourBasket.
  ///
  /// In en, this message translates to:
  /// **'Your Basket'**
  String get yourBasket;

  /// No description provided for @cartItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String cartItemsCount(int count);

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// No description provided for @cartSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get cartSummary;

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get cartShipping;

  /// No description provided for @cartShippingFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get cartShippingFree;

  /// No description provided for @cartTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get cartTax;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @cartSupportNote.
  ///
  /// In en, this message translates to:
  /// **'Every purchase supports our Re-Forestation partner program.'**
  String get cartSupportNote;

  /// No description provided for @cartDeliveryEstimate.
  ///
  /// In en, this message translates to:
  /// **'Arrives by Thursday — Standard Ground Shipping'**
  String get cartDeliveryEstimate;

  /// No description provided for @promoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promoCode;

  /// No description provided for @enterPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterPromoCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cartRemoveA11y.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get cartRemoveA11y;

  /// No description provided for @badgeAddOn.
  ///
  /// In en, this message translates to:
  /// **'ADD-ON'**
  String get badgeAddOn;

  /// No description provided for @badgeCrossSell.
  ///
  /// In en, this message translates to:
  /// **'CROSS-SELL'**
  String get badgeCrossSell;

  /// No description provided for @cartRec1Title.
  ///
  /// In en, this message translates to:
  /// **'Silk Screen Kit'**
  String get cartRec1Title;

  /// No description provided for @cartRec1Desc.
  ///
  /// In en, this message translates to:
  /// **'Add vibrant layers to your botanical prints with washable inks.'**
  String get cartRec1Desc;

  /// No description provided for @cartRec2Title.
  ///
  /// In en, this message translates to:
  /// **'Microscope 100x'**
  String get cartRec2Title;

  /// No description provided for @cartRec2Desc.
  ///
  /// In en, this message translates to:
  /// **'Zoom deeper into leaves and insects with guided slides.'**
  String get cartRec2Desc;

  /// No description provided for @cartAddAmount.
  ///
  /// In en, this message translates to:
  /// **'Add +{amount}'**
  String cartAddAmount(String amount);

  /// No description provided for @cartLine1Title.
  ///
  /// In en, this message translates to:
  /// **'The Botanist Kit'**
  String get cartLine1Title;

  /// No description provided for @cartLine1Desc.
  ///
  /// In en, this message translates to:
  /// **'Age range: 6–9 years. Seeds, journal, and soil pH strips.'**
  String get cartLine1Desc;

  /// No description provided for @cartLine2Title.
  ///
  /// In en, this message translates to:
  /// **'Avian Architect'**
  String get cartLine2Title;

  /// No description provided for @cartLine2Desc.
  ///
  /// In en, this message translates to:
  /// **'Age range: 8–12 years. Build models and learn flight basics.'**
  String get cartLine2Desc;

  /// No description provided for @cartLine3Title.
  ///
  /// In en, this message translates to:
  /// **'Prism Mastery'**
  String get cartLine3Title;

  /// No description provided for @cartLine3Desc.
  ///
  /// In en, this message translates to:
  /// **'Age range: 9–14 years. Optics lab with prism and light box.'**
  String get cartLine3Desc;

  /// No description provided for @footerInstagram.
  ///
  /// In en, this message translates to:
  /// **'INSTAGRAM'**
  String get footerInstagram;

  /// No description provided for @footerPinterest.
  ///
  /// In en, this message translates to:
  /// **'PINTEREST'**
  String get footerPinterest;

  /// No description provided for @footerLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'LINKEDIN'**
  String get footerLinkedIn;

  /// No description provided for @cartCopyrightLine.
  ///
  /// In en, this message translates to:
  /// **'© 2024 Talento Kids. Rooted in Curiosity.'**
  String get cartCopyrightLine;

  /// No description provided for @nurturingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nurturing Tomorrow\'s Scientists'**
  String get nurturingTitle;

  /// No description provided for @whatsInsideTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s Inside the Laboratory?'**
  String get whatsInsideTitle;

  /// No description provided for @explorerTestimonials.
  ///
  /// In en, this message translates to:
  /// **'Explorer Testimonials'**
  String get explorerTestimonials;

  /// No description provided for @testimonialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hear from parents and young explorers around the world'**
  String get testimonialsSubtitle;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @partnerQuality.
  ///
  /// In en, this message translates to:
  /// **'PARTNER QUALITY'**
  String get partnerQuality;

  /// No description provided for @partnerQualitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built with heirloom-quality materials designed to last for a lifetime of exploration.'**
  String get partnerQualitySubtitle;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'{count} Reviews'**
  String reviews(int count);

  /// No description provided for @kitDetailsCategory.
  ///
  /// In en, this message translates to:
  /// **'NATURE & SCIENCE'**
  String get kitDetailsCategory;

  /// No description provided for @kitDetailsName.
  ///
  /// In en, this message translates to:
  /// **'Botanist Discovery Kit'**
  String get kitDetailsName;

  /// No description provided for @kitDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Thoughtfully curated tools and guides for young botanists to identify specimens, press plants, and explore ecology from the backyard to the field.'**
  String get kitDetailsDescription;

  /// No description provided for @kitDetailsAgeTag.
  ///
  /// In en, this message translates to:
  /// **'AGES 6-12'**
  String get kitDetailsAgeTag;

  /// No description provided for @kitDetailsExperimentsTag.
  ///
  /// In en, this message translates to:
  /// **'15+ EXPERIMENTS'**
  String get kitDetailsExperimentsTag;

  /// No description provided for @kitDetailsPriceCurrent.
  ///
  /// In en, this message translates to:
  /// **'\$84.00'**
  String get kitDetailsPriceCurrent;

  /// No description provided for @kitDetailsPriceOriginal.
  ///
  /// In en, this message translates to:
  /// **'\$110.00'**
  String get kitDetailsPriceOriginal;

  /// No description provided for @mindsetCard1Title.
  ///
  /// In en, this message translates to:
  /// **'Critical Observation'**
  String get mindsetCard1Title;

  /// No description provided for @mindsetCard1Body.
  ///
  /// In en, this message translates to:
  /// **'Train attention to detail and patient recording so children notice patterns in the living world.'**
  String get mindsetCard1Body;

  /// No description provided for @mindsetCard2Title.
  ///
  /// In en, this message translates to:
  /// **'Ecological Literacy'**
  String get mindsetCard2Title;

  /// No description provided for @mindsetCard2Body.
  ///
  /// In en, this message translates to:
  /// **'Connect plants, soil, and habitats so learners understand how ecosystems support one another.'**
  String get mindsetCard2Body;

  /// No description provided for @mindsetCard3Title.
  ///
  /// In en, this message translates to:
  /// **'Laboratory Skills'**
  String get mindsetCard3Title;

  /// No description provided for @mindsetCard3Body.
  ///
  /// In en, this message translates to:
  /// **'Introduce careful handling of tools, specimens, and simple methods used by real scientists.'**
  String get mindsetCard3Body;

  /// No description provided for @kitContent1Title.
  ///
  /// In en, this message translates to:
  /// **'Precision Brass Magnifier'**
  String get kitContent1Title;

  /// No description provided for @kitContent1Desc.
  ///
  /// In en, this message translates to:
  /// **'10x magnification with scratch-resistant glass lenses.'**
  String get kitContent1Desc;

  /// No description provided for @kitContent2Title.
  ///
  /// In en, this message translates to:
  /// **'Canvas Explorer\'s Journal'**
  String get kitContent2Title;

  /// No description provided for @kitContent2Desc.
  ///
  /// In en, this message translates to:
  /// **'Water-resistant pages for field notes and specimen drawings.'**
  String get kitContent2Desc;

  /// No description provided for @kitContent3Title.
  ///
  /// In en, this message translates to:
  /// **'Wooden Plant Press'**
  String get kitContent3Title;

  /// No description provided for @kitContent3Desc.
  ///
  /// In en, this message translates to:
  /// **'Sustainably sourced oak press with adjustable tension straps.'**
  String get kitContent3Desc;

  /// No description provided for @kitContent4Title.
  ///
  /// In en, this message translates to:
  /// **'Specimen Collection Kit'**
  String get kitContent4Title;

  /// No description provided for @kitContent4Desc.
  ///
  /// In en, this message translates to:
  /// **'Includes 12 glass test tubes, tweezers, and labeling stickers.'**
  String get kitContent4Desc;

  /// No description provided for @testimonial1Body.
  ///
  /// In en, this message translates to:
  /// **'This kit turned our weekend walks into real field studies. My daughter now keeps a pressed-leaf journal on her desk.'**
  String get testimonial1Body;

  /// No description provided for @testimonial1Name.
  ///
  /// In en, this message translates to:
  /// **'Sarah Elwick'**
  String get testimonial1Name;

  /// No description provided for @testimonial1Role.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED EXPLORER'**
  String get testimonial1Role;

  /// No description provided for @testimonial2Body.
  ///
  /// In en, this message translates to:
  /// **'Clear guides and durable materials — I use it in my after-school science club and am ordering more for next term.'**
  String get testimonial2Body;

  /// No description provided for @testimonial2Name.
  ///
  /// In en, this message translates to:
  /// **'Mr. Alan Porter'**
  String get testimonial2Name;

  /// No description provided for @testimonial2Role.
  ///
  /// In en, this message translates to:
  /// **'SCIENCE TEACHER'**
  String get testimonial2Role;

  /// No description provided for @kitDetailsAddToCartDemo.
  ///
  /// In en, this message translates to:
  /// **'Preview only — cart is not synced from this screen.'**
  String get kitDetailsAddToCartDemo;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @addToCartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add to cart. Please try again.'**
  String get addToCartFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @verifiedExplorer.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED EXPLORER'**
  String get verifiedExplorer;

  /// No description provided for @mindsetCriteriaPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Develops curiosity, focus, and scientific thinking through guided exploration.'**
  String get mindsetCriteriaPlaceholder;

  /// No description provided for @kitContentItemPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Included in this discovery kit for hands-on learning.'**
  String get kitContentItemPlaceholder;

  /// No description provided for @kitDetailsAgePlus.
  ///
  /// In en, this message translates to:
  /// **'AGES {age}+'**
  String kitDetailsAgePlus(int age);

  /// No description provided for @kitDetailsItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ITEMS'**
  String kitDetailsItemsCount(int count);

  /// No description provided for @kitRatingSummary.
  ///
  /// In en, this message translates to:
  /// **'★ {rating} ({count} Reviews)'**
  String kitRatingSummary(String rating, int count);

  /// No description provided for @profileUserName.
  ///
  /// In en, this message translates to:
  /// **'Sarah'**
  String get profileUserName;

  /// No description provided for @profileChildName.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get profileChildName;

  /// No description provided for @profileWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}.'**
  String profileWelcomeBack(String name);

  /// No description provided for @profileWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your organic laboratory is thriving. Here\'s what {childName} is exploring today.'**
  String profileWelcomeSubtitle(String childName);

  /// No description provided for @profileCuriosityProgress.
  ///
  /// In en, this message translates to:
  /// **'CURIOSITY PROGRESS'**
  String get profileCuriosityProgress;

  /// No description provided for @profileKitTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Forest Discovery Kit'**
  String get profileKitTitle;

  /// No description provided for @profileKitDescription.
  ///
  /// In en, this message translates to:
  /// **'Leo has completed 4 out of 6 botanical experiments. The \'Fungal Networks\' module is waiting to be discovered.'**
  String get profileKitDescription;

  /// No description provided for @profileMasteryReached.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Mastery Reached'**
  String profileMasteryReached(int percent);

  /// No description provided for @profileOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get profileOrderHistory;

  /// No description provided for @profileViewAllOrders.
  ///
  /// In en, this message translates to:
  /// **'View All Orders'**
  String get profileViewAllOrders;

  /// No description provided for @profileOrder1Number.
  ///
  /// In en, this message translates to:
  /// **'#TLN-49202'**
  String get profileOrder1Number;

  /// No description provided for @profileOrder1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Bio-Luminary Kit • Sep 12'**
  String get profileOrder1Subtitle;

  /// No description provided for @profileOrder2Number.
  ///
  /// In en, this message translates to:
  /// **'#TLN-48115'**
  String get profileOrder2Number;

  /// No description provided for @profileOrder2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Botanist Pro • Aug 03'**
  String get profileOrder2Subtitle;

  /// No description provided for @profileOrder3Number.
  ///
  /// In en, this message translates to:
  /// **'#TLN-47088'**
  String get profileOrder3Number;

  /// No description provided for @profileOrder3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Avian Architect • Jun 21'**
  String get profileOrder3Subtitle;

  /// No description provided for @profileDelivered.
  ///
  /// In en, this message translates to:
  /// **'DELIVERED'**
  String get profileDelivered;

  /// No description provided for @profileManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get profileManageSubscription;

  /// No description provided for @profileActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get profileActive;

  /// No description provided for @profilePlanName.
  ///
  /// In en, this message translates to:
  /// **'The Explorer Monthly Plan'**
  String get profilePlanName;

  /// No description provided for @profileNextDelivery.
  ///
  /// In en, this message translates to:
  /// **'Next Delivery: Oct 24, 2024'**
  String get profileNextDelivery;

  /// No description provided for @profileBillingAmount.
  ///
  /// In en, this message translates to:
  /// **'Billing Amount: \$34.00/mo'**
  String get profileBillingAmount;

  /// No description provided for @profilePauseOrUpdate.
  ///
  /// In en, this message translates to:
  /// **'Pause or Update Plan'**
  String get profilePauseOrUpdate;

  /// No description provided for @profileLeosBadges.
  ///
  /// In en, this message translates to:
  /// **'{childName}\'s Badges'**
  String profileLeosBadges(String childName);

  /// No description provided for @profileBadgesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Honors earned through discovery.'**
  String get profileBadgesSubtitle;

  /// No description provided for @profileViewPortfolio.
  ///
  /// In en, this message translates to:
  /// **'VIEW PORTFOLIO →'**
  String get profileViewPortfolio;

  /// No description provided for @profileAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get profileAccountSettings;

  /// No description provided for @profileProfileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileProfileInformation;

  /// No description provided for @profilePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get profilePaymentMethods;

  /// No description provided for @profileShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get profileShippingAddress;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileRecommendedForLeo.
  ///
  /// In en, this message translates to:
  /// **'Recommended for {childName}'**
  String profileRecommendedForLeo(String childName);

  /// No description provided for @profileRec1Badge.
  ///
  /// In en, this message translates to:
  /// **'PHYSICS • AGES 8-12'**
  String get profileRec1Badge;

  /// No description provided for @profileRec1Title.
  ///
  /// In en, this message translates to:
  /// **'The Hydraulics of Growth'**
  String get profileRec1Title;

  /// No description provided for @profileRec2Badge.
  ///
  /// In en, this message translates to:
  /// **'ENGINEERING • AGES 8-12'**
  String get profileRec2Badge;

  /// No description provided for @profileRec2Title.
  ///
  /// In en, this message translates to:
  /// **'Avian Architecture'**
  String get profileRec2Title;

  /// No description provided for @profileRec3Badge.
  ///
  /// In en, this message translates to:
  /// **'NATURE • AGES 6-10'**
  String get profileRec3Badge;

  /// No description provided for @profileRec3Title.
  ///
  /// In en, this message translates to:
  /// **'Tales of the Canopy'**
  String get profileRec3Title;

  /// No description provided for @profileMyAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get profileMyAccount;
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
