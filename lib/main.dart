import 'dart:io' show HttpException;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'providers/location_provider.dart';
import 'providers/visit_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/fee_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/favorite_list_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/messaging_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/commission_provider.dart';
import 'providers/review_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  // Afficher un placeholder au lieu d'une erreur pour les images 404 (ex. photos propriétés)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    final ex = details.exception;
    final msg = ex.toString();
    
    // Gestion spécifique des erreurs d'images (404, HttpException)
    if (ex is HttpException ||
        (msg.contains('404') && msg.contains('statusCode')) ||
        (msg.contains('HttpException')) ||
        (msg.contains('NetworkImageLoadException')) ||
        (msg.contains('Failed to load network image'))) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 32,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 4),
              Text(
                'Image non disponible',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Pour les autres erreurs, utiliser le widget d'erreur par défaut
    return ErrorWidget(ex);
  };
  runApp(const FutelaApp());
}

class FutelaApp extends StatelessWidget {
  const FutelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => FeeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteListProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
        ChangeNotifierProvider(create: (_) => CommissionProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Futela',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.lightTheme, // Force le thème clair même en mode sombre
            themeMode: ThemeMode.light, // Force toujours le mode clair
            // Requis pour DatePickerDialog, showDatePicker, etc.
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('fr', 'FR'),
              Locale('en', 'US'),
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
