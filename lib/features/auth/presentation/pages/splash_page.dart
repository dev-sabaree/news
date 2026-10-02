import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:newsapp/core/localization/localization_service.dart';
import 'package:newsapp/dependency_injection/injection.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:newsapp/routes/route_names.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  void _checkSession() {
    if (!mounted) return;

    final isLanguageSelected = sl<LocalizationService>().isLanguageSelected;

    if (!isLanguageSelected) {
      _fadeAndNavigate(RouteNames.languageSelect);
      return;
    }

    context.read<AuthBloc>().add(CheckSessionRequested());
  }

  Future<void> _fadeAndNavigate(String route) async {
    await _animationController.reverse();

    if (!mounted) return;

    context.go(route);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          await _fadeAndNavigate(RouteNames.news);
        }

        if (state is AuthUnauthenticated) {
          await _fadeAndNavigate(RouteNames.login);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: const RepaintBoundary(
              child: Image(
                image: AssetImage('assets/logo/app_logo.png'),
                width: 175,
                height: 175,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
