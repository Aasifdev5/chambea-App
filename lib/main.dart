import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:chambea/screens/client/perfil_screen.dart';
import 'package:chambea/screens/chambeador/chambeadorregister_screen.dart';
import 'firebase_options.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:chambea/screens/chambeador/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/blocs/client/client_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_bloc.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chambea/services/api_service.dart'; // Updated import

// Utility class for authentication and navigation
class AuthUtils {
  static bool _isNavigating = false;
  static DateTime? _lastBackPress;
  static const _debounceDuration = Duration(milliseconds: 1000);

  static Future<Widget> getAuthenticatedScreen(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('DEBUG: No authenticated user, redirecting to SplashScreen');
      return const SplashScreen();
    }

    print('DEBUG: Fetching account type for UID: ${user.uid}');
    try {
      final accountType = await ApiService.getAccountType();
      print('DEBUG: Valid account type received: $accountType');

      if (accountType == 'Client' || accountType == 'Chambeador') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('account_type', accountType);
        return accountType == 'Client'
            ? const ClientHomeScreen()
            : const HomeScreen();
      } else {
        print('DEBUG: Invalid or missing account type: $accountType');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('account_type');
        return const ProfileSelectionScreen();
      }
    } catch (e) {
      print('DEBUG: Error fetching account type: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('account_type');
      return const ProfileSelectionScreen();
    }
  }

  static Future<bool> handleBackNavigation(BuildContext context) async {
    final now = DateTime.now();
    if (_isNavigating) {
      print('DEBUG: Navigation in progress, ignoring back press');
      return false;
    }

    if (_lastBackPress != null &&
        now.difference(_lastBackPress!) < _debounceDuration) {
      print('DEBUG: Back button press debounced');
      return false;
    }
    _lastBackPress = now;

    _isNavigating = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('DEBUG: User is logged in, redirecting to appropriate screen');
        final nextScreen = await getAuthenticatedScreen(context);
        if (context.mounted && nextScreen != const SplashScreen()) {
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => nextScreen),
            (route) => false,
          );
          return false;
        }
      }
      print('DEBUG: User not logged in, showing exit confirmation');
      if (!context.mounted) return false;
      final shouldExit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Salir'),
            content: const Text('¿Deseas salir de la aplicación?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salir'),
              ),
            ],
          ),
        ),
      );
      return shouldExit ?? false;
    } finally {
      _isNavigating = false;
    }
  }
}

// Registers FCM token for push notifications
Future<void> registerFcmToken() async {
  try {
    final messaging = FirebaseMessaging.instance;
    final permission = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (permission.authorizationStatus != AuthorizationStatus.authorized) {
      print('DEBUG: Notification permission denied');
      await messaging.requestPermission(provisional: true);
      return;
    }
    final token = await messaging.getToken();
    print('DEBUG: FCM Token: $token');
    if (token == null) {
      print('DEBUG: FCM token is null. Check Firebase configuration.');
      return;
    }
    final response = await ApiService.post('/api/users/update-fcm-token', {
      'fcm_token': token,
    });
    print('DEBUG: API Response: ${response['statusCode']} ${response['body']}');
    if (response['statusCode'] == 200 &&
        response['body']['status'] == 'success') {
      print('DEBUG: FCM token updated successfully');
    } else {
      print(
        'DEBUG: Failed to update FCM token: ${response['body']['message'] ?? response['body']}',
      );
    }
  } catch (e, stack) {
    print('DEBUG: Error registering FCM token: $e\n$stack');
    if (e.toString().contains('Method Not Allowed')) {
      print(
        'DEBUG: Ensure the endpoint /api/users/update-fcm-token supports POST',
      );
    } else if (e.toString().contains('Unauthorized')) {
      print('DEBUG: Refreshing Firebase ID token');
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    print('Flutter Error: ${details.exceptionAsString()}\n${details.stack}');
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized");

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
    print("✅ App Check activated");

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    print("✅ Firestore persistence enabled");

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('DEBUG: User signed out, clearing account type');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('account_type');
      }
    });

    runApp(const ChambeaApp());

    Future.microtask(() async {
      await registerFcmToken();
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📩 Notification: ${message.notification?.body}');
      });

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        try {
          await ApiService.post('/api/users/update-fcm-token', {
            'fcm_token': newToken,
          });
          print('✅ FCM token refreshed');
        } catch (e) {
          print('❌ FCM token refresh error: $e');
        }
      });
    });
  } catch (e, stack) {
    print('🔥 Main crash: $e\n$stack');
  }
}

