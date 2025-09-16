import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import '../property/add_property_screen.dart';
import '../../providers/property_provider.dart';
import '../../widgets/property_card.dart';
import '../visits/my_visits_screen.dart';
import '../fees/fees_screen.dart';
import '../favorites/favorites_screen.dart';
import '../property/property_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.white,
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
                // Profil header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Photo de profil
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: user.profilePictureFilePath != null
                            ? NetworkImage(user.profilePictureFilePath!)
                            : null,
                        child: user.profilePictureFilePath == null
                            ? Text(
                                user.firstName.isNotEmpty
                                    ? user.firstName[0].toUpperCase()
                                    : 'U',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Nom complet
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Email
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Téléphone
                      Text(
                        user.phone,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Badge de vérification
                      if (user.isIdVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.success),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Profil vérifié',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
                        // TODO: Implémenter le changement de mot de passe
                      },
                    ),
                    _MenuItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Vérification d\'identité',
                      onTap: () {
                        // TODO: Implémenter la vérification d'identité
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildMenuSection(
                  context,
                  title: 'Mes propriétés',
                  items: [
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
                
                _buildMenuSection(
                  context,
                  title: 'Visites et Paiements',
                  items: [
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
                    _MenuItem(
                      icon: Icons.payment_outlined,
                      title: 'Historique des paiements',
                      onTap: () {
                        // TODO: Créer l'écran d'historique des paiements
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité à venir'),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Demander un retrait',
                      onTap: () {
                        _showWithdrawalDialog(context);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildMenuSection(
                  context,
                  title: 'Informations',
                  items: [
                    _MenuItem(
                      icon: Icons.receipt_outlined,
                      title: 'Frais et commissions',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FeesScreen(),
                          ),
                        );
                      },
                    ),
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
                        // TODO: Implémenter le centre d'aide
                      },
                    ),
                    _MenuItem(
                      icon: Icons.contact_support_outlined,
                      title: 'Nous contacter',
                      onTap: () {
                        // TODO: Implémenter le contact
                      },
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      title: 'À propos',
                      onTap: () {
                        // TODO: Implémenter la page à propos
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: AppColors.textPrimary,
      ),
      title: Text(
        item.title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textTertiary,
      ),
      onTap: item.onTap,
    );
  }

  void _showWithdrawalDialog(BuildContext context) {
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = '1';
    String selectedCurrency = 'USD';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  selectedType = value;
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
                      selectedCurrency = value;
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

                    // TODO: Implémenter la demande de retrait
                    // await visitProvider.requestWithdrawal(...)
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demande de retrait envoyée'),
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
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
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
      if (!provider.isLoading && provider.nextCursor != null) {
        provider.loadMyProperties();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes annonces'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
              );
            },
          )
        ],
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myProperties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.myProperties.isEmpty) {
            return Center(
              child: Text(provider.error!),
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
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
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
  }
}
