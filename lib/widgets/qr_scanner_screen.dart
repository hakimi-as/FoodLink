import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/theme/app_colors.dart';
import '../models/claim_model.dart';

/// Full-screen camera scanner donors use to confirm a student's pickup QR
/// code. Returns the matched [ClaimModel] on success, or null if cancelled.
class QrScannerScreen extends StatefulWidget {
  final List<ClaimModel> pendingClaims;

  const QrScannerScreen({super.key, required this.pendingClaims});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    final match = widget.pendingClaims.where((c) => c.claimId == raw).firstOrNull;
    if (match == null) {
      setState(() => _errorText = 'This code doesn\'t match a pending claim on your listings.');
      return;
    }

    _handled = true;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(match);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Scan Pickup Code', style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Viewfinder frame
          Center(
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            left: 24, right: 24, bottom: 40,
            child: Column(children: [
              Text('Point your camera at the student\'s QR code',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_errorText!, textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12.5)),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
