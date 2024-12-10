import 'dart:async';
import 'package:ecom_app/MainApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'SignIn_Ui.dart';
import 'bloc/user/bloc_code.dart';
import 'bloc/user/events.dart';
import 'bloc/user/states.dart';
import 'data/UserSession.dart';

class SplashUI extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashUI> with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation Controller & Animation Initialization
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Set the animation duration
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start the animation
    _controller.forward();


    // Use Timer to delay the session check and event dispatching
    Timer(const Duration(seconds: 5), () {
      if (!_hasNavigated) {
        // Initiate the session check after animation completes
        context.read<UserBloc>().add(CheckOnboardingEvent());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (_hasNavigated) return;
          /*
          if (state is OnboardingNotSeenState) {
            _hasNavigated = true;
            print('Navigating to Onboarding');
            _navigateTo(context, OnboardingUI());
          } else
            */if (state is UserSessionLoadedState) {
            _hasNavigated = true;
            print('Navigating to Home');
            UserSession().loadUserSession(state);
            _navigateTo(context, MainScreen());
          } else if (state is UserLoggedOutState || state is UserErrorState) {
            _hasNavigated = true;
            print('Navigating to Sign In');
            _navigateTo(context, SigninUi());
          }
        },
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: SvgPicture.asset(
                  "assets/images/app_logo.svg",
                  width: 210,
                  height: 210,
                  fit: BoxFit.contain,
                ),
            ),
          ),
        ),
    );
  }

  // Helper method for navigation
  void _navigateTo(BuildContext context, Widget destination) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

