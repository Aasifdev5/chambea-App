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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firebase_options.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:chambea/screens/chambeador/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/blocs/client/client_bloc.dart';
import 'package:chambea/blocs/chambeador/chambeador_bloc.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(const ChambeaApp());
}

class ApiService {
  static const String baseUrl = 'https://chambea.lat';

  static Future<Map<String, String>> getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken(true); // Force refresh token
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> isLoggedIn() async {
    return FirebaseAuth.instance.currentUser != null;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    print(
      'DEBUG: GET $endpoint response: ${response.statusCode} ${response.body}',
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load data: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
    print(
      'DEBUG: POST $endpoint response: ${response.statusCode} ${response.body}',
    );
    return {
      'statusCode': response.statusCode,
      'body': json.decode(response.body),
    };
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
    return {
      'statusCode': response.statusCode,
      'body': json.decode(response.body),
    };
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return {
      'statusCode': response.statusCode,
      'body': json.decode(response.body),
    };
  }

  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String fieldName,
    File file,
  ) async {
    final headers = await getHeaders();
    headers.remove('Content-Type');
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to upload file: ${response.statusCode}');
  }
}

class ChambeaApp extends StatelessWidget {
  const ChambeaApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final isLoggedIn = await ApiService.isLoggedIn();
    if (!isLoggedIn) {
      print('DEBUG: User not logged in, redirecting to SplashScreen');
      return const SplashScreen();
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('DEBUG: No authenticated user, redirecting to SplashScreen');
        return const SplashScreen();
      }

      final response = await ApiService.get('/api/account-type/${user.uid}');
      print('DEBUG: Fetch account type response: $response');
      if (response['status'] == 'success') {
        final accountType = response['data']['account_type'] ?? '';
        if (accountType == 'Client') {
          print('DEBUG: User is Client, redirecting to ClientHomeScreen');
          return const ClientHomeScreen();
        } else if (accountType == 'Chambeador') {
          print('DEBUG: User is Chambeador, redirecting to HomeScreen');
          return const HomeScreen();
        }
      }
      print(
        'DEBUG: No account type found, redirecting to ProfileSelectionScreen',
      );
      return const ProfileSelectionScreen();
    } catch (e) {
      print('DEBUG: Error fetching account type: $e');
      if (e.toString().contains('404')) {
        print('DEBUG: Profile not found, likely a new user');
      }
      return const ProfileSelectionScreen();
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
        home: FutureBuilder<Widget>(
          future: _getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text('Error al cargar la pantalla inicial'),
                ),
              );
            } else {
              return snapshot.data!;
            }
          },
        ),
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingOneScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.5,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingOneScreen extends StatelessWidget {
  const OnboardingOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnboardingTwoScreen(),
                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingTwoScreen extends StatelessWidget {
  const OnboardingTwoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnboardingThreeScreen(),
                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingThreeScreen extends StatelessWidget {
  const OnboardingThreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
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

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ActiveServiceScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error en Google Sign-In: $e')));
      }
    }
  }

  Future<void> _startPhoneAuth() async {
    try {
      final phoneNumber = _phoneNumber.phoneNumber;
      if (phoneNumber == null || phoneNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa un número de teléfono'),
          ),
        );
        return;
      }

      final isValid = _validatePhoneNumber(phoneNumber);
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Número de teléfono inválido para el país seleccionado',
            ),
          ),
        );
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ActiveServiceScreen()),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.message ?? 'Verificación fallida'}'),
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
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
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el código: $e')),
        );
      }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                OutlinedButton.icon(
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

  @override
  void initState() {
    super.initState();
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
    if (code != null && code!.length == 6) {
      setState(() {
        _otp = code!;
        for (int i = 0; i < 6; i++) {
          _otpControllers[i].text = _otp[i];
        }
      });
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    _otp = _otpControllers.map((controller) => controller.text).join();
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un código de 6 dígitos'),
        ),
      );
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otp,
      );
      await _auth.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ActiveServiceScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Código incorrecto: $e')));
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ActiveServiceScreen()),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.message ?? 'Verificación fallida'}'),
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
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
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar el código: $e')),
        );
      }
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
        onChanged: (value) {
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

    return Scaffold(
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
                Text(
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
    );
  }
}

class ActiveServiceScreen extends StatelessWidget {
  const ActiveServiceScreen({super.key});

