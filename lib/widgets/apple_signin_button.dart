import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final double height;

  const AppleSignInButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.text = 'Continuer avec Apple',
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    // Utiliser le bouton officiel Apple si disponible
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return SizedBox(
        height: height,
        child: SignInWithAppleButton(
          onPressed: (isLoading || onPressed == null) ? () {} : onPressed!,
          text: text,
          height: height,
          style: SignInWithAppleButtonStyle.black,
        ),
      );
    }

    // Bouton personnalisé pour les autres plateformes
    return SizedBox(
      height: height,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            : const Icon(
                CupertinoIcons.device_phone_portrait,
                size: 22,
                color: Colors.black,
              ),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}