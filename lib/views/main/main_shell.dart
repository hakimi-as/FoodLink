import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/claim_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'feed_screen.dart';
import 'donate_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initListeners());
  }

  void _initListeners() {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    final food = context.read<FoodProvider>();
    final claim = context.read<ClaimProvider>();

    food.listenFeed();
    if (auth.user!.isDonor) {
      food.listenDonorItems(auth.user!.uid);
      claim.listenDonorClaims(auth.user!.uid);
    } else if (auth.user!.isStudent) {
      claim.listenMyClaims(auth.user!.uid);
    } else if (auth.user!.isAdmin) {
      food.listenAllItems();
      claim.listenAllClaims();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          FeedScreen(),
          DonateScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        isDonor: auth.user?.isDonor ?? false,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
