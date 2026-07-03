import 'package:flutter/material.dart';
import 'main_shell.dart';
import '../utils/app_constants.dart';

/// شاشة البداية (Splash Screen).
///
/// تعرض اسم التطبيق مع تأثير ظهور تدريجي (fade-in)، ثم تنتظر 3 ثوانٍ
/// بالضبط قبل الانتقال إلى الشاشة الرئيسية. لا تعتمد على أي حزمة
/// خارجية للأنيميشن — تستخدم AnimationController المدمج في Flutter
/// فقط، لضمان التوافق مع بيئة FlutLab.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // بدء أنيميشن الظهور التدريجي فور بناء الشاشة.
    _controller.forward();

    // الانتقال إلى الشاشة الرئيسية بعد 3 ثوانٍ بالضبط من فتح التطبيق،
    // بغض النظر عن مدة الأنيميشن نفسها.
    Future.delayed(AppConstants.splashDuration, _navigateToHome);
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 96,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
