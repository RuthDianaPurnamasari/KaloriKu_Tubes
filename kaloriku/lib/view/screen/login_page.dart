import 'package:flutter/material.dart';
import 'package:kaloriku/model/login_model.dart';
import 'package:kaloriku/services/api_services.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:kaloriku/view/screen/bottom_navbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiServices _dataService = ApiServices();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    bool isLoggedIn = await AuthManager.isLoggedIn();
    if (isLoggedIn) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DynamicBottomNavbar(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username tidak boleh kosong';
    if (value.length < 4) return 'Masukkan minimal 4 karakter';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 3) return 'Masukkan minimal 3 karakter';
    return null;
  }

  Future<void> _handleLogin() async {
    final isValidForm = _formKey.currentState!.validate();
    if (!isValidForm) return;

    setState(() {
      _isLoading = true;
    });

    final loginData = LoginInput(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    try {
      LoginResponse? res = await _dataService.login(loginData);

      if (res?.status == 200) {
        await AuthManager.login(_usernameController.text, res?.token ?? '');
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const DynamicBottomNavbar()),
            (route) => false,
          );
        }
      } else {
        displaySnackbar(res?.message ?? 'Unknown error');
      }
    } catch (e) {
      displaySnackbar('Terjadi kesalahan: $e');
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Login Form
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    // Login Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: _validateUsername,
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.account_circle_rounded),
                                hintText: 'Masukkan username...',
                                labelText: 'Username',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                fillColor: Color.fromARGB(255, 242, 254, 255),
                                filled: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              obscureText: true,
                              validator: _validatePassword,
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.password_rounded),
                                hintText: 'Masukkan password...',
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                fillColor: Color.fromARGB(255, 242, 254, 255),
                                filled: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('Login'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void displaySnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}