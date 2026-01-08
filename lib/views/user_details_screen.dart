import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart'; // Ensure UserModel is imported
import '../../providers/auth_provider.dart';
import '../../services/donation_service.dart';
import '../../providers/theme_provider.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _matricController = TextEditingController();
  final _bioController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isLoading = false;

  final DonationService _donationService = DonationService(); 

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUserModel;
    if (user != null) {
      _nameController.text = user.name;
      // Matric is usually read-only or derived, keeping your logic:
      _matricController.text = user.role == 'student' ? "2212901" : "Staff/Donor";
      _phoneController.text = user.phone ?? "";
      _bioController.text = user.bio ?? "";
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUserModel;

      if (user != null) {
        String? uploadedImageUrl;

        // 1. Upload new image if selected
        if (_imageFile != null) {
          uploadedImageUrl = await _donationService.uploadImage(_imageFile!);
          if (uploadedImageUrl == null) {
            throw "Failed to upload image.";
          }
        }

        // 2. Create the Updated User Model
        // We preserve uid, email, and role from the original user
        UserModel updatedUser = UserModel(
          uid: user.uid,
          email: user.email,
          role: user.role,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          bio: _bioController.text.trim(),
          // Use new image if uploaded, otherwise keep the old one
          photoUrl: uploadedImageUrl ?? user.photoUrl,
        );

        // 3. Send the object to the Provider
        String? error = await authProvider.updateUser(updatedUser);

        if (mounted) {
          if (error == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile Updated Successfully!")),
            );
            Navigator.pop(context);
          } else {
            // Show error returned by provider
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $error")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAF9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    ImageProvider getImageProvider() {
      if (_imageFile != null) {
        if (kIsWeb) return NetworkImage(_imageFile!.path);
        return FileImage(File(_imageFile!.path));
      } else {
        final user = Provider.of<AuthProvider>(context).currentUserModel;
        if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
          return NetworkImage(user.photoUrl!);
        }
        return const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200");
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("User Details", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cardColor, width: 4),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: getImageProvider(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildTextField("Full Name", _nameController, Icons.person, isDark),
              const SizedBox(height: 16),
              // Matric is often read-only, you can add readOnly: true if needed
              _buildTextField("Matric Number", _matricController, Icons.badge, isDark), 
              const SizedBox(height: 16),
              _buildTextField("Phone Number", _phoneController, Icons.phone, isDark),
              const SizedBox(height: 16),
              _buildTextField("Bio", _bioController, Icons.info_outline, isDark, maxLines: 3),

              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isDark, {int maxLines = 1}) {
    final fillColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}