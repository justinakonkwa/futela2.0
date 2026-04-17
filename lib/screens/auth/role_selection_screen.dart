import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/futela_logo.dart';
import '../../widgets/custom_button.dart';
import 'complete_profile_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  final List<RoleOption> _roles = [
    RoleOption(
      role: 'ROLE_USER',
      title: 'Visiteur',
      description: 'Je cherche un bien immobilier à louer ou acheter',
      icon: CupertinoIcons.search,
      color: AppColors.primary,
    ),
    RoleOption(
      role: 'ROLE_COMMISSIONNAIRE',
      title: 'Commissionnaire',
      description: 'Je suis un professionnel de l\'immobilier',
      icon: CupertinoIcons.briefcase_fill,
      color: Colors.purple,
    ),
  ];

  void _continue() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un rôle'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompleteProfileScreen(role: _selectedRole!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.back,
              color: Theme.of(context).textTheme.displayLarge?.color,
              size: 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const FutelaLogo(
                              size: 72,
                              backgroundColor: AppColors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Choisissez votre rôle',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.color,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sélectionnez le rôle qui correspond à votre profil',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ..._roles.map((roleOption) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RoleCard(
                            roleOption: roleOption,
                            isSelected: _selectedRole == roleOption.role,
                            onTap: () {
                              setState(() {
                                _selectedRole = roleOption.role;
                              });
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Continuer',
                onPressed: _selectedRole != null ? _continue : null,
                height: 52,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleOption {
  final String role;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  RoleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _RoleCard extends StatelessWidget {
  final RoleOption roleOption;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.roleOption,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? roleOption.color.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? roleOption.color
                : Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                    : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: roleOption.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: roleOption.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                roleOption.icon,
                color: roleOption.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleOption.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? roleOption.color
                              : Theme.of(context).textTheme.displayLarge?.color,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roleOption.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: roleOption.color,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
