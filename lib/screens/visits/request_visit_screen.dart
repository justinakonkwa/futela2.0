import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visit_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RequestVisitScreen extends StatefulWidget {
  final String propertyId;

  const RequestVisitScreen({
    super.key,
    required this.propertyId,
  });

  @override
  State<RequestVisitScreen> createState() => _RequestVisitScreenState();
}

class _RequestVisitScreenState extends State<RequestVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _contactController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedStatus = 'pending';

  @override
  void dispose() {
    _messageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demander une visite'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations de la visite',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date de la visite
                      _buildDateSelector(),
                      const SizedBox(height: 16),
                      
                      // Heure de la visite
                      _buildTimeSelector(),
                      const SizedBox(height: 16),
                      
                      // Statut de la visite
                      _buildStatusSelector(),
                      const SizedBox(height: 16),
                      
                      // Message optionnel
                      CustomTextField(
                        controller: _messageController,
                        label: 'Message (optionnel)',
                        hint: 'Ajoutez un message pour le propriétaire...',
                        maxLines: 3,
                        validator: null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Contact
                      CustomTextField(
                        controller: _contactController,
                        label: 'Contact',
                        hint: 'Votre numéro de téléphone ou email',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre contact';
                          }
                          // Validation basique du format de contact
                          final cleanValue = value.trim();
                          if (cleanValue.length < 8) {
                            return 'Le contact doit contenir au moins 8 caractères';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Bouton de soumission
              Consumer<VisitProvider>(
                builder: (context, visitProvider, child) {
                  return CustomButton(
                    text: 'Demander la visite',
                    onPressed: visitProvider.isLoading ? null : _submitVisitRequest,
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    isLoading: visitProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de la visite',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heure de la visite',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut de la visite',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(
              value: 'pending',
              child: Text('En attente'),
            ),
            DropdownMenuItem(
              value: 'confirmed',
              child: Text('Confirmée'),
            ),
            DropdownMenuItem(
              value: 'cancelled',
              child: Text('Annulée'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedStatus = value;
              });
            }
          },
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _cleanMessage(String message) {
    // Nettoyer le message en gardant seulement les caractères alphanumériques, espaces et ponctuation de base
    return message.replaceAll(RegExp(r'[^\w\s.,!?-]'), '').trim();
  }

  Future<void> _submitVisitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final visitProvider = context.read<VisitProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour demander une visite'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Combiner la date et l'heure
      final visitDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Nettoyer et valider les données avant envoi
      final message = _messageController.text.trim();
      final contact = _contactController.text.trim();
      
      // Nettoyer le message - enlever les caractères spéciaux qui pourraient poser problème
      final cleanMessage = message.isEmpty ? null : _cleanMessage(message);
      
      await visitProvider.createVisit(
        visitor: authProvider.user!.id,
        property: widget.propertyId,
        dates: visitDateTime,
        status: _selectedStatus,
        message: cleanMessage,
        contact: contact,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande de visite envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
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
  }
}
