import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/property_service.dart';
import '../../utils/app_colors.dart';

class DelegatePropertyScreen extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const DelegatePropertyScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<DelegatePropertyScreen> createState() => _DelegatePropertyScreenState();
}

class _DelegatePropertyScreenState extends State<DelegatePropertyScreen> {
  final _service = PropertyService();
  final _commissionnaireIdController = TextEditingController();
  double _commissionRate = 10;
  bool _isLoading = false;
  bool _isLoadingCommissionnaires = false;
  String? _error;
  List<Map<String, dynamic>> _commissionnaires = [];
  Map<String, dynamic>? _selectedCommissionnaire;

  @override
  void initState() {
    super.initState();
    _loadCommissionnaires();
  }

  @override
  void dispose() {
    _commissionnaireIdController.dispose();
    super.dispose();
  }

  Future<void> _loadCommissionnaires() async {
    setState(() => _isLoadingCommissionnaires = true);
    try {
      final list = await _service.getCommissionnaires();
      setState(() => _commissionnaires = list);
    } catch (_) {
      // Si l'endpoint n'existe pas, on passe en mode saisie manuelle
      setState(() => _commissionnaires = []);
    } finally {
      setState(() => _isLoadingCommissionnaires = false);
    }
  }

  Future<void> _delegate() async {
    final commissionnaireId = _selectedCommissionnaire?['id']?.toString() ??
        _commissionnaireIdController.text.trim();

    if (commissionnaireId.isEmpty) {
      setState(() => _error = 'Veuillez sélectionner ou saisir un commissionnaire');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _service.delegateProperty(
        widget.propertyId,
        commissionnaireId: commissionnaireId,
        commissionRate: _commissionRate,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // true = succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Propriété déléguée avec succès !',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Déléguer la propriété',
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info propriété
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(CupertinoIcons.building_2_fill,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Propriété à déléguer',
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.propertyTitle,
                            style: const TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Sélection commissionnaire
              const Text(
                'Commissionnaire',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (_isLoadingCommissionnaires)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (_commissionnaires.isNotEmpty)
                _buildCommissionnaireList()
              else
                _buildManualInput(),

              const SizedBox(height: 28),

              // Taux de commission
              const Text(
                'Taux de commission',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pourcentage du montant de la visite reversé au commissionnaire.',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Taux',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_commissionRate.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.border,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withValues(alpha: 0.1),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _commissionRate,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        onChanged: (v) => setState(() => _commissionRate = v),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1%',
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                            )),
                        Text('30%',
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Exemple de calcul
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.info_circle,
                              color: AppColors.info, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pour une visite de 10\$ → commissionnaire reçoit ${(10 * _commissionRate / 100).toStringAsFixed(2)}\$',
                              style: const TextStyle(
                                fontFamily: 'Gilroy',
                                fontSize: 12,
                                color: AppColors.info,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Erreur
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_circle,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontFamily: 'Gilroy',
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Bouton déléguer
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _delegate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.person_badge_plus_fill,
                                    color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Déléguer la propriété',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionnaireList() {
    return Column(
      children: _commissionnaires.map((c) {
        final id = c['id']?.toString() ?? '';
        final name = '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}'.trim();
        final phone = c['phone']?.toString() ?? '';
        final isSelected = _selectedCommissionnaire?['id'] == id;

        return GestureDetector(
          onTap: () => setState(() => _selectedCommissionnaire = c),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border.withValues(alpha: 0.4),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.background,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'C',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Commissionnaire',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: const TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 22),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildManualInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _commissionnaireIdController,
        style: const TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: 'UUID du commissionnaire',
          hintText: 'ex: 019d6900-1111-7aef-bcf2-...',
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(CupertinoIcons.person_fill,
                size: 20, color: AppColors.primary),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            fontFamily: 'Gilroy',
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
