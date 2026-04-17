import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/futela_logo.dart';
import '../../widgets/social_login_buttons.dart';
import '../../widgets/error_dialog.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../auth/profile_completion_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      _loginController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ProfileCompletionWrapper()),
      );
    } else if (mounted) {
      final errorMessage = authProvider.error ?? 'Erreur de connexion';

      // Détection du type d'erreur
      if (errorMessage.contains('connection') ||
          errorMessage.contains('connexion') ||
          errorMessage.contains('network') ||
          errorMessage.contains('réseau') ||
          errorMessage.contains('Failed host lookup')) {
        // Erreur de connexion réseau
        await ErrorDialog.showNetworkError(context);
      } else if (errorMessage.contains('timeout') ||
          errorMessage.contains('took longer') ||
          errorMessage.contains('délai') ||
          errorMessage.contains('aborted')) {
        // Erreur de timeout
        await ErrorDialog.showTimeoutError(context);
      } else if (errorMessage.contains('credentials') ||
          errorMessage.contains('identifiants') ||
          errorMessage.contains('Invalid') ||
          errorMessage.contains('password') ||
          errorMessage.contains('email') ||
          errorMessage.contains('401') ||
          errorMessage.contains('Unauthorized')) {
        // Erreur d'authentification
        await ErrorDialog.showAuthError(
          context,
          message: 'Email ou mot de passe incorrect. Veuillez réessayer.',
        );
      } else {
        // Erreur générique
        await ErrorDialog.showGenericError(
          context,
          message: errorMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.back,
              color: Theme.of(context).textTheme.displayLarge?.color,
              size: 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const FutelaLogo(
                          size: 72,
                          backgroundColor: AppColors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Bienvenue',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connectez-vous pour continuer',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  controller: _loginController,
                  label: 'Email ou Téléphone',
                  hint: 'votre@email.com ou +243...',
                  keyboardType: TextInputType.emailAddress,
                  prefixIconData: CupertinoIcons.person_fill,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email ou téléphone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIconData: CupertinoIcons.lock_fill,
                  suffixIcon: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? CupertinoIcons.eye_slash_fill
                          : CupertinoIcons.eye_fill,
                      size: 22,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.6),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 4) {
                      return 'Le mot de passe doit contenir au moins 4 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Se connecter',
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      isLoading: authProvider.isLoading,
                      height: 52,
                      fullWidth: true,
                    );
                  },
                ),

                const SizedBox(height: 20),
                const SocialLoginButtons(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous n\'avez pas de compte ? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Créer un compte',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                // Text(
                //   'En continuant, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité.',
                //   textAlign: TextAlign.center,
                //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                //         color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                //         height: 1.4,
                //       ),
                // ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
