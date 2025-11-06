import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visit_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/property_card_shimmer.dart';
import '../../widgets/futela_logo.dart';

class MyVisitsScreen extends StatefulWidget {
  const MyVisitsScreen({super.key});

  @override
  State<MyVisitsScreen> createState() => _MyVisitsScreenState();
}

class _MyVisitsScreenState extends State<MyVisitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final visitProvider = context.read<VisitProvider>();
      visitProvider.loadMyVisits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Visites'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<VisitProvider>(
        builder: (context, visitProvider, child) {
          if (visitProvider.isLoading && visitProvider.visits.isEmpty) {
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

          if (visitProvider.error != null) {
            return Center(
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
                    'Erreur',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    visitProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Réessayer',
                    onPressed: () {
                      visitProvider.loadMyVisits();
                    },
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ),
                ],
              ),
            );
          }

          if (visitProvider.visits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Futela avec icône de calendrier
                    const FutelaLogoWithBadge(
                      size: 120,
                      badgeIcon: Icons.calendar_today,
                      badgeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Aucune visite',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vous n\'avez pas encore de visites programmées.\nTrouvez une propriété et demandez une visite !',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Explorer les propriétés',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => visitProvider.loadMyVisits(),
            child:             ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visitProvider.visits.length,
              itemBuilder: (context, index) {
                final visitId = visitProvider.visits[index];
                return _buildVisitCard(visitId.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisitCard(String visitId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:  const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visite #${visitId.substring(0, 8)}...',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $visitId',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'En attente',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Détails',
                    onPressed: () {
                      // TODO: Naviguer vers les détails de la visite
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à implémenter'),
                        ),
                      );
                    },
                    backgroundColor: Colors.grey[200]!,
                    textColor: Colors.grey[700]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Payer',
                    onPressed: () {
                      _showPaymentDialog(visitId);
                    },
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _showPaymentDialog(String visitId) {
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = '1';
    String selectedCurrency = 'USD';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paiement de la visite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Type de paiement',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Mobile Money')),
                DropdownMenuItem(value: '2', child: Text('Carte bancaire')),
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
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
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
          Consumer<VisitProvider>(
            builder: (context, visitProvider, child) {
              return ElevatedButton(
                onPressed: visitProvider.isLoading ? null : () async {
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
                    
                    print('📞 Phone number formatted: $phoneNumber');

                    final response = await visitProvider.payVisit(
                      visitId: visitId,
                      type: selectedType,
                      phone: phoneNumber,
                      amount: amount,
                      currency: selectedCurrency,
                    );

                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Paiement envoyé: ${response.message}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: visitProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Payer'),
              );
            },
          ),
        ],
      ),
    );
  }
}
