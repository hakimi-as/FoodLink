import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/donation_service.dart';
import '../providers/theme_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DonationService _donationService = DonationService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUserModel;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // --- COLORS ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1F2937);
    
    // FIX 1: Ensure subtitleColor is not null using '!' or a default
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    
    final iconOpacity = isDark ? 0.2 : 0.1; 

    if (user == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: Text("Please login first", style: TextStyle(color: titleColor)))
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            "History",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold, 
              color: titleColor, 
            ),
          ),
          centerTitle: true,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: titleColor),
          bottom: TabBar(
            labelColor: const Color(0xFFEA580C),
            unselectedLabelColor: isDark ? Colors.grey[600] : Colors.grey[400],
            indicatorColor: const Color(0xFFEA580C),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "My Claims"),
              Tab(text: "My Donations"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHistoryList(
              stream: _donationService.getUserClaims(user.uid),
              emptyMessage: "You haven't claimed any food yet.",
              isDonation: false,
              isDark: isDark,
              cardColor: cardColor,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              iconOpacity: iconOpacity,
            ),
            _buildHistoryList(
              stream: _donationService.getUserDonations(user.uid),
              emptyMessage: "You haven't donated any food yet.",
              isDonation: true,
              isDark: isDark,
              cardColor: cardColor,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              iconOpacity: iconOpacity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList({
    required Stream<List<Map<String, dynamic>>> stream,
    required String emptyMessage,
    required bool isDonation,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required double iconOpacity,
  }) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: titleColor)));
        }

        final items = snapshot.data ?? [];

        // --- EMPTY STATE ---
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // FIX 2: Use .withValues(alpha: ...) instead of .withOpacity()
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDonation ? Icons.volunteer_activism : Icons.shopping_basket,
                    size: 50,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: GoogleFonts.plusJakartaSans(
                    color: subtitleColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // --- LIST STATE ---
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            final title = item['title'] ?? 'Unknown Item';
            final quantity = item['quantity'] ?? 1;
            final timestamp = item['timestamp']?.toDate() ?? DateTime.now();
            final formattedDate = DateFormat('MMM d, h:mm a').format(timestamp);
            final status = item['status'] ?? 'Unknown';

            // Determine Primary Color for this card
            final primaryColor = isDonation ? Colors.green : Colors.orange;

            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                   BoxShadow(
                      // FIX 3: Updated to withValues
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                   )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 1. Icon Box
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        // FIX 4: Updated to withValues
                        color: primaryColor.withValues(alpha: iconOpacity),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isDonation ? Icons.volunteer_activism : Icons.restaurant,
                        color: primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // 2. Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          
                          // Time Row
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 12, color: subtitleColor),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: GoogleFonts.plusJakartaSans(
                                  color: subtitleColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Quantity Row
                          Text(
                            isDonation 
                                ? "Donated: $quantity unit(s)" 
                                : "Claimed: $quantity unit(s)",
                            style: GoogleFonts.plusJakartaSans(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.transparent : Colors.grey[200]!
                        ),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available': return Colors.green;
      case 'reserved': return Colors.orange;
      case 'completed': return Colors.blue;
      case 'expired': return Colors.red;
      default: return Colors.grey;
    }
  }
}