import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/public_profile_provider.dart';
import '../../utils/app_colors.dart';
import '../property/property_detail_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  final String? ownerName;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    this.ownerName,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PublicProfileProvider>();
      provider.reset();
      provider.loadProfile(userId: widget.userId);
      provider.loadProperties(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<PublicProfileProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (provider.isLoadingProfile)
                      _buildProfileShimmer()
                    else if (provider.profile != null)
                      _buildProfileHeader(context, provider.profile!),

                    const SizedBox(height: 8),

                    _buildPropertiesSection(context, provider),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, PublicProfileProvider provider) {
    final name = provider.profile?.fullName ?? widget.ownerName ?? 'Profil';
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: const Center(
              child: Icon(Icons.arrow_back_rounded, size: 22, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, profile) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar + badges
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primaryLight.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: profile.avatar != null
                      ? CachedNetworkImageProvider(profile.avatar!)
                      : null,
                  child: profile.avatar == null
                      ? Text(
                          profile.fullName.isNotEmpty
                              ? profile.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ),
              if (profile.isCertified)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Nom
          Text(
            profile.fullName,
            style: const TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),

          // Business name
          if (profile.businessName != null && profile.businessName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.businessName!,
              style: const TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Badges rôles
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (profile.isCommissionnaire)
                _buildBadge('Commissionnaire', AppColors.primary, Icons.business_center_rounded),
              if (profile.isVerified)
                _buildBadge('Vérifié', AppColors.success, Icons.verified_rounded),
              if (profile.isCertified)
                _buildBadge('Certifié', AppColors.warning, Icons.workspace_premium_rounded),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                context,
                '${profile.propertyCount}',
                'Propriétés',
                Icons.home_work_rounded,
                AppColors.primary,
              ),
              _buildStatDivider(),
              _buildStat(
                context,
                profile.isAvailable ? 'Disponible' : 'Indisponible',
                'Statut',
                Icons.circle,
                profile.isAvailable ? AppColors.success : AppColors.textTertiary,
              ),
              _buildStatDivider(),
              _buildStat(
                context,
                _formatMemberSince(profile.createdAt),
                'Membre depuis',
                Icons.calendar_today_rounded,
                AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: AppColors.border);
  }

  Widget _buildPropertiesSection(BuildContext context, PublicProfileProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_work_rounded, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ses propriétés',
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (provider.properties.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.properties.length}',
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (provider.isLoadingProperties)
          _buildPropertiesShimmer()
        else if (provider.properties.isEmpty)
          _buildEmptyProperties()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: provider.properties.length,
            itemBuilder: (context, index) {
              return _buildPropertyItem(context, provider.properties[index]);
            },
          ),
      ],
    );
  }

  Widget _buildPropertyItem(BuildContext context, item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(propertyId: item.id),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Photo
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 100,
                  height: 90,
                  child: item.photo != null
                      ? CachedNetworkImage(
                          imageUrl: item.photo!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _photoPlaceholder(),
                        )
                      : _photoPlaceholder(),
                ),
              ),
              const SizedBox(width: 14),
              // Infos
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.location.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textTertiary),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                item.location,
                                style: const TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Text(
                        item.formattedPrice,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: AppColors.grey100,
      child: const Center(
        child: Icon(Icons.home_work_rounded, size: 32, color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildEmptyProperties() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.home_work_outlined, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune propriété publiée',
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileShimmer() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _shimmerBox(96, 96, isCircle: true),
          const SizedBox(height: 16),
          _shimmerBox(24, 180),
          const SizedBox(height: 8),
          _shimmerBox(16, 120),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _shimmerBox(28, 100),
              const SizedBox(width: 8),
              _shimmerBox(28, 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(3, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _shimmerBox(90, 100, radius: 16),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(16, double.infinity),
                      const SizedBox(height: 8),
                      _shimmerBox(12, 120),
                      const SizedBox(height: 8),
                      _shimmerBox(18, 80),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget _shimmerBox(double height, double width, {bool isCircle = false, double radius = 8}) {
    return Container(
      height: height,
      width: width == double.infinity ? null : width,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  String _formatMemberSince(DateTime date) {
    final now = DateTime.now();
    final months = (now.year - date.year) * 12 + now.month - date.month;
    if (months < 1) return 'Ce mois';
    if (months < 12) return '$months mois';
    final years = (months / 12).floor();
    return '$years an${years > 1 ? 's' : ''}';
  }
}
