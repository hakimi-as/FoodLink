import 'package:flutter/material.dart';
// FIX 1: Hide AuthProvider to avoid conflict
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; 
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  final User firebaseUser;

  const RoleSelectionScreen({super.key, required this.firebaseUser});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _confirmRole(String role) async {
    setState(() => _isLoading = true);
    try {
      UserModel newUser = await _authService.finalizeGoogleRegistration(
          widget.firebaseUser, role);
      
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).setCurrentUser(newUser);
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome!",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Please select your account type to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildRoleButton(
                  title: "I am a Student",
                  subtitle: "I want to claim free food.",
                  icon: Icons.school_outlined,
                  color: Colors.orange,
                  onTap: () => _confirmRole('student'),
                ),
                const SizedBox(height: 20),

                _buildRoleButton(
                  title: "I am a Donor/Staff",
                  subtitle: "I want to donate food.",
                  icon: Icons.volunteer_activism_outlined,
                  color: Colors.blue,
                  onTap: () => _confirmRole('staff'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              // FIX 2: Use withValues
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[300], size: 16),
          ],
        ),
      ),
    );
  }
}