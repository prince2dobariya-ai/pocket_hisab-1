import 'package:flutter/material.dart';
import 'package:pocket_hisab/screens/drawer/home_drawer.dart';
import 'package:pocket_hisab/screens/hisab/person_screen.dart';
import 'package:pocket_hisab/screens/home/home_screen.dart';
import 'package:pocket_hisab/screens/wallet/wallet_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(),
      appBar: CustomAppBar(title: "Khissu"),
      body: TabBarView(
        controller: _tabController,
        children: [HomeScreen(), WalletScreen(), PersonScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (value) {
          setState(() {
            _tabController.animateTo(value);
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hisab"),
        ],
      ),
    );
  }
}
