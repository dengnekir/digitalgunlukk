import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../core/widgets/colors.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ProfileViewModel>();
    // _nameController ve _surnameController'ı initState'te değil,
    // build metodunda veya userModel yüklendikten sonra başlatmak daha güvenli olabilir.
    // Şimdilik boş dize ile başlatarak null hatasını engelliyoruz.
    _nameController =
        TextEditingController(text: viewModel.userModel?.name ?? '');
    _surnameController =
        TextEditingController(text: viewModel.userModel?.surname ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profili Düzenle',
            style: TextStyle(
                color: Colors.black, fontSize: screenSize.width * 0.05)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // iOS'ta başlık ortalı olur
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height * 0.03),
              _buildInputField(
                controller: _nameController,
                label: 'Ad',
                icon: Icons.person_outline,
              ),
              SizedBox(height: screenSize.height * 0.02),
              _buildInputField(
                controller: _surnameController,
                label: 'Soyad',
                icon: Icons.person_outline,
              ),
              SizedBox(height: screenSize.height * 0.05),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorss.primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.1,
                    vertical: screenSize.height * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15), // Daha yumuşak köşeler
                  ),
                  elevation: 3, // Hafif bir yükseltme
                ),
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        // Güncelleme işlemi
                        await viewModel.updateUserNameAndSurname(
                          _nameController.text,
                          _surnameController.text,
                        );
                        if (!mounted) return;
                        // Başarılı olursa geri dön
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil başarıyla güncellendi!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      },
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Kaydet',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style:
            TextStyle(color: Colors.black, fontSize: screenSize.width * 0.04),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.black54, fontSize: screenSize.width * 0.04),
          prefixIcon: Icon(icon,
              color: colorss.primaryColor, size: screenSize.width * 0.055),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorss.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02),
          errorStyle: const TextStyle(
            color: Colors.red,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
