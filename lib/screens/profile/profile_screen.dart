import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/role_permissions.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../property/add_property_screen.dart';
import '../../providers/property_provider.dart';
import '../../providers/visit_provider.dart';
import '../../widgets/property_card.dart';
import '../../widgets/property_card_shimmer.dart';
import '../visits/my_visits_screen.dart';
import '../visits/payment_history_screen.dart';
// import '../fees/fees_screen.dart';
import '../favorites/favorites_screen.dart';
import '../property/property_detail_screen.dart';
import '../support/help_center_screen.dart';
import '../support/contact_us_screen.dart';
import '../support/about_screen.dart';
// import '../messaging/conversations_list_screen.dart';
// import '../../providers/messaging_provider.dart';
import '../../widgets/futela_logo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Implémenter les paramètres
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = authProvider.user!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profil header — carte compacte
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar compact
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.primary.withOpacity(0.12),
                              backgroundImage: user.profilePictureFilePath != null
                                  ? NetworkImage(user.profilePictureFilePath!)
                                  : null,
                              child: user.profilePictureFilePath == null
                                  ? Text(
                                      user.firstName.isNotEmpty
                                          ? user.firstName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontFamily: 'Gilroy',
                                        fontSize: 22,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        user.email,
                                        style: const TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (user.phone.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          user.phone,
                                          style: const TextStyle(
                                            fontFamily: 'Gilroy',
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.person_outline, size: 18),
                              label: const Text('Voir profil'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary.withOpacity(0.6)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(int.parse(RolePermissions.getRoleColor(user.role).replaceFirst('#', '0xFF'))).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(int.parse(RolePermissions.getRoleColor(user.role).replaceFirst('#', '0xFF'))).withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Color(int.parse(RolePermissions.getRoleColor(user.role).replaceFirst('#', '0xFF'))),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  RolePermissions.getRoleDisplayName(user.role),
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    color: Color(int.parse(RolePermissions.getRoleColor(user.role).replaceFirst('#', '0xFF'))),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Logo Futela
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Logo
                      const FutelaLogo(size: 50),
                      const SizedBox(width: 16),
                      
                      // Informations
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Futela',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Version 1.0.0',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Indicateur
                      Icon(
                        Icons.verified,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Menu options
                _buildMenuSection(
                  context,
                  title: 'Mon compte',
                  items: [
                    _MenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Modifier le profil',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline,
                      title: 'Changer le mot de passe',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    // _MenuItem(
                    //   icon: Icons.verified_user_outlined,
                    //   title: 'Vérification d\'identité',
                    //   onTap: () {
                    //     // TODO: Implémenter la vérification d'identité
                    //   },
                    // ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildMenuSection(
                  context,
                  title: 'Mes propriétés',
                  items: [
                    if (RolePermissions.canAddProperties(user))
                      _MenuItem(
                        icon: Icons.home_work_outlined,
                        title: 'Mes annonces',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const _MyPropertiesScreen(),
                            ),
                          );
                        },
                      ),
                    if (RolePermissions.canManageFavorites(user))
                      _MenuItem(
                        icon: Icons.favorite_outline,
                        title: 'Mes favoris',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const FavoritesScreen(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Consumer<MessagingProvider>(
                //   builder: (context, messagingProvider, _) {
                //     return _buildMenuSection(
                //       context,
                //       title: 'Communication',
                //       items: [
                //         _MenuItem(
                //           icon: Icons.chat_bubble_outline,
                //           title: 'Messagerie',
                //           badgeCount: messagingProvider.unreadMessagesCount > 0
                //               ? messagingProvider.unreadMessagesCount
                //               : null,
                //           onTap: () {
                //             messagingProvider.loadUnreadMessagesCount();
                //             Navigator.of(context).push(
                //               MaterialPageRoute(
                //                 builder: (context) => const ConversationsListScreen(),
                //               ),
                //             );
                //           },
                //         ),
                //       ],
                //     );
                //   },
                // ),
                
                const SizedBox(height: 16),
                
                _buildMenuSection(
                  context,
                  title: 'Visites et Paiements',
                  items: [
                    if (RolePermissions.canViewOwnVisits(user))
                      _MenuItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'Mes visites',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MyVisitsScreen(),
                            ),
                          );
                        },
                      ),
                    if (RolePermissions.canViewPaymentHistory(user))
                      _MenuItem(
                        icon: Icons.payment_outlined,
                        title: 'Historique des paiements',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PaymentHistoryScreen(),
                            ),
                          );
                        },
                      ),
                    // if (RolePermissions.canRequestWithdrawal(user))
                    //   _MenuItem(
                    //     icon: Icons.account_balance_wallet_outlined,
                    //     title: 'Demander un retrait',
                    //     onTap: () {
                    //       _showWithdrawalDialog(context);
                    //     },
                    //   ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildMenuSection(
                  context,
                  title: 'Apparence',
                  items: [
                    _MenuItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Thème (clair / sombre / système)',
                      onTap: () => _showThemeSheet(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildMenuSection(
                  context,
                  title: 'Informations',
                  items: [
                    // _MenuItem(
                    //   icon: Icons.receipt_outlined,
                    //   title: 'Frais et commissions',
                    //   onTap: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (context) => const FeesScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Comment demander une visite',
                      onTap: () {
                        _showVisitGuide(context);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildMenuSection(
                  context,
                  title: 'Support',
                  items: [
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Centre d\'aide',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HelpCenterScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.contact_support_outlined,
                      title: 'Nous contacter',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ContactUsScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      title: 'À propos',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Bouton de déconnexion
                CustomButton(
                  text: 'Se déconnecter',
                  isOutlined: true,
                  fullWidth: true,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Déconnexion'),
                        content: const Text(
                          'Êtes-vous sûr de vouloir vous déconnecter ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              authProvider.logout();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text('Déconnexion'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSectionIcon(title),
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...items.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Mon compte':
        return Icons.person_outline;
      case 'Mes propriétés':
        return Icons.home_work_outlined;
      case 'Visites et Paiements':
        return Icons.payment_outlined;
      case 'Apparence':
        return Icons.palette_outlined;
      case 'Informations':
        return Icons.info_outline;
      case 'Support':
        return Icons.support_agent_outlined;
      default:
        return Icons.menu_outlined;
    }
  }

  void _showThemeSheet(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choisir le thème',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _themeOption(context, themeProvider, ThemeMode.light, Icons.light_mode, 'Clair'),
              _themeOption(context, themeProvider, ThemeMode.dark, Icons.dark_mode, 'Sombre'),
              _themeOption(context, themeProvider, ThemeMode.system, Icons.brightness_auto, 'Système'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeOption(BuildContext context, ThemeProvider themeProvider, ThemeMode mode, IconData icon, String label) {
    final isSelected = themeProvider.themeMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Theme.of(context).iconTheme.color),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
      onTap: () async {
        await themeProvider.setThemeMode(mode);
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.badgeCount != null && item.badgeCount! > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        onTap: item.onTap,
      ),
    );
  }

  // ignore: unused_element
  void _showWithdrawalDialog(BuildContext context) {
    final phoneController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          String selectedType = '1';
          String selectedCurrency = 'USD';
          
          return AlertDialog(
        title: const Text('Demande de retrait'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Type de retrait',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Mobile Money')),
                DropdownMenuItem(value: '2', child: Text('Virement bancaire')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(),
                prefixText: '+243 ',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Montant',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'CDF', child: Text('CDF')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCurrency = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (phoneController.text.isEmpty || amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez remplir tous les champs'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Montant invalide'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Formater le numéro de téléphone au format 243XXXXXXXXX (sans le signe +)
                    String phoneNumber = phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
                    // Supprimer le préfixe 243 s'il existe déjà pour éviter la duplication
                    if (phoneNumber.startsWith('243')) {
                      phoneNumber = phoneNumber.substring(3);
                    }
                    // Ajouter le préfixe 243
                    phoneNumber = '243$phoneNumber';

                    final visitProvider = Provider.of<VisitProvider>(context, listen: false);
                    await visitProvider.requestWithdrawal(
                      currency: selectedCurrency,
                      amount: amount,
                      phone: phoneNumber,
                      type: selectedType,
                    );
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demande de retrait envoyée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Demander'),
              );
            },
          ),
        ],
      
          );
        },
      ),
    );
  }

  void _showVisitGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comment demander une visite'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideStep(
                context,
                '1',
                'Trouvez une propriété',
                'Parcourez les annonces et trouvez une propriété qui vous intéresse.',
              ),
              _buildGuideStep(
                context,
                '2',
                'Cliquez sur "Demander une visite"',
                'Sur la page de détail de la propriété, cliquez sur le bouton pour demander une visite.',
              ),
              _buildGuideStep(
                context,
                '3',
                'Remplissez le formulaire',
                'Choisissez la date et l\'heure de votre visite, ajoutez un message optionnel et vos coordonnées.',
              ),
              _buildGuideStep(
                context,
                '4',
                'Confirmez votre demande',
                'Vérifiez les informations et confirmez votre demande de visite.',
              ),
              _buildGuideStep(
                context,
                '5',
                'Suivez vos visites',
                'Consultez "Mes visites" dans votre profil pour voir le statut de vos demandes.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Les visites peuvent nécessiter un paiement selon le type de propriété.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(
    BuildContext context,
    String number,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final int? badgeCount;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.badgeCount, // gardé pour réactiver Messagerie
    required this.onTap,
  });
}

