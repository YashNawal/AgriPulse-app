import 'market_profit_arbitrage_screen.dart';
import 'profit_calculator_screen.dart';
import 'farm_stock_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agri_provider.dart';
import '../../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'prices_screen.dart';
import 'markets_screen.dart';
import 'store_screen.dart';
import 'chat_screen.dart';
import 'soil_screen.dart';
import 'disease_screen.dart';
import 'alerts_screen.dart';
import 'onboarding/select_language_screen.dart';
import 'onboarding/your_details_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (index >= 0 && index <= 4) {
      setState(() => _currentIndex = index);
    } else if (index == 5) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SoilScreen()));
    } else if (index == 6) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseScreen()));
    } else if (index == 7) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final agri = context.watch<AgriProvider>();
    final lang = context.watch<LanguageProvider>();

    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const PricesScreen(),
      const MarketsScreen(),
      const StoreScreen(),
      const ChatScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('app_name'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Text(
                  agri.isSupabaseConnected ? '🟢 Supabase Cloud Sync' : (agri.isOnline ? '🟢 API Online' : '🟠 Offline Smart Cache'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: (agri.isSupabaseConnected || agri.isOnline) ? AppTheme.accentEmerald : AppTheme.amberText,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Switcher Dropdown Menu
          PopupMenuButton<String>(
            initialValue: lang.currentLang,
            onSelected: (code) => lang.setLanguage(code),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    lang.currentLanguageName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              for (final l in LanguageProvider.supportedLanguages)
                PopupMenuItem(
                  value: l.code,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.nativeName,
                        style: TextStyle(
                          fontWeight: l.code == lang.currentLang ? FontWeight.w800 : FontWeight.w600,
                          color: l.code == lang.currentLang ? AppTheme.primaryGreen : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l.name,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.cardWhite,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.eco, color: Colors.white, size: 36),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          agri.isGuestMode ? 'Guest Mode' : '🟢 Supabase Synced',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (agri.currentFarmer?.name.isNotEmpty == true) ? agri.currentFarmer!.name : lang.t('app_name'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    agri.currentFarmer != null
                        ? '📍 ${agri.currentFarmer!.district}, ${agri.currentFarmer!.state}'
                        : 'AI Agri Intelligence & Farm Store',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (agri.currentFarmer != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '🌾 ${agri.currentFarmer!.farmArea % 1 == 0 ? agri.currentFarmer!.farmArea.toInt() : agri.currentFarmer!.farmArea} ${agri.currentFarmer!.farmAreaUnit} • ${agri.currentFarmer!.savedCrops.take(3).join(', ')}',
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: AppTheme.primaryGreen),
              title: Text(lang.t('nav_home')),
              selected: _currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: AppTheme.primaryGreen),
              title: Text(lang.t('nav_prices')),
              selected: _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate_outlined, color: AppTheme.primaryGreen),
              title: Text(lang.t('nav_markets')),
              selected: _currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows_rounded, color: AppTheme.accentEmerald),
              title: const Text('Highest Price & Transport Profit'),
              subtitle: const Text('Distance, vehicle freight & net cash arbitrage', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketProfitArbitrageScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_rupee, color: AppTheme.accentEmerald),
              title: const Text('Farm Profit & MSP Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitCalculatorScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryGreen),
              title: const Text('My Farm Stock & Crops'),
              subtitle: Text(
                '${agri.farmStock.where((e) => e.isHarvested).length} stored • ${agri.farmStock.where((e) => e.isGrowing).length} in-ground',
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmStockScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.storefront, color: AppTheme.primaryGreen),
              title: Text(lang.t('nav_store')),
              selected: _currentIndex == 3,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryGreen),
              title: Text(lang.t('nav_chat')),
              selected: _currentIndex == 4,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.landscape_outlined, color: AppTheme.amberText),
              title: Text(lang.t('nav_soil')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SoilScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.biotech_outlined, color: AppTheme.roseText),
              title: Text(lang.t('nav_disease')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF25D366)),
              title: Text(lang.t('nav_alerts')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppTheme.primaryGreen),
              title: const Text('My Farm Details (Profile)'),
              subtitle: Text(
                agri.currentFarmer?.district != null ? '📍 ${agri.currentFarmer!.district}, ${agri.currentFarmer!.state}' : 'Configure location & crops',
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => YourDetailsScreen(initialProfile: agri.currentFarmer)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
              title: const Text('Change Language'),
              subtitle: Text(lang.currentLanguageName, style: const TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SelectLanguageScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.roseText),
              title: const Text('Sign Out / Switch Account', style: TextStyle(color: AppTheme.roseText)),
              onTap: () async {
                Navigator.pop(context);
                await agri.logOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SelectLanguageScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardWhite,
          border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.cardWhite,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: AppTheme.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: lang.t('nav_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.trending_up),
              activeIcon: const Icon(Icons.trending_up_rounded),
              label: lang.t('nav_prices'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calculate_outlined),
              activeIcon: const Icon(Icons.calculate),
              label: lang.t('nav_markets'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.storefront_outlined),
              activeIcon: const Icon(Icons.storefront),
              label: lang.t('nav_store'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              activeIcon: const Icon(Icons.chat_bubble),
              label: lang.t('nav_chat'),
            ),
          ],
        ),
      ),
    );
  }
}
