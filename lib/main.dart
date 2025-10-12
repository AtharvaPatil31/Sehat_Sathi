import 'dart:async';
import 'package:flutter/material.dart';
import 'package:three/screens/login.dart';
import 'package:three/screens/medicine_tracker_screen.dart';
import 'package:three/screens/profilescreen.dart';
import 'package:three/screens/video_consultation_screen.dart';
import 'screens/supabase_client.dart';
import 'screens/diagnosis.dart';

const Color primaryColor = Color.fromRGBO(20, 33, 61, 1);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sehat Saathi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        );
      },
      home: const SplashScreen(),
    );
  }
}

// ---------------- Splash Screen ----------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/sihlogo.png', // make sure this exists
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            Text(
              "Sehat Saathi",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Home Screen ----------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showBottomNav = true;

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
  List.generate(4, (_) => GlobalKey<NavigatorState>());

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab =
    !await _navigatorKeys[_currentIndex].currentState!.maybePop();
    if (isFirstRouteInCurrentTab) {
      if (_currentIndex != 0) {
        setState(() => _currentIndex = 0);
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

  void _hideBottomNav(bool hide) {
    setState(() => _showBottomNav = !hide);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: List.generate(4, _buildOffstageNavigator),
        ),
        bottomNavigationBar: _showBottomNav
            ? BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: (index) {
            if (_currentIndex == index) {
              _navigatorKeys[index]
                  .currentState!
                  .popUntil((route) => route.isFirst);
            } else {
              setState(() => _currentIndex = index);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_call),
              label: 'Consult',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Diagnosis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy),
              label: 'Medicine',
            ),
          ],
        )
            : null,
      ),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (_) {
          late Widget page;
          switch (index) {
            case 0:
              page = HomeTab(primaryColor: primaryColor, onEnterCall: _hideBottomNav);
              break;
            case 1:
              page = VideoConsultationScreen(
                primaryColor: primaryColor,
                onFullScreen: _hideBottomNav,
              );
              break;
            case 2:
              page = const MedicalAssistantPage();
              break;
            case 3:
              page = MedicineTrackerScreen();
              break;
            default:
              page = const SizedBox();
          }
          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}

// ---------------- Home Tab ----------------
class HomeTab extends StatelessWidget {
  final Color primaryColor;
  final void Function(bool) onEnterCall;

  const HomeTab({super.key, required this.primaryColor, required this.onEnterCall});

  void _navigateToVideoConsultation(BuildContext context) {
    onEnterCall(true);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => VideoConsultationScreen(
          primaryColor: primaryColor,
          onFullScreen: onEnterCall,
        ),
      ),
    )
        .then((_) => onEnterCall(false));
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsScreen(primaryColor: primaryColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.person, color: Colors.black), onPressed: () => _navigateToProfile(context)),
          IconButton(icon: const Icon(Icons.settings, color: Colors.black), onPressed: () => _navigateToSettings(context)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Sehat Saathi!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _navigateToVideoConsultation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Book Consultation', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Settings Screen ----------------
class SettingsScreen extends StatefulWidget {
  final Color primaryColor;
  const SettingsScreen({super.key, required this.primaryColor});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
              child: RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (v) => setState(() => _selectedLanguage = v!),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
              child: RadioListTile<String>(
                title: const Text('Punjabi'),
                value: 'Punjabi',
                groupValue: _selectedLanguage,
                onChanged: (v) => setState(() => _selectedLanguage = v!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
