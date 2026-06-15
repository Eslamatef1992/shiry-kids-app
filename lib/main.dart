import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/cart_provider.dart';
import 'providers/locale_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/new_password_screen.dart';
import 'screens/location_permission_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // firebase_messaging plugin requires Firebase to be initialized on the Dart
  // side even if push notifications are not actively used; without this call
  // the plugin crashes at startup with "No Firebase App '[DEFAULT]'".
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  // Make build-time errors visible on-screen (in red) instead of rendering
  // as a blank/invisible area. This makes silent layout/render failures
  // (e.g. a widget subtree throwing during build) easy to diagnose without
  // needing console access.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Text(
          'Render error:\n${details.exceptionAsString()}',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  };
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ShiryKidsApp());
}

class ShiryKidsApp extends StatelessWidget {
  const ShiryKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadSavedLocale()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: 'Shiry Kids',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: localeProvider.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,

            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/otp': (_) => const OtpScreen(),
            '/forgot-password': (_) => const ForgotPasswordScreen(),
            '/new-password': (_) => const NewPasswordScreen(),
            '/location': (_) => const LocationPermissionScreen(),
            '/home': (_) => const MainShell(),
          },
        ),
      ),
    );
  }
}
