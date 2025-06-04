import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_viewmodel.dart';
import '../../core/widgets/colors.dart';
import '../../core/utils/validators.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _ForgotPasswordContent(),
    );
  }
}

class _ForgotPasswordContent extends StatefulWidget {
  const _ForgotPasswordContent({Key? key}) : super(key: key);

  @override
  _ForgotPasswordContentState createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<_ForgotPasswordContent>
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
      appBar: AppBar(
        backgroundColor: colorss.backgroundColorLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorss.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Şifremi Unuttum',
          style: TextStyle(color: colorss.textColor),
        ),
      ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenSize.height * 0.05),
                        Text(
                          'Şifrenizi mi unuttunuz?',
                          style: TextStyle(
                            color: colorss.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: colorss.textColor.withOpacity(0.5),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
                          style: TextStyle(
                            color: colorss.textColorSecondary,
                            fontSize: 16,
                          ),
                        ),
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
                          child: _buildEmailField(viewModel),
                        ),
                        SizedBox(height: screenSize.height * 0.05),
                        _buildResetButton(viewModel),
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
              child: Center(
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

  Widget _buildResetButton(LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            try {
              setState(() {
                _errorMessage = null;
              });
              await viewModel.resetPassword();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi'),
                    backgroundColor: colorss.primaryColor,
                  ),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              setState(() {
                _errorMessage = e.toString();
              });
            }
          }
        },
        style: colorss.getPrimaryButtonStyle(),
        child: Text(
          'Şifremi Sıfırla',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
