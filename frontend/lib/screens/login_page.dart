import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'vehicle_registration_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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

                  // Title
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
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Microsoft Button
                  _SocialButton(
                    label: 'Continue with Microsoft',
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const VehicleRegistrationPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Google Button
                  _SocialButton(
                    label: 'Continue with Google',
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const VehicleRegistrationPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Apple Button
                  _SocialButton(
                    label: 'Continue with Apple',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    icon: _BrandBox(
                      backgroundColor: Colors.black,
                      child: SvgPicture.asset(
                        'assets/images/apple.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const VehicleRegistrationPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 26),

                  // Help text
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: 'Trouble logging in? Please contact the\n'),
                        TextSpan(
                          text: 'IT Service Desk',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Divider(color: borderColor, height: 1),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'TERMS OF SERVICE',
                        style: TextStyle(
                          fontSize: 10,
                          color: mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'PRIVACY POLICY',
                        style: TextStyle(
                          fontSize: 10,
                          color: mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    '© 2024 CampusPark Systems.',
                    style: TextStyle(
                      fontSize: 10,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Widget icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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

  const _BrandBox({
    required this.child,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}