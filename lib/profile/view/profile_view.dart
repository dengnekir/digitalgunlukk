import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../register/view/login_view.dart';
import '../../core/widgets/colors.dart';
import 'edit_profile_view.dart';
import 'about_us_view.dart';
import 'package:url_launcher/url_launcher.dart';

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
  @override
  void initState() {
    super.initState();

    // Kullanıcı verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserData();
    });
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
        title: const Text('Profil', style: TextStyle(color: Colors.black)),
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
                        SizedBox(height: screenSize.height * 0.02),
                        _buildProfileHeader(viewModel, screenSize),
                        SizedBox(height: screenSize.height * 0.03),
                        Text(
                          'Ayarlar',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: screenSize.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        _buildSettingsList(viewModel, screenSize),
                        SizedBox(height: screenSize.height * 0.04),
                        _buildLogoutButton(viewModel, screenSize),
                        SizedBox(height: screenSize.height * 0.04),
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
          '${viewModel.userModel!.name} ${viewModel.userModel!.surname}',
          style: TextStyle(
            fontSize: screenSize.width * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          viewModel.userModel!.email,
          style: TextStyle(
            fontSize: screenSize.width * 0.035,
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
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
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
            horizontal: screenSize.width * 0.1,
            vertical: screenSize.height * 0.025,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: colorss.logoutButtonColor.withOpacity(0.5),
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
                color: Colors.white, size: screenSize.width * 0.06),
            SizedBox(width: screenSize.width * 0.03),
            Text(
              'Çıkış Yap',
              style: TextStyle(
                fontSize: screenSize.width * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