class ChambeaApp extends StatefulWidget {
  const ChambeaApp({super.key});

  @override
  State<ChambeaApp> createState() => _ChambeaAppState();
}

class _ChambeaAppState extends State<ChambeaApp> {
  Widget? _initialScreen;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final screen = await AuthUtils.getAuthenticatedScreen(context);
      if (mounted) {
        setState(() {
          _initialScreen = screen;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error initializing app: $e');
      if (mounted) {
        setState(() {
          _initialScreen = const Scaffold(
            body: Center(child: Text('Error al cargar la aplicación')),
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            print('DEBUG: Creating ClientBloc');
            return ClientBloc();
          },
        ),
        BlocProvider(
          create: (context) {
            print('DEBUG: Creating ChambeadorBloc');
            return ChambeadorBloc();
          },
        ),
        BlocProvider(
          create: (context) {
            print('DEBUG: Creating ProposalsBloc');
            return ProposalsBloc();
          },
        ),
      ],
      child: MaterialApp(
        title: 'CHAMBEA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF22c55e),
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22c55e),
              foregroundColor: Colors.white,
              elevation: 5,
              shadowColor: const Color(0xFF22c55e).withOpacity(0.3),
            ),
          ),
        ),
        home: _isLoading
            ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : _initialScreen,
        routes: {
          '/perfil': (context) => const PerfilScreen(),
          '/chambeador_register': (context) => ChambeadorRegisterScreen(),
          '/client_home': (context) => const ClientHomeScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingOneScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/logo.png',
              width: screenWidth * 0.5,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingOneScreen extends StatefulWidget {
  const OnboardingOneScreen({super.key});

  @override
  State<OnboardingOneScreen> createState() => _OnboardingOneScreenState();
}

class _OnboardingOneScreenState extends State<OnboardingOneScreen> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    if (!mounted) return;
    setState(() {
      _isCheckingAuth = true;
    });
    final nextScreen = await AuthUtils.getAuthenticatedScreen(context);
    if (mounted && nextScreen != const SplashScreen()) {
      print('DEBUG: Logged-in user detected, redirecting from OnboardingOneScreen');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    }
    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    return await AuthUtils.handleBackNavigation(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Image.asset(
                    'assets/images/onboarding1.png',
                    height: screenHeight * 0.35,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    '¡Bienvenido a CHAMBEA!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Realiza tus actividades con tranquilidad mientras nuestros profesionales se encargan de todo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          _ProgressIndicator(isActive: true),
                          _ProgressIndicator(isActive: false),
                          _ProgressIndicator(isActive: false),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Saltar',
                          style: TextStyle(
                            color: const Color(0xFF22c55e),
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingTwoScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      'Siguiente',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingTwoScreen extends StatefulWidget {
  const OnboardingTwoScreen({super.key});

  @override
  State<OnboardingTwoScreen> createState() => _OnboardingTwoScreenState();
}

class _OnboardingTwoScreenState extends State<OnboardingTwoScreen> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    if (!mounted) return;
    setState(() {
      _isCheckingAuth = true;
    });
    final nextScreen = await AuthUtils.getAuthenticatedScreen(context);
    if (mounted && nextScreen != const SplashScreen()) {
      print('DEBUG: Logged-in user detected, redirecting from OnboardingTwoScreen');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    }
    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    return await AuthUtils.handleBackNavigation(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Image.asset(
                    'assets/images/onboarding2.png',
                    height: screenHeight * 0.35,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    'Encuentra servicios a tu medida',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Conecta con trabajadores de confianza en tu vecindario para ayudarte en casa, apartamento u oficina.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          _ProgressIndicator(isActive: false),
                          _ProgressIndicator(isActive: true),
                          _ProgressIndicator(isActive: false),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Saltar',
                          style: TextStyle(
                            color: const Color(0xFF22c55e),
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingThreeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      'Siguiente',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingThreeScreen extends StatefulWidget {
  const OnboardingThreeScreen({super.key});

  @override
  State<OnboardingThreeScreen> createState() => _OnboardingThreeScreenState();
}

class _OnboardingThreeScreenState extends State<OnboardingThreeScreen> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    if (!mounted) return;
    setState(() {
      _isCheckingAuth = true;
    });
    final nextScreen = await AuthUtils.getAuthenticatedScreen(context);
    if (mounted && nextScreen != const SplashScreen()) {
      print('DEBUG: Logged-in user detected, redirecting from OnboardingThreeScreen');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    }
    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    return await AuthUtils.handleBackNavigation(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Image.asset(
                    'assets/images/onboarding3.png',
                    height: screenHeight * 0.35,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    'Programa según tu conveniencia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Elige el momento perfecto para ti y el trabajador con flexibilidad y facilidad.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          _ProgressIndicator(isActive: false),
                          _ProgressIndicator(isActive: false),
                          _ProgressIndicator(isActive: true),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Saltar',
                          style: TextStyle(
                            color: const Color(0xFF22c55e),
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Comenzar',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'BO');
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  Timer? _debounce;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPhoneNumber();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    if (!mounted) return;
    setState(() {
      _isCheckingAuth = true;
    });
    final nextScreen = await AuthUtils.getAuthenticatedScreen(context);
    if (mounted && nextScreen != const SplashScreen()) {
      print('DEBUG: Logged-in user detected, redirecting from LoginScreen');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    }
    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  Future<void> _loadSavedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('last_phone_number');
    if (savedPhone != null) {
      setState(() {
        _phoneNumber = PhoneNumber(phoneNumber: savedPhone, isoCode: 'BO');
        _phoneController.text = savedPhone;
      });
    }
  }

  Future<void> _savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_phone_number', phoneNumber);
  }

  Future<bool> _onWillPop() async {
    return await AuthUtils.handleBackNavigation(context);
  }

  Future<void> _signInWithGoogle() async {
    if (_isGoogleLoading) return;
    setState(() {
      _isGoogleLoading = true;
    });
    try {
      print('DEBUG: Starting Google Sign-In');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('DEBUG: Google Sign-In cancelled');
        setState(() {
          _isGoogleLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      print(
        'DEBUG: Google Sign-In successful, navigating to ActiveServiceScreen',
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ActiveServiceScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('DEBUG: Error in Google Sign-In: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error en Google Sign-In: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _startPhoneAuth() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final phoneNumber = _phoneNumber.phoneNumber;
      print('DEBUG: Starting phone auth for number: $phoneNumber');
      if (phoneNumber == null || phoneNumber.isEmpty) {
        print('DEBUG: Phone number is empty');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa un número de teléfono'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final isValid = _validatePhoneNumber(phoneNumber);
      if (!isValid) {
        print('DEBUG: Invalid phone number: $phoneNumber');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Número de teléfono inválido para el país seleccionado',
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _savePhoneNumber(phoneNumber);
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('DEBUG: Auto-verification completed: $credential');
          await _auth.signInWithCredential(credential);
          if (mounted) {
            print(
              'DEBUG: Navigating to ActiveServiceScreen after auto-verification',
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ActiveServiceScreen()),
              (route) => false,
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('DEBUG: Phone verification failed: ${e.message}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.message ?? 'Verificación fallida'}'),
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          print('DEBUG: OTP code sent, verificationId: $verificationId');
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OTPScreen(
                  verificationId: verificationId,
                  phoneNumber: phoneNumber,
                ),
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('DEBUG: Code auto-retrieval timeout: $verificationId');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('DEBUG: Error in phone auth: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el código: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validatePhoneNumber(String phoneNumber) {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (_phoneNumber.isoCode == 'BO') {
      return RegExp(r'^\+591\d{8}$').hasMatch(cleanedNumber);
    } else if (_phoneNumber.isoCode == 'US') {
      return RegExp(r'^\+1\d{10}$').hasMatch(cleanedNumber);
    } else if (_phoneNumber.isoCode == 'MX') {
      return RegExp(r'^\+52\d{10}$').hasMatch(cleanedNumber);
    }
    return cleanedNumber.length >= 9 && cleanedNumber.length <= 15;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: screenHeight * 0.15,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    'Introduce tu número de teléfono',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Te enviaremos un código para verificar tu número telefónico',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        _phoneNumber = number;
                      });
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        _validatePhoneNumber(number.phoneNumber ?? '');
                      });
                    },
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.DROPDOWN,
                      setSelectorButtonAsPrefixIcon: true,
                      leadingPadding: 12,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    initialValue: _phoneNumber,
                    selectorTextStyle: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black87,
                    ),
                    textStyle: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black87,
                    ),
                    textFieldController: _phoneController,
                    formatInput: false,
                    keyboardType: TextInputType.phone,
                    inputDecoration: InputDecoration(
                      hintText: 'Número de teléfono',
                      hintStyle: TextStyle(
                        color: Colors.black38,
                        fontSize: screenWidth * 0.035,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFF22c55e)),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.1,
                              vertical: screenHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                          ),
                          onPressed: _startPhoneAuth,
                          child: Text(
                            'Enviar código',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  SizedBox(height: screenHeight * 0.03),
                  _isGoogleLoading
                      ? const CircularProgressIndicator()
                      : OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.1,
                              vertical: screenHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                            elevation: 2,
                          ),
                          icon: Image.asset(
                            'assets/images/search.png',
                            height: screenHeight * 0.03,
                            width: screenHeight * 0.03,
                          ),
                          label: Text(
                            'Continuar con Google',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: _signInWithGoogle,
                        ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    'Al unirte a nuestra aplicación, aceptas nuestros Términos de Uso y Política de privacidad',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with CodeAutoFill {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _otp = '';
  bool _canResend = false;
  int _resendCountdown = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('DEBUG: OTPScreen initState - Starting to listen for SMS code');
    listenForCode();
    _startResendTimer();
  }

  void _startResendTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      }
    });
  }

  @override
  void codeUpdated() {
    print('DEBUG: codeUpdated called with code: $code');
    if (code != null && code!.length == 6) {
      print('DEBUG: Valid OTP received: $code');
      setState(() {
        _otp = code!;
        for (int i = 0; i < 6; i++) {
          _otpControllers[i].text = _otp[i];
        }
      });
      _verifyOtp();
    } else {
      print('DEBUG: Invalid or null OTP received: $code');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Código OTP inválido: $code')));
      }
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });
    _otp = _otpControllers.map((controller) => controller.text).join();
    if (_otp.length != 6) {
      print('DEBUG: OTP length invalid: $_otp');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un código de 6 dígitos'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      print('DEBUG: Verifying OTP: $_otp');
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otp,
      );
      await _auth.signInWithCredential(credential);
      print(
        'DEBUG: OTP verification successful, navigating to ActiveServiceScreen',
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ActiveServiceScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('DEBUG: OTP verification failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Código incorrecto: $e')));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _resendOtp() async {
    if (!_canResend) {
      print('DEBUG: Resend not allowed yet, countdown: $_resendCountdown');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      print('DEBUG: Resending OTP for phone: ${widget.phoneNumber}');
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('DEBUG: Auto-verification completed on resend: $credential');
          await _auth.signInWithCredential(credential);
          if (mounted) {
            print('DEBUG: Navigating to ActiveServiceScreen after resend');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ActiveServiceScreen()),
              (route) => false,
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('DEBUG: Resend verification failed: ${e.message}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.message ?? 'Verificación fallida'}'),
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print('DEBUG: New OTP code sent, verificationId: $verificationId');
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OTPScreen(
                  verificationId: verificationId,
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Código reenviado')));
            setState(() {
              _canResend = false;
              _resendCountdown = 60;
              _startResendTimer();
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print(
            'DEBUG: Code auto-retrieval timeout for verificationId: $verificationId',
          );
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('DEBUG: Error resending OTP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar el código: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _otpTextField(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.1,
      height: screenWidth * 0.1,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      child: TextField(
        controller: _otpControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF22c55e), width: 2),
          ),
        ),
        textInputAction: index < 5
            ? TextInputAction.next
            : TextInputAction.done,
        onChanged: (value) {
          print('DEBUG: OTP field $index changed: $value');
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (index == 5 && value.isNotEmpty) {
            _verifyOtp();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    print('DEBUG: Disposing OTPScreen, canceling SMS listener');
    cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => await AuthUtils.handleBackNavigation(context),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: screenHeight * 0.15,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    'Ingresa el código',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Te enviamos un código de verificación al número\n${widget.phoneNumber}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: screenWidth * 0.01,
                    children: List.generate(6, (index) => _otpTextField(index)),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          _canResend
                              ? 'Puedes reenviar el código ahora'
                              : 'Puedes reenviar el código en $_resendCountdown segundos',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                  SizedBox(height: screenHeight * 0.05),
                  TextButton(
                    onPressed: _canResend ? _resendOtp : null,
                    child: Text(
                      'Reenviar código',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: _canResend ? const Color(0xFF22c55e) : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActiveServiceScreen extends StatelessWidget {
  const ActiveServiceScreen({super.key});

  Future<void> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.request();
    print('DEBUG: Location permission status: $status');
    if (status.isGranted) {
      print('DEBUG: Location permission granted');
    } else {
      print('DEBUG: Location permission denied');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is required for full functionality',
            ),
          ),
        );
      }
    }
  }

  Future<Widget> _getNextScreen(BuildContext context) async {
    return await AuthUtils.getAuthenticatedScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () => AuthUtils.handleBackNavigation(context),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Image.asset(
                    'assets/images/active_service.png',
                    height: screenHeight * 0.35,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    'Permite que la aplicación acceda a tu ubicación',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Permítenos acceder a tu ubicación para conectarte con los mejores trabajadores cerca de ti y ofrecerte un servicio rápido y eficiente.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () async {
                      await requestLocationPermission(context);
                      final nextScreen = await _getNextScreen(context);
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => nextScreen),
                          (route) => false,
                        );
                      }
                    },
                    child: Text(
                      'Activar los servicios locales',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextButton(
                    onPressed: () async {
                      final nextScreen = await _getNextScreen(context);
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => nextScreen),
                          (route) => false,
                        );
                      }
                    },
                    child: Text(
                      'Omitir',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: const Color(0xFF22c55e),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  String? _selectedProfile;
  bool _termsAccepted = false;
  bool _isLoading = false;

  Future<void> _handleProfileSelection() async {
    if (_selectedProfile == null || !_termsAccepted) {
      print('DEBUG: Profile not selected or terms not accepted');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un perfil y acepta los términos'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('DEBUG: No authenticated user found');
        throw Exception('No authenticated user found');
      }

      final saveResponse = await ApiService.post(
        '/api/account-type/${user.uid}',
        {'account_type': _selectedProfile},
      );

      if (saveResponse['statusCode'] == 200 &&
          saveResponse['body']['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('account_type', _selectedProfile!);
        print('DEBUG: Account type saved: $_selectedProfile');
      } else {
        print(
          'DEBUG: Failed to save account type: ${saveResponse['body']['message'] ?? saveResponse['body']}',
        );
        throw Exception('Failed to save account type');
      }
    } catch (e) {
      print('DEBUG: Error saving account type: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('account_type', _selectedProfile!);
      print('DEBUG: Saved account type locally: $_selectedProfile');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (_selectedProfile == 'Client') {
          print('DEBUG: Navigating to PerfilScreen');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PerfilScreen()),
            (route) => false,
          );
        } else if (_selectedProfile == 'Chambeador') {
          print('DEBUG: Navigating to ChambeadorRegisterScreen');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => ChambeadorRegisterScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await AuthUtils.handleBackNavigation(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Selecciona tu Perfil',
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Selecciona si necesitas servicios técnicos o si quieres ofrecer tus habilidades como profesional.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      Expanded(
                        child: _profileOption(
                          buttonLabel: 'CLIENTE',
                          subtitle: 'Buscar servicios',
                          iconPath: 'assets/images/Group.png',
                          isSelected: _selectedProfile == 'Client',
                          onTap: () {
                            setState(() {
                              _selectedProfile = 'Client';
                            });
                          },
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: _profileOption(
                          buttonLabel: 'CHAMBEADOR',
                          subtitle: 'Ofrecer servicios',
                          iconPath:
                              'assets/images/Maintenance-3--Streamline-Milano.svg.png',
                          isSelected: _selectedProfile == 'Chambeador',
                          onTap: () {
                            setState(() {
                              _selectedProfile = 'Chambeador';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (val) {
                          setState(() {
                            _termsAccepted = val ?? false;
                          });
                        },
                        activeColor: const Color(0xFF22C55E),
                      ),
                      Expanded(
                        child: Text(
                          'He leído y acepto las política de privacidad, términos y condiciones',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedProfile != null && _termsAccepted
                          ? _handleProfileSelection
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedProfile != null && _termsAccepted
                                ? const Color(0xFF22C55E)
                                : Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Continuar',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileOption({
    required String buttonLabel,
    required String subtitle,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF22C55E) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF22C55E).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(iconPath, height: screenWidth * 0.15),
                SizedBox(height: screenWidth * 0.03),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenWidth * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonLabel,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.025),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: screenWidth * 0.035,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatefulWidget {
  final bool isActive;

  const _ProgressIndicator({required this.isActive});

  @override
  _ProgressIndicatorState createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<_ProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _colorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: const Color(0xFF22c55e),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _ProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isActive ? screenWidth * 0.06 : screenWidth * 0.025,
              height: screenWidth * 0.025,
              decoration: BoxDecoration(
                shape: widget.isActive ? BoxShape.rectangle : BoxShape.circle,
                color: _colorAnimation.value,
                borderRadius: widget.isActive
                    ? BorderRadius.circular(screenWidth * 0.03)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color:
                        (widget.isActive
                                ? const Color(0xFF22c55e)
                                : Colors.grey.shade200)
                            .withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}