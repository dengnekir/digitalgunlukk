import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../register/view/login_view.dart';
import '../../core/widgets/colors.dart';
import 'edit_profile_view.dart';
import 'about_us_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileViewContent(),
    );
  }
}

class _ProfileViewContent extends StatefulWidget {
  const _ProfileViewContent({Key? key}) : super(key: key);

  @override
  _ProfileViewContentState createState() => _ProfileViewContentState();
}

class _ProfileViewContentState extends State<_ProfileViewContent> {
  String _appVersion = 'Yükleniyor...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();

    // Kullanıcı verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserData();
    });
  }

  Future<void> _loadAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Uygulama Destek Talebi',
      }),
    );
    if (!await launchUrl(emailLaunchUri)) {
      throw 'Mail gönderilemedi: $emailLaunchUri';
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.userModel == null
              ? const Center(
                  child: Text(
                  'Kullanıcı bilgileri yüklenemedi',
                  style: TextStyle(color: Colors.black),
                ))
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenSize.height * 0.03),
                        _buildProfileHeader(viewModel, screenSize),
                        SizedBox(height: screenSize.height * 0.04),
                        Text(
                          'Ayarlar',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: screenSize.width * 0.048,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        _buildSettingsList(viewModel, screenSize),
                        SizedBox(height: screenSize.height * 0.05),
                        _buildLogoutButton(viewModel, screenSize),
                        SizedBox(height: screenSize.height * 0.02),
                        _buildAppVersionText(screenSize),
                        SizedBox(height: screenSize.height * 0.03),
                      ],
                    ),
                  ),
                ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: screenSize.height * 0.02),
        Text(
          '${_capitalizeFirstLetter(viewModel.userModel!.name)} ${_capitalizeFirstLetter(viewModel.userModel!.surname)}',
          style: TextStyle(
            fontSize: screenSize.width * 0.065,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          viewModel.userModel!.email,
          style: TextStyle(
            fontSize: screenSize.width * 0.038,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
      ],
    );
  }

  Widget _buildSettingsList(ProfileViewModel viewModel, Size screenSize) {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.person_outline,
          title: 'Profili Düzenle',
          screenSize: screenSize,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                        value: viewModel,
                        child: const EditProfileView(),
                      )),
            );
          },
        ),
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: 'Uygulama Hakkında',
          screenSize: screenSize,
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsView()),
            );
          },
        ),
        _buildSettingsTile(
          icon: Icons.help_outline,
          title: 'Yardım ve Destek',
          screenSize: screenSize,
          onTap: () async {
            try {
              await _launchEmail('omergzt35@gmail.com');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mail gönderilemedi: $e')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Size screenSize,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: colorss.primaryColor, size: screenSize.width * 0.06),
            SizedBox(width: screenSize.width * 0.04),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: screenSize.width * 0.04,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(Icons.arrow_forward_ios,
                  color: Colors.black54, size: screenSize.width * 0.04),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ProfileViewModel viewModel, Size screenSize) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorss.logoutButtonColor,
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.02,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: () async {
          await viewModel.signOut();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginView()),
              (route) => false,
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout,
                color: Colors.white, size: screenSize.width * 0.055),
            SizedBox(width: screenSize.width * 0.025),
            Text(
              'Çıkış Yap',
              style: TextStyle(
                fontSize: screenSize.width * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppVersionText(Size screenSize) {
    return Center(
      child: Text(
        'Uygulama Sürümü: $_appVersion',
        style: TextStyle(
          fontSize: screenSize.width * 0.035,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
