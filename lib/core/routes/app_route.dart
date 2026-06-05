import 'package:flutter/material.dart';

class AppRoute<T> extends PageRouteBuilder<T> {
  AppRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, _) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slide = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );
            return SlideTransition(
              position: slide,
              child: FadeTransition(opacity: fade, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
        );
}

class AppScaleRoute<T> extends PageRouteBuilder<T> {
  AppScaleRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, _) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );
            return ScaleTransition(
              scale: scale,
              child: FadeTransition(opacity: fade, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
}
