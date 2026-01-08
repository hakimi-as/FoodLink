import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
// Note: We removed the import for home_screen.dart because AuthWrapper handles navigation now.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  // Colors
  final Color _primaryColor = const Color(0xFFEA580C);
  final Color _backgroundColor = const Color(0xFFF3F4F6);
  final Color _inputBgColor = const Color(0xFFF9FAFB);
  final Color _inputBorderColor = const Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 650),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Icon Circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 50,
                        errorBuilder: (c, e, s) =>
                            Icon(Icons.rice_bowl, size: 30, color: _primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Title & Subtitle
                  Text(
                    "MySaveFood",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Share meals, spread kindness.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 3. Email Field
                  _buildLabel("Email"),
                  _buildInputField(
                    controller: _emailController,
                    hintText: "Enter your email",
                    validator: (v) => v!.contains('@') ? null : "Invalid Email",
                  ),
                  const SizedBox(height: 16),

                  // 4. Password Field
                  _buildLabel("Password"),
                  _buildInputField(
                    controller: _passwordController,
                    hintText: "••••••••",
                    obscureText: !_isPasswordVisible,
                    validator: (v) =>
                        v!.length < 6 ? "Password too short" : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 5. Login Button (FIXED)
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                // 1. Attempt Login
                                String? error = await authProvider.login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                // 2. Handle Result
                                if (context.mounted) {
                                  if (error != null) {
                                    // If Error: Show Snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(error)));
                                  } 
                                  // If Success: Do NOTHING.
                                  // The AuthWrapper in main.dart listens to the provider 
                                  // and will automatically switch to HomeScreen.
                                }
                              }
                            },
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Log In",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 6. OR Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[200])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Or continue with",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: Colors.grey[400])),
                      ),
                      Expanded(child: Divider(color: Colors.grey[200])),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 7. Google Button (FIXED)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[200]!),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final provider =
                            Provider.of<AuthProvider>(context, listen: false);

                        String? error = await provider.googleLogin();

                        if (context.mounted) {
                          // Only handle errors. Success is handled by AuthWrapper.
                          if (error != null && error != "Google Sign-In Cancelled") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/480px-Google_%22G%22_logo.svg.png',
                            height: 24,
                            errorBuilder: (c, e, s) => const Icon(
                                Icons.g_mobiledata,
                                color: Colors.blue,
                                size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Google",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 8. Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey[400], fontSize: 14)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()));
                        },
                        child: Text(
                          "Register",
                          style: GoogleFonts.plusJakartaSans(
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _inputBorderColor),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1F2937)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}