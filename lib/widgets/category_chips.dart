import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../utils/app_colors.dart';

class CategoryChips extends StatefulWidget {
  final String? selectedCategory;
  final Function(String?)? onCategorySelected;

  const CategoryChips({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _loadCategories() {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    propertyProvider.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, propertyProvider, child) {
        if (propertyProvider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Toutes les catégories
              _buildCategoryChip(
                context,
                label: 'Toutes',
                isSelected: _selectedCategory == null,
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                  widget.onCategorySelected?.call(null);
                },
              ),
              
              const SizedBox(width: 8),
              
              // Catégories spécifiques
              ...propertyProvider.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildCategoryChip(
                    context,
                    label: category.name,
                    isSelected: _selectedCategory == category.id,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category.id;
                      });
                      widget.onCategorySelected?.call(category.id);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
