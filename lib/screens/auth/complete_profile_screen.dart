import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/futela_logo.dart';
import '../main_navigation.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String role;

  const CompleteProfileScreen({
    super.key,
    required this.role,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Champs commissionnaire
  final _idDocumentNumberController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _taxIdController = TextEditingController();
  
  String? _idDocumentType;
  File? _idDocumentFile;
  File? _selfieFile;
  
  bool _isLoading = false;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  bool get _isCommissionnaire => widget.role == 'ROLE_COMMISSIONNAIRE';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _idDocumentNumberController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  Future<void> _pickIdDocument() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _idDocumentFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickSelfie() async {
    try {
      // Afficher un dialog pour choisir la source
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Selfie de vérification'),
          content: const Text('Choisissez la source de votre photo'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              icon: const Icon(CupertinoIcons.camera),
              label: const Text('Caméra'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              icon: const Icon(CupertinoIcons.photo),
              label: const Text('Galerie'),
            ),
          ],
        ),
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      
      if (image != null) {
        setState(() {
          _selfieFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la capture: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation des documents pour commissionnaire
    if (_isCommissionnaire) {
      if (_idDocumentType == null) {
        setState(() {
          _error = 'Veuillez sélectionner un type de document';
        });
        return;
      }
      
      if (_idDocumentFile == null) {
        setState(() {
          _error = 'Veuillez ajouter une photo de votre pièce d\'identité';
        });
        return;
      }
      
      if (_selfieFile == null) {
        setState(() {
          _error = 'Veuillez prendre un selfie de vérification';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.completeProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: '+243${_phoneController.text.trim()}',
        role: widget.role,
        idDocumentType: _idDocumentType,
        idDocumentNumber: _idDocumentNumberController.text.trim().isEmpty
            ? null
            : _idDocumentNumberController.text.trim(),
        businessName: _businessNameController.text.trim().isEmpty
            ? null
            : _businessNameController.text.trim(),
        businessAddress: _businessAddressController.text.trim().isEmpty
            ? null
            : _businessAddressController.text.trim(),
        taxId: _taxIdController.text.trim().isEmpty
            ? null
            : _taxIdController.text.trim(),
        idDocumentFile: _idDocumentFile,
        selfieFile: _selfieFile,
      );

      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      } else if (mounted) {
        setState(() {
          _error = authProvider.error ?? 'Erreur lors de la complétion du profil';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
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
                child: Form(
                  key: _formKey,
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
                                size: 64,
                                backgroundColor: AppColors.white,
                                borderRadius: BorderRadius.all(Radius.circular(18)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Complétez votre profil',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.color,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getRoleLabel(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.exclamationmark_circle_fill,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.error,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Informations de base
                      Text(
                        'Informations personnelles',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      
                      CustomTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        hint: 'Jean',
                        prefixIconData: CupertinoIcons.person_fill,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre prénom';
                          }
                          if (value.length < 2 || value.length > 100) {
                            return 'Le prénom doit contenir entre 2 et 100 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      CustomTextField(
                        controller: _lastNameController,
                        label: 'Nom',
                        hint: 'Mukendi',
                        prefixIconData: CupertinoIcons.person_fill,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          if (value.length < 2 || value.length > 100) {
                            return 'Le nom doit contenir entre 2 et 100 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Téléphone
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Téléphone',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: '812345678',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 16, right: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.phone_fill,
                                      size: 22,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '+243',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      width: 1,
                                      height: 24,
                                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                    ),
                                  ],
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 44),
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                                  : AppColors.grey50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                                      : AppColors.grey200,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.error, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.error, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre numéro';
                              }
                              if (value.startsWith('0')) {
                                if (value.length != 10) {
                                  return 'Le numéro doit contenir 10 chiffres (avec 0)';
                                }
                              } else {
                                if (value.length != 9) {
                                  return 'Le numéro doit contenir 9 chiffres (sans 0)';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),

                      // Champs spécifiques commissionnaire
                      if (_isCommissionnaire) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Informations professionnelles',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Type de document
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Type de pièce d\'identité *',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _idDocumentType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                                    : AppColors.grey50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                                        : AppColors.grey200,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'national_id', child: Text('Carte d\'identité nationale')),
                                DropdownMenuItem(value: 'passport', child: Text('Passeport')),
                                DropdownMenuItem(value: 'driver_license', child: Text('Permis de conduire')),
                                DropdownMenuItem(value: 'voter_card', child: Text('Carte d\'électeur')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _idDocumentType = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        CustomTextField(
                          controller: _idDocumentNumberController,
                          label: 'Numéro du document',
                          hint: 'CD1234567',
                          prefixIconData: CupertinoIcons.doc_text_fill,
                        ),
                        const SizedBox(height: 12),
                        
                        CustomTextField(
                          controller: _businessNameController,
                          label: 'Nom commercial',
                          hint: 'Futela Immo SARL',
                          prefixIconData: CupertinoIcons.building_2_fill,
                        ),
                        const SizedBox(height: 12),
                        
                        CustomTextField(
                          controller: _businessAddressController,
                          label: 'Adresse professionnelle',
                          hint: 'Av. Kasa-Vubu 123, Kinshasa',
                          prefixIconData: CupertinoIcons.location_solid,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        
                        CustomTextField(
                          controller: _taxIdController,
                          label: 'Numéro fiscal / RCCM',
                          hint: 'CD/KIN/RCCM/24-A-12345',
                          prefixIconData: CupertinoIcons.number,
                        ),
                        
                        const SizedBox(height: 24),
                        Text(
                          'Documents de vérification',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Upload pièce d'identité
                        _DocumentUploadCard(
                          title: 'Pièce d\'identité *',
                          description: 'Photo de votre document d\'identité',
                          icon: CupertinoIcons.doc_text_fill,
                          file: _idDocumentFile,
                          onTap: _pickIdDocument,
                        ),
                        const SizedBox(height: 12),
                        
                        // Upload selfie
                        _DocumentUploadCard(
                          title: 'Selfie de vérification *',
                          description: 'Photo de vous (caméra ou galerie)',
                          icon: CupertinoIcons.camera_fill,
                          file: _selfieFile,
                          onTap: _pickSelfie,
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                    ],
                  ),
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
                text: _isCommissionnaire ? 'Soumettre pour validation' : 'Terminer',
                onPressed: _isLoading ? null : _handleSubmit,
                isLoading: _isLoading,
                height: 52,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel() {
    switch (widget.role) {
      case 'ROLE_USER':
        return 'Visiteur';
      case 'ROLE_COMMISSIONNAIRE':
        return 'Commissionnaire';
      default:
        return '';
    }
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final File? file;
  final VoidCallback onTap;

  const _DocumentUploadCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.primary.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? AppColors.primary
                : Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                    : AppColors.grey200,
            width: hasFile ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasFile
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasFile ? CupertinoIcons.check_mark : icon,
                color: hasFile ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasFile
                              ? AppColors.primary
                              : Theme.of(context).textTheme.displayLarge?.color,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile ? 'Document ajouté' : description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Theme.of(context).textTheme.bodySmall?.color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