  Future<Widget> _getNextScreen() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('DEBUG: No authenticated user, redirecting to SplashScreen');
        return const SplashScreen();
      }

      final response = await ApiService.get('/account-type/${user.uid}');
      print(
        'DEBUG: ActiveServiceScreen fetch account type response: $response',
      );
      if (response['status'] == 'success') {
        final accountType = response['data']['account_type'] ?? '';
        if (accountType == 'Client') {
          print('DEBUG: User is Client, redirecting to ClientHomeScreen');
          return const ClientHomeScreen();
        } else if (accountType == 'Chambeador') {
          print('DEBUG: User is Chambeador, redirecting to HomeScreen');
          return const HomeScreen();
        }
      }
      print(
        'DEBUG: No account type found, redirecting to ProfileSelectionScreen',
      );
      return const ProfileSelectionScreen();
    } catch (e) {
      print('DEBUG: Error fetching account type in ActiveServiceScreen: $e');
      return const ProfileSelectionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                    final nextScreen = await _getNextScreen();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => nextScreen),
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
                    final nextScreen = await _getNextScreen();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => nextScreen),
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
    );
  }
}

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  _ProfileSelectionScreenState createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  String? _selectedProfile;
  bool _termsAccepted = false;
  bool _isLoading = false;

  Future<void> _handleProfileSelection() async {
    if (_selectedProfile == null || !_termsAccepted) return;

    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }
      print(
        'DEBUG: Current user: ${user.uid}, selectedProfile: $_selectedProfile',
      );

      final response = await ApiService.post('/account-type/${user.uid}', {
        'account_type': _selectedProfile,
      });
      print('DEBUG: Save account type response: $response');

      if (response['statusCode'] == 200 &&
          response['body']['status'] == 'success') {
        if (_selectedProfile == 'Client') {
          print('DEBUG: User selected Client, redirecting to ClientHomeScreen');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
            );
          }
        } else if (_selectedProfile == 'Chambeador') {
          print(
            'DEBUG: User selected Chambeador, redirecting to ChambeadorRegisterScreen',
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ChambeadorRegisterScreen()),
            );
          }
        }
      } else {
        throw Exception(
          'Failed to save profile type: ${response['statusCode']}',
        );
      }
    } catch (e) {
      print('DEBUG: Error saving profile type: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el tipo de cuenta: $e')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                Text(
                  'Selecciona tu Perfil',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'Elige si deseas contratar servicios o mostrar tus habilidades como profesional.',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _profileOption(
                      context,
                      profileType: 'Cliente',
                      description: 'Contrata servicios técnicos',
                      iconPath: 'assets/images/Group.png',
                      isSelected: _selectedProfile == 'Cliente',
                      onTap: () {
                        setState(() {
                          _selectedProfile = 'Cliente';
                        });
                      },
                    ),
                    _profileOption(
                      context,
                      profileType: 'Chambeador',
                      description: 'Ofrece tus servicios',
                      iconPath:
                          'assets/images/Maintenance-3--Streamline-Milano.svg.png',
                      isSelected: _selectedProfile == 'Chambeador',
                      onTap: () {
                        setState(() {
                          _selectedProfile = 'Chambeador';
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF22c55e),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Acepto la política de privacidad, términos y condiciones',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedProfile != null && _termsAccepted
                              ? const Color(0xFF22c55e)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFF22c55e).withOpacity(0.3),
                        ),
                        onPressed: _selectedProfile != null && _termsAccepted
                            ? _handleProfileSelection
                            : null,
                        child: Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
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
    );
  }

  Widget _profileOption(
    BuildContext context, {
    required String profileType,
    required String description,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: screenWidth * 0.4,
        height: screenHeight * 0.3,
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [Colors.white, const Color(0xFFE8F5E9)]
                : [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF22c55e).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? const Color(0xFF22c55e) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    iconPath,
                    height: screenHeight * 0.1,
                    width: screenHeight * 0.1,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    profileType,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF22c55e)
                          : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF22c55e),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isActive ? 24 : 10,
              height: 10,
              decoration: BoxDecoration(
                shape: widget.isActive ? BoxShape.rectangle : BoxShape.circle,
                color: _colorAnimation.value,
                borderRadius: widget.isActive
                    ? BorderRadius.circular(12)
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
