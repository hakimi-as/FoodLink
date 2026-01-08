import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // 1. ADDED PHONE CONTROLLER
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedRole = 'student';
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
                  color: Colors.black.withValues(alpha: 0.05), // Updated to withValues
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
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withValues(alpha: 0.2), // Updated to withValues
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 40,
                        errorBuilder: (c, e, s) => Icon(Icons.person_add, size: 30, color: _primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Title
                  Text(
                    "Join Us",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Create your account today.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 3. Name Field
                  _buildLabel("Full Name"),
                  _buildInputField(
                    controller: _nameController,
                    hintText: "e.g. Ali Bin Abu",
                    validator: (v) => v!.isEmpty ? "Name Required" : null,
                  ),
                  const SizedBox(height: 16),

                  // 4. Email Field
                  _buildLabel("Email"),
                  _buildInputField(
                    controller: _emailController,
                    hintText: "student@uni.edu.my",
                    validator: (v) => v!.contains('@') ? null : "Invalid Email",
                  ),
                  const SizedBox(height: 16),

                  // 5. Phone Number Field (ADDED)
                  _buildLabel("Phone Number"),
                  _buildInputField(
                    controller: _phoneController,
                    hintText: "e.g. +60123456789",
                    validator: (v) => v!.length < 8 ? "Valid Phone Required" : null,
                  ),
                  const SizedBox(height: 16),

                  // 6. Password Field
                  _buildLabel("Password"),
                  _buildInputField(
                    controller: _passwordController,
                    hintText: "Min 6 characters",
                    obscureText: !_isPasswordVisible,
                    validator: (v) => v!.length < 6 ? "Password too short" : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 7. Role Dropdown
                  _buildLabel("I am a..."),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: _inputBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _inputBorderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1F2937), fontSize: 16),
                        dropdownColor: Colors.white,
                        items: const [
                          DropdownMenuItem(value: 'student', child: Text("Student (Receiver)")),
                          DropdownMenuItem(value: 'donor', child: Text("Donor (Provider)")),
                        ],
                        onChanged: (val) => setState(() => _selectedRole = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 8. Register Button
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
                          color: _primaryColor.withValues(alpha: 0.3), // Updated to withValues
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                // FIX: Now passing 5 Arguments including phone
                                String? error = await authProvider.register(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  _nameController.text.trim(),
                                  _selectedRole,
                                  _phoneController.text.trim(), // <--- Added Phone
                                );

                                if (error == null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! Please Login.")));
                                  Navigator.pop(context);
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? "Error")));
                                }
                              }
                            },
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Create Account",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 9. Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", 
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 14)
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Log In",
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}