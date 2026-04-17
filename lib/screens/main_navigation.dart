import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../utils/app_colors.dart';
import '../utils/role_permissions.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'favorites/favorites_screen.dart';
import 'profile/profile_screen.dart';
import 'commission/commissionnaire_dashboard.dart';
import 'commission/pending_approval_screen.dart';

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
        final user = authProvider.user;
        final hasGestionTab = user != null &&
            RolePermissions.canAccessCommissionFeatures(user);

        // Commissionnaire avec compte en attente ou refusé
        final isPendingCommissionnaire = user != null &&
            RolePermissions.isCommissionnaire(user) &&
            !hasGestionTab;

        // Screens dynamiques selon le rôle
        final screens = [
          const HomeScreen(),
          const SearchScreen(),
          const FavoritesScreen(),
          if (hasGestionTab) const CommissionnaireDashboard(),
          if (isPendingCommissionnaire) const PendingApprovalScreen(),
          const ProfileScreen(),
        ];

        // Items de navigation dynamiques
        final navItems = [
          _NavItem(CupertinoIcons.house, CupertinoIcons.house_fill, 'Accueil'),
          _NavItem(CupertinoIcons.search, CupertinoIcons.search, 'Rechercher'),
          _NavItem(CupertinoIcons.heart, CupertinoIcons.heart_fill, 'Favoris'),
          if (hasGestionTab)
            _NavItem(CupertinoIcons.chart_bar_square, CupertinoIcons.chart_bar_square_fill, 'Gestion'),
          if (isPendingCommissionnaire)
            _NavItem(CupertinoIcons.clock, CupertinoIcons.clock_fill, 'Statut'),
          _NavItem(CupertinoIcons.person, CupertinoIcons.person_fill, 'Profil'),
        ];

        // Clamp l'index si le nombre d'onglets change
        final clampedIndex = _currentIndex.clamp(0, screens.length - 1);
        if (clampedIndex != _currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _currentIndex = clampedIndex);
          });
        }

        return Scaffold(
          body: IndexedStack(
            index: clampedIndex,
            children: screens,
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: navItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = clampedIndex == index;

                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() => _currentIndex = index);
                            // Charger les favoris quand on clique sur l'onglet
                            final favIndex = hasGestionTab ? 2 : 2;
                            if (index == favIndex) {
                              context.read<FavoriteProvider>().loadFavorites();
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Badge spécial pour l'onglet Gestion
                                item.label == 'Gestion'
                                    ? _buildGestionIcon(isSelected)
                                    : item.label == 'Statut'
                                        ? _buildStatutIcon(isSelected)
                                        : Icon(
                                        isSelected ? item.activeIcon : item.icon,
                                        size: 22,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textTertiary,
                                      ),
                                const SizedBox(height: 2),
                                Text(
                                  item.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textTertiary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        fontSize: 10,
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

  Widget _buildGestionIcon(bool isSelected) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isSelected
              ? CupertinoIcons.chart_bar_square_fill
              : CupertinoIcons.chart_bar_square,
          size: 22,
          color: isSelected ? AppColors.primary : AppColors.textTertiary,
        ),
        Positioned(
          top: -3,
          right: -4,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatutIcon(bool isSelected) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isSelected ? CupertinoIcons.clock_fill : CupertinoIcons.clock,
          size: 22,
          color: isSelected ? Colors.amber.shade700 : AppColors.textTertiary,
        ),
        Positioned(
          top: -3,
          right: -4,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.amber.shade600,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem(this.icon, this.activeIcon, this.label);
}
