import 'package:flutter/material.dart';
import 'dart:async';
import 'package:chambea/screens/chambeador/chambeadorregister_screen.dart';
import 'package:chambea/screens/client/perfil_screen.dart';
import 'package:chambea/screens/chambeador/antecedentes_screen.dart';

void main() {
  runApp(const ChambeaApp());
}

class ChambeaApp extends StatelessWidget {
  const ChambeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const SplashScreen(),
    );
  }
}

// Splash Screen
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
      Navigator.pushReplacement(
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

// Onboarding 1
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
                    fontSize:
                        screenWidth * 0.045, // Smaller font (Medium: 0.05)
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'Realiza tus actividades con tranquilidad mientras nuestros profesionales se encargan de todo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
                        Navigator.pushReplacement(
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
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
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

// Onboarding 2
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
                    fontSize:
                        screenWidth * 0.045, // Smaller font (Medium: 0.05)
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'Conecta con trabajadores de confianza en tu vecindario para ayudarte en casa, apartamento u oficina.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
                        Navigator.pushReplacement(
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
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
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

// Onboarding 3
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
                    fontSize:
                        screenWidth * 0.045, // Smaller font (Medium: 0.05)
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'Elige el momento perfecto para ti y el trabajador con flexibilidad y facilidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
                        Navigator.pushReplacement(
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
                          fontSize:
                              screenWidth *
                              0.035, // Smaller font (Medium: 0.038)
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
                    size: 20, // Reduced icon size for smaller aesthetic
                  ),
                  label: Text(
                    'Comenzar',
                    style: TextStyle(
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
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

// Login Screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    fontSize:
                        screenWidth * 0.045, // Smaller font (Medium: 0.05)
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'Te enviaremos un código para verificar tu número telefónico',
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag, color: Colors.grey),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            '+591',
                            style: TextStyle(
                              fontSize:
                                  screenWidth *
                                  0.035, // Smaller font (Medium: 0.038)
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    hintText: 'Número de teléfono',
                    hintStyle: TextStyle(
                      color: Colors.black38,
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OTPScreen()),
                    );
                  },
                  child: Text(
                    'Enviar código',
                    style: TextStyle(
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    // Add Google sign-in logic here
                  },
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  'Al unirte a nuestra aplicación, aceptas nuestros Términos de Uso y Política de privacidad',
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.03, // Smaller font (Medium: 0.032)
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

// OTPScreen
class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  String _otp = '';

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged() {
    _otp = _otpControllers.map((controller) => controller.text).join();
    if (_otp.length == 4) {
      if (_otp == '7421') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ActiveServiceScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Código incorrecto')));
      }
    }
  }

  Widget _otpTextField(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.12,
      height: screenWidth * 0.12,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: TextField(
        controller: _otpControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: screenWidth * 0.045, // Smaller font (Medium: 0.05)
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
          _onOtpChanged();
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
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
                    fontSize:
                        screenWidth * 0.045, // Smaller font (Medium: 0.05)
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'Te enviamos un código de verificación al número\n+591 394 934 834',
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) => _otpTextField(index)),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Puedes reenviar el código en 60 segundos',
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.03, // Smaller font (Medium: 0.032)
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  'From Messages\n123 456',
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.03, // Smaller font (Medium: 0.032)
                    color: Colors.black54,
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

// Active Service Screen
class ActiveServiceScreen extends StatelessWidget {
  const ActiveServiceScreen({super.key});

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
                    fontSize:
                        screenWidth * 0.045, // Smaller font (Medium: 0.05)
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  'Permítenos acceder a tu ubicación para conectarte con los mejores trabajadores cerca de ti y ofrecerte un servicio rápido y eficiente.',
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileSelectionScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Activar los servicios locales',
                    style: TextStyle(
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileSelectionScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Omitir',
                    style: TextStyle(
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
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

// Profile Selection Screen
class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  _ProfileSelectionScreenState createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  String? _selectedProfile;
  bool _termsAccepted = false;

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
                    fontSize:
                        screenWidth * 0.045, // Smaller font (Medium: 0.05)
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
                    fontSize:
                        screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
                          fontSize:
                              screenWidth *
                              0.03, // Smaller font (Medium: 0.032)
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
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
                  onPressed:
                      _selectedProfile != null && _termsAccepted
                          ? () {
                            if (_selectedProfile == 'Chambeador') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChambeadorRegisterScreen(),
                                ),
                              );
                            } else if (_selectedProfile == 'Cliente') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PerfilScreen(),
                                ),
                              );
                            }
                          }
                          : null,
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
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
            colors:
                isSelected
                    ? [Colors.white, const Color(0xFFE8F5E9)]
                    : [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
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
                      fontSize:
                          screenWidth * 0.035, // Smaller font (Medium: 0.038)
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected ? const Color(0xFF22c55e) : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize:
                          screenWidth * 0.03, // Smaller font (Medium: 0.032)
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

// Progress Indicator Widget
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
                borderRadius:
                    widget.isActive ? BorderRadius.circular(12) : null,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isActive
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
