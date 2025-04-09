<<<<<<< HEAD
import 'package:gridscout/constants.dart';
import 'package:gridscout/services/auth.dart';
=======
import 'package:asugs/constants.dart';
import 'package:asugs/services/auth.dart';
>>>>>>> 2eb82753615ad9020e69eb297e85e87fbb301350
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Track password visibility
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  String? _errorMessage; // To store error messages
  bool _isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Logo
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(75), // Circular logo
                      child: Image.asset(
                        "assets/images/logo_white.png",
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing between logo and text
                  // Text below the logo
                  Text(
                    'Welcome to Grid Scout!',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      color: kSecondaryColor, // Use the secondary color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Form for email and password inputs
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email input
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10), // Spacing between fields
                        // Password input with show/hide functionality
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible =
                                        !_isPasswordVisible; // Toggle visibility
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              } else if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Error message display
                        if (_errorMessage != null) ...[
                          Row(
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/forget');
                                },
                                child: Text(
                                  "Forget Password?",
                                  style: const TextStyle(
                                    color: kSecondaryColor,
                                    decorationStyle: TextDecorationStyle.wavy,
                                    decoration: TextDecoration.underline,
                                    decorationColor: kSecondaryColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                        // Login Button
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Button color
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  !_isLoading) {
                                setState(() {
                                  _isLoading = true;
                                  _errorMessage = null;
                                });
                                String email = emailController.text.trim();
                                String password =
                                    passwordController.text.trim();
                                User? user = await AuthService()
                                    .signInWithEmailAndPassword(email, password,
                                        (err) {
                                  setState(() {
                                    _errorMessage = err;
                                  });
                                });
                                if (user != null) {
                                  Navigator.pushNamed(context, '/');
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Signup button for navigation to signup page
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        if (_isLoading) return;
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
<<<<<<< HEAD
                        'Create new account',
=======
                        'Signup new account',
>>>>>>> 2eb82753615ad9020e69eb297e85e87fbb301350
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
