import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'welcome_page.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/services/language_service.dart';
import 'features/auth/widgets/session_guard.dart';
import 'features/auth/pages/login_page.dart';
import 'home_menu.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider()..initializeAuth(),
        ),
        ChangeNotifierProvider<LanguageService>(
          create: (_) => LanguageService(),
        ),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'Haim App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            locale: languageService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'), // Español
              Locale('en', 'US'), // Inglés
            ],
            routes: {
              '/': (context) => const SessionGuard(
                child: WelcomePage(),
              ),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const LoginPage(), // Usar LoginPage como fallback
              '/home': (context) => const SessionGuard(
                child: HomeMenu(),
              ),
            },
            onGenerateRoute: (settings) {
              // Manejar rutas no definidas
              if (settings.name == '/welcome') {
                return MaterialPageRoute(
                  builder: (context) => const SessionGuard(
                    child: WelcomePage(),
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
