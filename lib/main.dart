import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'providers/location_provider.dart';
import 'providers/visit_provider.dart';
import 'providers/fee_provider.dart';
import 'providers/favorite_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const FutelaApp());
}

class FutelaApp extends StatelessWidget {
  const FutelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
        ChangeNotifierProvider(create: (_) => FeeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MaterialApp(
        title: 'Futela',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
