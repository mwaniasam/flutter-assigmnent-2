import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/providers/auth_provider.dart';
import 'package:bookswap_app/screens/auth/login_screen.dart';
import 'package:bookswap_app/screens/auth/email_verification_screen.dart';
import 'package:bookswap_app/screens/main_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return const LoginScreen();
        }

        // TODO: Re-enable email verification for production
        // For demo: Bypass email verification check
        // if (!user.emailVerified) {
        //   return const EmailVerificationScreen();
        // }

        return const MainNavigation();
      },
    );
  }
}
