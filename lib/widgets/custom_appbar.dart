import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.bottom,
  });

  @override
  Size get preferredSize {
    double bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size(double.infinity, 60 + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Navigator.canPop(context) ? null : const _AnimatedLogo(),
      title: Text(title),
      centerTitle: Navigator.canPop(context) ? true : false,
      actions: actions,
      bottom: bottom,
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 0.1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.1,
          end: -0.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.1,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _tapCount++;
    if (!_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }

    if (_tapCount == 3) {
      Get.snackbar(
        "Oops! 💸",
        "Did you just drop a coin from your wallet?",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
      );
    } else if (_tapCount == 9) {
      Get.snackbar(
        "Hey! 🏦",
        "This is a wallet, not a toy!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
    } else if (_tapCount == 15) {
      Get.snackbar(
        "Warning! 🚨",
        "Any more taps and I'll deduct ₹10 from your balance! Just kidding! 😜",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } else if (_tapCount == 21) {
      Get.snackbar(
        "Okay, you win! 🏆",
        "You are the ultimate Pocket Hisab clicker!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade100,
        colorText: Colors.amber.shade900,
      );
      _tapCount = 0; // reset
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: RotationTransition(turns: _rotateAnimation, child: child),
          );
        },
        child: Image.asset(
          "assets/logo.webp",
          width: 45,
          height: 45,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
