import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the device's native maps app with directions to [address].
Future<void> openDirections(String address) async {
  final query = Uri.encodeComponent(address);
  final uri = Platform.isIOS
      ? Uri.parse('https://maps.apple.com/?daddr=$query')
      : Uri.parse('geo:0,0?q=$query');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }

  // Fallback: Google Maps web URL works on any platform with a browser.
  final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query');
  if (await canLaunchUrl(webUri)) {
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('[MapLauncher] No app available to open directions to "$address"');
  }
}
