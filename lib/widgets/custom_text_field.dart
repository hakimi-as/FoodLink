import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final c = context.clr;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10.5, fontWeight: FontWeight.w700,
            color: c.muted, letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: GoogleFonts.dmSans(fontSize: 15, color: c.text),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: GoogleFonts.dmSans(color: c.hint, fontSize: 15),
            filled: true,
            fillColor: c.card,
            prefixIcon: Icon(widget.icon, color: c.hint, size: 18),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: c.hint, size: 18,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: c.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: c.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
          ),
        ),
      ],
    );
  }
}
