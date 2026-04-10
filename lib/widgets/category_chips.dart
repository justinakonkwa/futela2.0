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

  @override
  void didUpdateWidget(CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Synchroniser avec les changements externes
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      _selectedCategory = widget.selectedCategory;
    }
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
              _buildCategoryChip(
                context,
                label: 'Toutes',
                isSelected: _selectedCategory == null,
                onTap: () {
                  setState(() => _selectedCategory = null);
                  widget.onCategorySelected?.call(null);
                },
              ),
              const SizedBox(width: 10),
              ...propertyProvider.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildCategoryChip(
                    context,
                    label: category.name,
                    isSelected: _selectedCategory == category.name,
                    onTap: () {
                      setState(() => _selectedCategory = category.name);
                      widget.onCategorySelected?.call(category.name);
                    },
                  ),
                );
              }),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  )
                : null,
            color: isSelected ? null : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              letterSpacing: isSelected ? -0.2 : 0,
            ),
          ),
        ),
      ),
    );
  }
}