class _MyPropertiesScreen extends StatefulWidget {
  const _MyPropertiesScreen();

  @override
  State<_MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<_MyPropertiesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PropertyProvider>(context, listen: false);
      provider.loadMyProperties(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = Provider.of<PropertyProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Protection contre les appels multiples
      if (!provider.isLoading && 
          provider.nextCursor != null && 
          provider.nextCursor!.isNotEmpty) {
        print('🔄 Loading more properties with cursor: ${provider.nextCursor}');
        provider.loadMyProperties();
      } else if (provider.nextCursor == null || provider.nextCursor!.isEmpty) {
        print('✅ No more properties to load (nextCursor is null or empty)');
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null || !RolePermissions.canAddProperties(authProvider.user!)) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('Mes annonces'),
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
              elevation: 0,
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Vous n\'avez pas accès à cette section.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Mes annonces'),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
                  );
                },
              ),
            ],
          ),
          body: Consumer<PropertyProvider>(
            builder: (context, provider, child) {
          // Debug: Print current state
          print('🔍 MyPropertiesScreen State: isLoading=${provider.isLoading}, error=${provider.error}, propertiesCount=${provider.myProperties.length}');
          
          if (provider.isLoading && provider.myProperties.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: PropertyCardShimmer(),
                );
              },
            );
          }

          if (provider.error != null && provider.myProperties.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Réessayer',
                      onPressed: () {
                        provider.clearError();
                        provider.loadMyProperties(refresh: true);
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.myProperties.isEmpty) {
            return Center(
              child: Text(
                'Aucune annonce',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.myProperties.length + (provider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.myProperties.length) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: PropertyCardShimmer(),
                );
              }
              final property = provider.myProperties[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PropertyCard(
                  property: property,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PropertyDetailScreen(
                          propertyId: property.id,
                          myProperty: true,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
      },
    );
  }
}
