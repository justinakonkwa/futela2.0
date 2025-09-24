import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/address_service.dart';
import '../utils/app_colors.dart';

class AddressDisplay extends StatefulWidget {
  final Property property;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const AddressDisplay({
    super.key,
    required this.property,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  State<AddressDisplay> createState() => _AddressDisplayState();
}

class _AddressDisplayState extends State<AddressDisplay> {
  String _displayAddress = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final fullAddress = await AddressService.buildFullAddress(
        address: widget.property.address,
        townName: widget.property.town.name,
        cityId: widget.property.town.city.id,
        provinceId: widget.property.town.city.province.id,
      );

      if (mounted) {
        setState(() {
          _displayAddress = fullAddress;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _displayAddress = widget.property.fullAddress;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Chargement...',
            style: widget.style?.copyWith(
              color: AppColors.textSecondary,
            ) ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Text(
      _displayAddress,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
