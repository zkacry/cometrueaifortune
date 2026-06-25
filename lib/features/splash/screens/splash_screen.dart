import 'package:flutter/material.dart';
import 'package:myfortune/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✨', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'AI Fortune',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                letterSpacing: 4,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'あなたの記憶を読んで占う',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppTheme.accent,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
