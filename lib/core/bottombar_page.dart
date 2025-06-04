import 'package:digitalgunluk/home/home_view.dart';
import 'package:flutter/material.dart';
import '../profile/view/profile_view.dart';
import '../history/view/history_view.dart'; // HistoryView dosyasını import ettim
import '../../core/widgets/colors.dart'; // colors.dart dosyasının yolunu kontrol et
// Eğer ana sayfa yoksa veya farklı bir yerde ise buraya import eklemelisin
// import 'package:digitalgunluk/home/view/home_view.dart';

class BottomBarPage extends StatefulWidget {
  const BottomBarPage({Key? key}) : super(key: key);

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  int _selectedIndex = 0;

  // Geçici Ana Sayfa widget'ı. Gerçek Ana Sayfanız varsa onu kullanın.
  static const Widget _homePage = Center(
    child: Text(
      'Ana Sayfa',
      style: TextStyle(fontSize: 24, color: Colors.white),
    ),
  );

  // Profil Geçmiş Sayfası
  static const List<Widget> _pages = <Widget>[
    HomeView(), // Ana Sayfa
    HistoryView(), // Geçmiş Sayfası
    ProfileView(), // Profil Geçmiş Sayfası
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Geçmiş',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorss.primaryColor,
        unselectedItemColor: colorss.textColor,
        onTap: _onItemTapped,
        backgroundColor: colorss.backgroundColorLight,
      ),
    );
  }
}
