import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'vehicle_registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  String? _loadingProvider;

  Future<void> _continueWithProvider(String provider) async {
    final credentials = await _showAuthCodeDialog(provider);
    if (credentials == null) return;

    setState(() => _loadingProvider = provider);

    try {
      await _authService.exchangeToken(
        provider: provider,
        code: credentials.code,
        codeVerifier: credentials.codeVerifier,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VehicleRegistrationPage()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }
  }

  Future<_AuthCodeInput?> _showAuthCodeDialog(String provider) async {
    final codeController = TextEditingController();
    final verifierController = TextEditingController();

    return showDialog<_AuthCodeInput>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${provider[0].toUpperCase()}${provider.substring(1)} auth'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Temporary test step: paste the OAuth authorisation code and PKCE verifier. Later this will be replaced by the real Google/Microsoft sign-in flow.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Authorisation code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: verifierController,
                decoration: const InputDecoration(
                  labelText: 'Code verifier',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = codeController.text.trim();
                final verifier = verifierController.text.trim();
                if (code.isEmpty || verifier.isEmpty) return;

                Navigator.pop(
                  context,
                  _AuthCodeInput(code: code, codeVerifier: verifier),
                );
              },
              child: const Text('Exchange token'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);
    const cardBackground = Colors.white;
    const mutedText = Color(0xFF8B8E99);
    const borderColor = Color(0xFFE6E8EF);

    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to\nCampusPark',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: primaryBlue,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Access university parking services with your academic credentials.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: mutedText, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  _SocialButton(
                    label: 'Continue with Microsoft',
                    isLoading: _loadingProvider == 'microsoft',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: borderColor,
                    icon: _BrandBox(
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset(
                        'assets/images/microsoft.svg',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    onTap: () => _continueWithProvider('microsoft'),
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    label: 'Continue with Google',
                    isLoading: _loadingProvider == 'google',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: borderColor,
                    icon: _BrandBox(
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset(
                        'assets/images/google.svg',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    onTap: () => _continueWithProvider('google'),
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    label: 'Continue with Apple',
                    isLoading: false,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    icon: _BrandBox(
                      backgroundColor: Colors.black,
                      child: SvgPicture.asset(
                        'assets/images/apple.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Apple is not in the Swagger auth provider enum yet.')),
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: mutedText, fontSize: 12, height: 1.5),
                      children: [
                        TextSpan(text: 'Trouble logging in? Please contact the\n'),
                        TextSpan(
                          text: 'IT Service Desk',
                          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Divider(color: borderColor, height: 1),
                  const SizedBox(height: 18),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('TERMS OF SERVICE', style: TextStyle(fontSize: 10, color: mutedText, fontWeight: FontWeight.w600)),
                      SizedBox(width: 16),
                      Text('PRIVACY POLICY', style: TextStyle(fontSize: 10, color: mutedText, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('© 2024 CampusPark Systems.', style: TextStyle(fontSize: 10, color: mutedText)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCodeInput {
  final String code;
  final String codeVerifier;

  const _AuthCodeInput({required this.code, required this.codeVerifier});
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Widget icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
              )
            else
              icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isLoading ? 'Signing in...' : label,
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

class _BrandBox extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const _BrandBox({required this.child, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(6)),
      alignment: Alignment.center,
      child: child,
    );
  }
}
