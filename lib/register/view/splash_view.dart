import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/splash_viewmodel.dart';
import '../../core/widgets/colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(),
      child: const _SplashViewContent(),
    );
  }
}

class _SplashViewContent extends StatefulWidget {
  const _SplashViewContent({Key? key}) : super(key: key);

  @override
  _SplashViewContentState createState() => _SplashViewContentState();
}

class _SplashViewContentState extends State<_SplashViewContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Splash ekranından sonra yönlendirme
    Future.delayed(const Duration(seconds: 3), () {
      final viewModel = context.read<SplashViewModel>();
      viewModel.checkAuthState(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorss.backgroundColor,
      body: Stack(
        children: [
          // Arkaplan animasyonu
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      colorss
                          .getPrimaryGlowColor()
                          .withOpacity(_glowAnimation.value * 0.3),
                      colorss.getSecondaryGlowColor(),
                    ],
                    stops: [0.0, 0.7],
                  ),
                ),
              );
            },
          ),

          // Logo ve metin
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Dijital',
                          style: TextStyle(
                            color: colorss.textColor,
                            fontSize: screenSize.width / 8,
                            fontWeight: FontWeight.normal,
                            letterSpacing: -2,
                            shadows: [
                              Shadow(
                                color: colorss.textColor.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Psi',
                          style: TextStyle(
                            color: colorss.primaryColor,
                            fontSize: screenSize.width / 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2,
                            shadows: [
                              Shadow(
                                color: colorss.primaryColor.withOpacity(0.95),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'kiyatri',
                          style: TextStyle(
                            color: colorss.textColor,
                            fontSize: screenSize.width / 8,
                            fontWeight: FontWeight.normal,
                            letterSpacing: -2,
                            shadows: [
                              Shadow(
                                color: colorss.textColor.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorss.primaryColor.withOpacity(0.1),
                          blurRadius: 55,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      "Zihnine Dokun",
                      style: TextStyle(
                        color: colorss.primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: colorss.primaryColor.withOpacity(0.9),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
