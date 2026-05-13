import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>>
      localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  String get welcomeBack;

  String get loginSubtitle;

  String get emailAddress;

  String get password;

  String get confirmPassword;

  String get fullName;

  String get gender;

  String get selectGender;

  String get male;

  String get female;

  String get forgotPassword;

  String get loginButton;

  String get orContinueWith;

  String get dontHaveAccount;

  String get signUp;

  String get createAccount;

  String get signupSubtitle;

  String get signupButton;

  String get alreadyHaveAccount;

  String get logIn;

  String get emailRequired;

  String get passwordRequired;

  String get nameRequired;

  String get confirmPasswordRequired;

  String get passwordsNotMatch;

  String get nurturingTomorrow;

  String get trustedByEducators;

  String get copyright;

  String get aesEncrypted;

  String get coppaCompliant;

  String get gdprSecured;

  String get welcomeBackTitle;

  String get learningGarden;

  String get welcomeBackDesc;

  String get everyChild;

  String get hiddenForest;

  String get untappedPotential;

  String get signupDesc;

  String get google;

  String get apple;

  String get somethingWentWrong;

  String get loginSuccess;

  String get accountCreated;

  String get pleaseSelectGender;

  String get navHome;

  String get navAbout;

  String get navPricing;

  String get navBlog;

  String get navLogin;

  String get navSignUp;

  String get heroBadge;

  String get heroTitle1;

  String get heroTitle2;

  String get heroTitle3;

  String get heroDesc;

  String get heroExplore;

  String get heroLearn;

  String get journeyTitle;

  String get journeySubtitle;

  String get journeyCard1Title;

  String get journeyCard1Desc;

  String get journeyCard2Title;

  String get journeyCard2Desc;

  String get journeyCard3Title;

  String get journeyCard3Desc;

  String get beyondBadge;

  String get beyondTitle;

  String get beyondFeature1Title;

  String get beyondFeature1Desc;

  String get beyondFeature2Title;

  String get beyondFeature2Desc;

  String get beyondFeature3Title;

  String get beyondFeature3Desc;

  String get footerCopyright;

  String get footerSustainability;

  String get footerShipping;

  String get footerReturns;

  String get footerPrivacy;

  String get footerContact;

  String get footerAccessibility;

  String get explorationsTitle;

  String get explorationsSubtitle;

  String get explorationsViewAll;

  String get card1Title;

  String get card1Desc;

  String get card1Button;

  String get card2Title;

  String get card2Desc;

  String get card3Title;

  String get card3Desc;

  String get featuredBadge;

  String get featuredTitle;

  String get featuredDesc;

  String get featuredButton;

  String get language;

  // Cart page
  String get yourBasket;

  String cartItemsCount(int count);

  String get recommendedForYou;

  String get cartSummary;

  String get cartSubtotal;

  String get cartShipping;

  String get cartShippingFree;

  String get cartTax;

  String get cartTotal;

  String get proceedToCheckout;

  String get cartSupportNote;

  String get cartDeliveryEstimate;

  String get promoCode;

  String get enterPromoCode;

  String get apply;

  String get cartRemoveA11y;

  String get badgeAddOn;

  String get badgeCrossSell;

  String get cartRec1Title;

  String get cartRec1Desc;

  String get cartRec2Title;

  String get cartRec2Desc;

  String cartAddAmount(String amount);

  String get cartLine1Title;

  String get cartLine1Desc;

  String get cartLine2Title;

  String get cartLine2Desc;

  String get cartLine3Title;

  String get cartLine3Desc;

  String get footerInstagram;

  String get footerPinterest;

  String get footerLinkedIn;

  String get cartCopyrightLine;

  String get nurturingTitle;

  String get whatsInsideTitle;

  String get explorerTestimonials;

  String get testimonialsSubtitle;

  String get writeReview;

  String get addToCart;

  String get partnerQuality;

  String get partnerQualitySubtitle;

  String reviews(int count);

  String get kitDetailsCategory;

  String get kitDetailsName;

  String get kitDetailsDescription;

  String get kitDetailsAgeTag;

  String get kitDetailsExperimentsTag;

  String get kitDetailsPriceCurrent;

  String get kitDetailsPriceOriginal;

  String get mindsetCard1Title;

  String get mindsetCard1Body;

  String get mindsetCard2Title;

  String get mindsetCard2Body;

  String get mindsetCard3Title;

  String get mindsetCard3Body;

  String get kitContent1Title;

  String get kitContent1Desc;

  String get kitContent2Title;

  String get kitContent2Desc;

  String get kitContent3Title;

  String get kitContent3Desc;

  String get kitContent4Title;

  String get kitContent4Desc;

  String get testimonial1Body;

  String get testimonial1Name;

  String get testimonial1Role;

  String get testimonial2Body;

  String get testimonial2Name;

  String get testimonial2Role;

  String get kitDetailsAddToCartDemo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      lookupAppLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();

    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". '
    'This is likely an issue with the localizations generation tool.',
  );
}