import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_viewmodel.dart';
import 'register_view.dart';
import 'forgot_password_view.dart';
import '../../core/widgets/colors.dart';
import '../../core/utils/validators.dart';
import '../../profile/view/profile_view.dart';
import '../../core/bottombar_page.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginViewContent(),
    );
  }
}

class _LoginViewContent extends StatefulWidget {
  const _LoginViewContent({Key? key}) : super(key: key);

  @override
  _LoginViewContentState createState() => _LoginViewContentState();
}

class _LoginViewContentState extends State<_LoginViewContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorss.backgroundColorLight,
      body: Stack(
        children: [
          // Geliştirilmiş Arkaplan Gradyanı
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomRight,
                    radius: 1.8,
                    colors: [
                      colorss
                          .getPrimaryGlowColor()
                          .withOpacity(_fadeAnimation.value * 0.25),
                      colorss.getSecondaryGlowColor(),
                    ],
                    stops: [0.2, 0.8],
                  ),
                ),
              );
            },
          ),

          // Ana içerik
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: screenSize.height * 0.1),
                        _buildHeader(screenSize),
                        SizedBox(height: screenSize.height * 0.05),

                        // Hata mesajı
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: colorss.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorss.primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorss.primaryColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: colorss.primaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                colorss.backgroundColorLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorss.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildEmailField(viewModel),
                              const SizedBox(height: 20),
                              _buildPasswordField(viewModel),
                              const SizedBox(height: 10),
                              _buildRememberMe(viewModel),
                              _buildForgotPassword(),
                            ],
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.05),
                        _buildLoginButton(viewModel),
                        const SizedBox(height: 20),
                        _buildRegisterLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Yükleme göstergesi
          if (viewModel.isLoading)
            Container(
              color: colorss.getOverlayColor(),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorss.primaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size screenSize) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dijital',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenSize.width / 8,
                fontWeight: FontWeight.normal,
                letterSpacing: -2,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 5,
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
                    color: colorss.primaryColor.withOpacity(0.9),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            Text(
              'kiyatri',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenSize.width / 8,
                fontWeight: FontWeight.normal,
                letterSpacing: -2,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorss.primaryColor.withOpacity(0.3),
                blurRadius: 7,
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
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(LoginViewModel viewModel) {
    return Container(
      decoration: colorss.getInputDecoration(),
      child: TextFormField(
        controller: viewModel.emailController,
        style: const TextStyle(color: colorss.textColor),
        decoration: colorss
            .getTextFieldDecoration(
              labelText: 'E-posta',
              prefixIcon: Icons.email_outlined,
            )
            .copyWith(
              errorStyle: const TextStyle(
                color: colorss.primaryColorLight,
              ),
            ),
        validator: Validators.validateEmail,
      ),
    );
  }

  Widget _buildPasswordField(LoginViewModel viewModel) {
    return Container(
      decoration: colorss.getInputDecoration(),
      child: TextFormField(
        controller: viewModel.passwordController,
        obscureText: !viewModel.isPasswordVisible,
        style: const TextStyle(color: colorss.textColor),
        decoration: colorss
            .getTextFieldDecoration(
              labelText: 'Şifre',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: colorss.primaryColorLight,
                ),
                onPressed: viewModel.togglePasswordVisibility,
              ),
            )
            .copyWith(
              errorStyle: const TextStyle(
                color: colorss.primaryColorLight,
              ),
            ),
        validator: Validators.validatePassword,
      ),
    );
  }

  Widget _buildRememberMe(LoginViewModel viewModel) {
    return Row(
      children: [
        Checkbox(
          value: viewModel.rememberMe,
          onChanged: (value) => viewModel.setRememberMe(value ?? false),
          fillColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return colorss.primaryColor;
              }
              return Colors.white;
            },
          ),
        ),
        const Text(
          'Beni Hatırla',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPasswordView()),
          );
        },
        child: const Text(
          'Şifremi Unuttum',
          style: TextStyle(
            color: colorss.textColor,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            try {
              // Hata mesajını temizle
              setState(() {
                _errorMessage = null;
              });

              final user = await viewModel.login();

              if (user != null && mounted) {
                // Başarılı giriş, profil sayfasına yönlendir
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BottomBarPage()),
                );
              }
            } catch (e) {
              // Hata mesajını göster
              setState(() {
                _errorMessage = e.toString();
              });
            }
          }
        },
        style: colorss.getPrimaryButtonStyle(),
        child: const Text(
          'Giriş Yap',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterView()),
        );
      },
      child: const Text(
        'Hesabın yok mu? Kayıt ol',
        style: TextStyle(
          color: colorss.primaryColorLight,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
