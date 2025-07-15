import 'package:flutter/material.dart';
import 'dart:math' as math;

class CinematicUnlockAnimation extends StatelessWidget {
    final AnimationController controller;

    CinematicUnlockAnimation({super.key, required this.controller})
        : lockScale = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: const Interval(0.0, 0.2, curve: Curves.elasticOut)),
            ),
            keySlide = Tween<Offset>(begin: const Offset(-200, 0), end: const Offset(-40, 0)).animate(
            CurvedAnimation(parent: controller, curve: const Interval(0.2, 0.4, curve: Curves.easeInOut)),
            ),
            keyTurn = Tween<double>(begin: 0.0, end: -math.pi / 4).animate(
            CurvedAnimation(parent: controller, curve: const Interval(0.4, 0.6, curve: Curves.easeInOut)),
            ),
            lockShatter = Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(parent: controller, curve: const Interval(0.6, 0.8, curve: Curves.easeIn)),
            ),
            fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(parent: controller, curve: const Interval(0.8, 1.0)),
            );

    final Animation<double> lockScale;
    final Animation<Offset> keySlide;
    final Animation<double> keyTurn;
    final Animation<double> lockShatter;
    final Animation<double> fadeOut;

    @override
    Widget build(BuildContext context) {
        return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
            return Container(
            color: Colors.black.withOpacity(0.5 * fadeOut.value),
            alignment: Alignment.center,
            child: Opacity(
                opacity: fadeOut.value,
                child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                    Transform.scale(
                        scale: lockScale.value * lockShatter.value,
                        child: Icon(
                        Icons.lock_rounded,
                        size: 80,
                        color: Colors.brown.shade700,
                        ),
                    ),
                    Transform.translate(
                        offset: keySlide.value,
                        child: Transform.rotate(
                        angle: keyTurn.value,
                        child: const Icon(
                            Icons.vpn_key_rounded,
                            size: 80,
                            color: Colors.amber,
                        ),
                        ),
                    ),
                    ],
                ),
                ),
            ),
            );
        },
        );
    }
}