import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Centre d\'aide'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section FAQ
            _buildSection(
              context,
              title: 'Questions fréquentes',
              icon: Icons.help_outline,
              children: [
                _buildFAQItem(
                  context,
                  question: 'Comment publier une annonce ?',
                  answer: 'Pour publier une annonce, connectez-vous à votre compte, puis cliquez sur le bouton "+" dans l\'onglet "Mes annonces". Remplissez tous les champs requis et ajoutez des photos de votre propriété.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Comment demander une visite ?',
                  answer: 'Sur la page de détail d\'une propriété, cliquez sur "Demander une visite", sélectionnez vos dates et heures préférées, puis envoyez votre demande.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Comment contacter un propriétaire ?',
                  answer: 'Vous pouvez contacter un propriétaire en demandant une visite ou en utilisant les informations de contact fournies dans l\'annonce.',
                ),
                _buildFAQItem(
                  context,
                  question: 'Comment modifier mon profil ?',
                  answer: 'Allez dans l\'onglet "Profil", puis cliquez sur "Modifier le profil" pour mettre à jour vos informations personnelles.',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Guides
            _buildSection(
              context,
              title: 'Guides d\'utilisation',
              icon: Icons.book_outlined,
              children: [
                _buildGuideItem(
                  context,
                  title: 'Guide de publication d\'annonce',
                  description: 'Apprenez à créer une annonce attractive',
                  onTap: () => _showGuide(context, 'Guide de publication'),
                ),
                _buildGuideItem(
                  context,
                  title: 'Guide de recherche de propriété',
                  description: 'Optimisez vos recherches de logement',
                  onTap: () => _showGuide(context, 'Guide de recherche'),
                ),
                _buildGuideItem(
                  context,
                  title: 'Guide de sécurité',
                  description: 'Conseils pour des transactions sécurisées',
                  onTap: () => _showGuide(context, 'Guide de sécurité'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Contact
            _buildSection(
              context,
              title: 'Besoin d\'aide ?',
              icon: Icons.support_agent,
              children: [
                _buildContactItem(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'support@futela.com',
                  onTap: () => _launchEmail('support@futela.com'),
                ),
                _buildContactItem(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Téléphone',
                  subtitle: '+243 XXX XXX XXX',
                  onTap: () => _launchPhone('+243XXXXXXXXX'),
                ),
                _buildContactItem(
                  context,
                  icon: Icons.chat_outlined,
                  title: 'Chat en direct',
                  subtitle: 'Disponible 24h/7j',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Informations légales
            _buildSection(
              context,
              title: 'Informations légales',
              icon: Icons.gavel_outlined,
              children: [
                _buildLegalItem(
                  context,
                  title: 'Conditions d\'utilisation',
                  onTap: () => _showComingSoon(context),
                ),
                _buildLegalItem(
                  context,
                  title: 'Politique de confidentialité',
                  onTap: () => _showComingSoon(context),
                ),
                _buildLegalItem(
                  context,
                  title: 'Mentions légales',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.article_outlined,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textTertiary,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textTertiary,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLegalItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.description_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textTertiary,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showGuide(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Ce guide sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cette fonctionnalité sera bientôt disponible'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Futela',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
