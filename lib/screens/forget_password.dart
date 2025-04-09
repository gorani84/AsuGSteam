import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gridscout/constants.dart';
import 'package:gridscout/services/auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  String? _errorMessage; // To store error messages
  String? _successMessage; // To store success messages
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
                  const SizedBox(height: 20),
                  // Text below the logo
                  Text(
                    'Reset Password',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      color: kSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Form for email input
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
                        const SizedBox(height: 20),
                        // Error message display
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // Success message display
                        if (_successMessage != null) ...[
                          Text(
                            _successMessage!,
                            style: const TextStyle(color: kSecondaryColor),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // Reset Password Button
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
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
                                  _successMessage =
                                      null; // Reset success message
                                });

                                String email = emailController.text.trim();
                                await AuthService().resetPassword(
                                  email,
                                  (err) {
                                    setState(() {
                                      _errorMessage = err;
                                      _successMessage =
                                          null; // Reset success message on error
                                    });
                                  },
                                );

                                // Show success message
                                setState(() {
                                  _successMessage =
                                      'Check your email to reset your password!';
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
                                    'Send Reset Link',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
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
