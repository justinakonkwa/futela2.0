import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/commission_provider.dart';
import '../../utils/app_colors.dart';

class CommissionsListScreen extends StatefulWidget {
  const CommissionsListScreen({super.key});

  @override
  State<CommissionsListScreen> createState() => _CommissionsListScreenState();
}

class _CommissionsListScreenState extends State<CommissionsListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommissionProvider>(context, listen: false)
          .loadCommissions(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<CommissionProvider>(context, listen: false)
          .loadCommissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mes Commissions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
        ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<CommissionProvider>(context, listen: false)
              .loadCommissions(refresh: true);
        },
        child: Consumer<CommissionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingCommissions && provider.commissions.isEmpty) {
              return _buildLoadingSkeleton();
            }

            if (provider.commissions.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: provider.commissions.length + 
                         (provider.hasMoreCommissions ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.commissions.length) {
                  return _buildLoadingIndicator();
                }
                
                final commission = provider.commissions[index];
                return _buildCommissionCard(commission);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCommissionCard(commission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(commission.verificationStatus).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(commission.verificationStatus),
                        color: _getStatusColor(commission.verificationStatus),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${commission.commissionAmount.toStringAsFixed(2)} ${commission.currency}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.displayLarge?.color,
                            ),
                          ),
                          Text(
                            commission.verificationStatusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(commission.verificationStatus),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(commission.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  if (commission.verifiedAt != null)
                    Text(
                      'Vérifiée le ${_formatDate(commission.verifiedAt!)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCommissionDetails(commission),
          if (commission.verificationStatus == 'code_sent' && commission.canVerify)
            _buildVerificationSection(commission),
        ],
      ),
    );
  }

  Widget _buildCommissionDetails(commission) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: CupertinoIcons.building_2_fill,
            label: 'Propriété',
            value: commission.propertyTitle ?? commission.visitId,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: CupertinoIcons.person_fill,
            label: 'Visiteur',
            value: commission.visitorName ?? commission.visitorId ?? '—',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: CupertinoIcons.calendar,
            label: 'Visite',
            value: commission.visitId,
          ),
          if (commission.failedAttempts > 0) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: CupertinoIcons.exclamationmark_triangle,
              label: 'Tentatives échouées',
              value: '${commission.failedAttempts}/5',
              valueColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: valueColor ?? Theme.of(context).textTheme.displayLarge?.color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationSection(commission) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.clock,
            color: AppColors.warning,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'En attente de vérification avec le code OTP',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 120,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.money_dollar_circle,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commission',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos commissions apparaîtront ici une fois que des visiteurs auront payé des visites sur vos propriétés déléguées.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(status) {
    final statusValue = status is String ? status : status.value;
    switch (statusValue) {
      case 'verified':
        return AppColors.success;
      case 'code_sent':
        return AppColors.warning;
      case 'pending':
        return AppColors.info;
      case 'expired':
      case 'locked':
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(status) {
    final statusValue = status is String ? status : status.value;
    switch (statusValue) {
      case 'verified':
        return CupertinoIcons.checkmark_circle_fill;
      case 'code_sent':
        return CupertinoIcons.clock_fill;
      case 'pending':
        return CupertinoIcons.hourglass;
      case 'expired':
      case 'locked':
      case 'cancelled':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.circle;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);
    
    if (difference.isNegative) {
      return 'expiré';
    } else if (difference.inHours > 0) {
      return 'dans ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'dans ${difference.inMinutes}min';
    } else {
      return 'bientôt';
    }
  }
}