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
import '../../widgets/social_login_buttons.dart';
import '../main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Champs commissionnaire
  final _idDocumentNumberController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _taxIdController = TextEditingController();
  
  String _selectedRole = 'ROLE_USER'; // Par défaut visiteur
  String? _idDocumentType;
  File? _idDocumentFile;
  File? _selfieFile;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showConfirmPassword = false;
  
  final ImagePicker _picker = ImagePicker();

  bool get _isCommissionnaire => _selectedRole == 'ROLE_COMMISSIONNAIRE';

  @override
  void initState() {
    super.initState();
    // Écouter les changements du mot de passe pour afficher le champ de confirmation
    _passwordController.addListener(() {
      setState(() {
        _showConfirmPassword = _passwordController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation des documents pour commissionnaire
    if (_isCommissionnaire) {
      if (_idDocumentType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un type de document'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      if (_idDocumentFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez ajouter une photo de votre pièce d\'identité'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      if (_selfieFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez prendre un selfie de vérification'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Si commissionnaire, utiliser registerCommissionnaire
    if (_isCommissionnaire) {
      final success = await authProvider.registerCommissionnaire(
        phone: '+243${_phoneController.text.trim()}',
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        idDocumentType: _idDocumentType!,
        idDocumentNumber: _idDocumentNumberController.text.trim(),
        businessName: _businessNameController.text.trim().isEmpty
            ? null
            : _businessNameController.text.trim(),
        businessAddress: _businessAddressController.text.trim().isEmpty
            ? null
            : _businessAddressController.text.trim(),
        taxId: _taxIdController.text.trim().isEmpty
            ? null
            : _taxIdController.text.trim(),
        idDocumentFile: _idDocumentFile!,
        selfieFile: _selfieFile!,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Erreur d\'inscription'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      // Inscription classique pour visiteur/propriétaire
      final success = await authProvider.signUp(
        phone: '+243${_phoneController.text.trim()}',
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty
            ? null
            : _middleNameController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Erreur d\'inscription'),
            backgroundColor: AppColors.error,
          ),
        );
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                          size: 72,
                          backgroundColor: AppColors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Créer un compte',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.displayLarge?.color,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rejoignez Futela',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sélection de rôle
                Text(
                  'Je suis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'ROLE_USER',
                      label: Text('Visiteur'),
                      icon: Icon(CupertinoIcons.person, size: 18),
                    ),
                    ButtonSegment(
                      value: 'ROLE_COMMISSIONNAIRE',
                      label: Text('Commissionnaire'),
                      icon: Icon(CupertinoIcons.briefcase, size: 18),
                    ),
                  ],
                  selected: {_selectedRole},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedRole = newSelection.first;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary;
                      }
                      return null;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Theme.of(context).textTheme.bodyMedium?.color;
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _firstNameController,
                  label: 'Prénom',
                  hint: 'Prénom',
                  prefixIconData: CupertinoIcons.person_fill,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _lastNameController,
                  label: 'Nom',
                  hint: 'Nom',
                  prefixIconData: CupertinoIcons.person_fill,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIconData: CupertinoIcons.mail_solid,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // Champ téléphone avec préfixe +243
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Téléphone',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
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
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
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
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
                                ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
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
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onChanged: (value) {
                        // Limiter la longueur selon si commence par 0 ou non
                        if (value.isNotEmpty) {
                          if (value.startsWith('0')) {
                            // Si commence par 0, max 10 caractères
                            if (value.length > 10) {
                              _phoneController.text = value.substring(0, 10);
                              _phoneController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _phoneController.text.length),
                              );
                            }
                          } else {
                            // Si ne commence pas par 0, max 9 caractères
                            if (value.length > 9) {
                              _phoneController.text = value.substring(0, 9);
                              _phoneController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _phoneController.text.length),
                              );
                            }
                          }
                        }
                      },
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
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIconData: CupertinoIcons.lock_fill,
                  suffixIcon: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? CupertinoIcons.eye_slash_fill
                          : CupertinoIcons.eye_fill,
                      size: 22,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Veuillez entrer votre mot de passe';
                    if (value.length < 4) return 'Au moins 4 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // Champ confirmation mot de passe (affiché seulement si mot de passe saisi)
                if (_showConfirmPassword) ...[
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    hint: '••••••••',
                    obscureText: _obscureConfirmPassword,
                    prefixIconData: CupertinoIcons.lock_fill,
                    suffixIcon: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                      child: Icon(
                        _obscureConfirmPassword
                            ? CupertinoIcons.eye_slash_fill
                            : CupertinoIcons.eye_fill,
                        size: 22,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Champs spécifiques commissionnaire
                if (_isCommissionnaire) ...[
                  const SizedBox(height: 16),
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
                    label: 'Numéro du document *',
                    hint: 'CD1234567',
                    prefixIconData: CupertinoIcons.doc_text_fill,
                    validator: (value) {
                      if (_isCommissionnaire && (value == null || value.isEmpty)) {
                        return 'Veuillez entrer le numéro du document';
                      }
                      return null;
                    },
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
                  
                  const SizedBox(height: 16),
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
                
                const SizedBox(height: 16),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Créer mon compte',
                      onPressed:
                          authProvider.isLoading ? null : _handleRegister,
                      isLoading: authProvider.isLoading,
                      height: 52,
                      fullWidth: true,
                    );
                  },
                ),

                const SizedBox(height: 20),
                // Boutons de connexion sociale
                const SocialLoginButtons(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Se connecter',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'En créant un compte, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
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
