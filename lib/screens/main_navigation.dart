import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../utils/app_colors.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'favorites/favorites_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Accueil',
    ),
    NavigationItem(
      icon: CupertinoIcons.search,
      activeIcon: CupertinoIcons.search,
      label: 'Rechercher',
    ),
    NavigationItem(
      icon: CupertinoIcons.heart,
      activeIcon: CupertinoIcons.heart_fill,
      label: 'Favoris',
    ),
    NavigationItem(
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = isDark ? AppColors.grey700 : AppColors.grey200;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(
                top: BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _navigationItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = _currentIndex == index;

                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                            if (index == 2) {
                              context.read<FavoriteProvider>().loadFavorites();
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6), // Réduit de 10 à 6
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  size: 22, // Réduit de 26 à 22
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                                const SizedBox(height: 2), // Réduit de 4 à 2
                                Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 10, // Réduit de 11 à 10
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
