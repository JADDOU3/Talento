// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cubits/cart/cart_cubit.dart';
import 'cubits/kit/kit_cubit.dart';
import 'cubits/reviews/kit_reviews_cubit.dart';
import 'shared/providers/language_provider.dart';
import 'shared/i18n/app_localizations.dart';
import 'shared/services/auth_state.dart'; // ✅ Import AuthState
import 'features/home/pages/home_page.dart';
import 'features/catalog/pages/catalog_page.dart';
import 'features/catalog/pages/kit_details_page.dart';
import 'features/cart/pages/cart_page.dart';
import 'features/profile/pages/profile_page.dart';
import 'util/theme/app_colors.dart';
import 'features/blog/pages/blog_page.dart';
import 'features/blog/pages/blog_post_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ IMPORTANT: Load saved auth state before the app starts
  await AuthState.instance.refresh();

  runApp(
    MultiProvider(
      providers: [
        // ✅ Provide AuthState so it can be accessed anywhere
        ChangeNotifierProvider(create: (_) => AuthState.instance),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const TalentoApp(),
    ),
  );
}

class TalentoApp extends StatelessWidget {
  const TalentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.locale.languageCode == 'ar';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => KitCubit()),
        BlocProvider(create: (_) => CartCubit()..loadCart()),
        BlocProvider(create: (_) => KitReviewsCubit()),
      ],
      child: MaterialApp(
        title: 'Talento',
        debugShowCheckedModeBanner: false,
        locale: languageProvider.locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.cartTeal,
            primary: AppColors.cartTeal,
            secondary: AppColors.secondary,
            tertiary: AppColors.yellow,
          ),
          textTheme: (isArabic
              ? GoogleFonts.cairoTextTheme()
              : GoogleFonts.fredokaTextTheme())
              .apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
          cardTheme: const CardThemeData(
            color: AppColors.cardBackground,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/blog': (context) => const BlogPage(),
          '/blog-post': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final postId = args is String ? args : 'our-story';
            return BlogPostPage(postId: postId);
          },
          '/': (context) => const HomePage(),
          '/home': (context) => const HomePage(),
          '/catalog': (context) => const CatalogPage(),
          '/cart': (context) => const CartPage(),
          '/profile': (context) => const ProfilePage(),
          '/kit-details': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final kitId = args is int ? args : 1;

            final kitCubit = context.read<KitCubit>();
            kitCubit.getKitById(kitId);

            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: kitCubit),
                BlocProvider(
                  create: (_) => KitReviewsCubit()..loadForKit(kitId),
                ),
              ],
              child: KitDetailsPage(kitId: kitId),
            );
          },
        },
      ),
    );
  }
}