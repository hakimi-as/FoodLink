import 'dart:io'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/donation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class DonateFormScreen extends StatefulWidget {
  const DonateFormScreen({super.key});

  @override
  State<DonateFormScreen> createState() => _DonateFormScreenState();
}

class _DonateFormScreenState extends State<DonateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController(); 
  final _locationController = TextEditingController();
  int _quantity = 1;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 22, minute: 0);
  bool _isHalalConfirmed = false; 

  @override
  Widget build(BuildContext context) {
    final donationProvider = Provider.of<DonationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // --- Dynamic Colors ---
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    // Fix: Explicitly cast nullable colors to non-null
    final inputFillColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[50]!;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Add Food Details", style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: () => _showImageSourceModal(context, donationProvider),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: donationProvider.selectedImage != null
                      ? _buildImagePreview(donationProvider.selectedImage!) 
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            Text("Tap to add photo", style: TextStyle(color: textColor)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(_titleController, "Menu Title", textColor, inputFillColor),
              const SizedBox(height: 12),
              _buildTextField(_descController, "Description", textColor, inputFillColor),
              const SizedBox(height: 12),
              _buildTextField(_locationController, "Pickup Location", textColor, inputFillColor),
              const SizedBox(height: 20),

              // Quantity & Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                            ),
                            Text("$_quantity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Best Before", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        TextButton.icon(
                          icon: const Icon(Icons.access_time, color: Colors.orange),
                          label: Text(_selectedTime.format(context), style: TextStyle(color: textColor)),
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null) setState(() => _selectedTime = picked);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Halal Checkbox
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B5E20) : Colors.green[50], 
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.5))
                ),
                child: CheckboxListTile(
                  activeColor: Colors.green,
                  title: Text("Halal Confirmation", style: TextStyle(color: textColor)),
                  subtitle: Text("I confirm this food is Halal.", style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600])),
                  value: _isHalalConfirmed,
                  onChanged: (val) => setState(() => _isHalalConfirmed = val!),
                ),
              ),
              
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  icon: donationProvider.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.volunteer_activism),
                  label: Text(donationProvider.isLoading ? "Posting..." : "Donate Food"),
                  onPressed: donationProvider.isLoading 
                    ? null 
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          if (!_isHalalConfirmed) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must confirm the food is Halal.")));
                            return;
                          }

                          final now = DateTime.now();
                          final expiry = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);

                          String? error = await donationProvider.submitDonation(
                            donorId: authProvider.currentUserModel!.uid,
                            donorName: authProvider.currentUserModel!.name,
                            title: _titleController.text,
                            description: _descController.text,
                            location: _locationController.text,
                            quantity: _quantity,
                            expiry: expiry,
                          );

                          if (error == null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Food Posted Successfully!")));
                            Navigator.pop(context);
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? "Error")));
                          }
                        }
                    },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, Color textColor, Color fillColor) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
      ),
      validator: (val) => val!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildImagePreview(XFile file) {
    if (kIsWeb) {
      return Image.network(file.path, fit: BoxFit.cover);
    } else {
      return Image.file(File(file.path), fit: BoxFit.cover);
    }
  }

  void _showImageSourceModal(BuildContext context, DonationProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                provider.pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                provider.pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}