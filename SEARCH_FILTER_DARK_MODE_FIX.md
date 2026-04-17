# Search Filter Dark Mode Fix

## Problem
The search filter modal in dark mode had several visibility issues:

1. **Invisible Equipment Labels**: Labels like "Meublé", "Parking", "Piscine", "Balcon", "Climatisation", "Chauffage", and "Animaux autorisés" were invisible because they used `AppColors.textPrimary` (a dark color) on a dark background.

2. **Overly Bright Input Fields**: Text input fields (Chambres min/max, SDB min/max, Surface min/max, Étage min/max, Prix min/max) had white backgrounds (`AppColors.grey50`) creating harsh contrast in dark mode.

3. **Invisible Borders**: Input field borders used `AppColors.grey200` which was barely visible in dark mode.

4. **Hint Text**: Placeholder text was using hardcoded `AppColors.textTertiary` instead of theme-aware colors.

## Solution

### 1. Fixed Equipment Labels (`lib/screens/search/search_screen.dart`)

**Before:**
```dart
Text(
  label,
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppColors.textPrimary,  // ❌ Dark color, invisible in dark mode
  ),
),
```

**After:**
```dart
Text(
  label,
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Theme.of(context).textTheme.displayLarge?.color,  // ✅ Theme-aware
  ),
),
```

### 2. Fixed Input Field Backgrounds (`lib/widgets/custom_text_field.dart`)

**Before:**
```dart
fillColor: enabled
    ? AppColors.grey50  // ❌ Always white/light gray
    : Theme.of(context).colorScheme.surfaceContainerHighest,
```

**After:**
```dart
fillColor: enabled
    ? Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerHighest  // Dark mode
        : AppColors.grey50  // Light mode
    : Theme.of(context).colorScheme.surfaceContainerHighest,
```

### 3. Fixed Input Field Borders

**Before:**
```dart
enabledBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(_radius),
  borderSide: BorderSide(color: AppColors.grey200, width: 1),  // ❌ Hardcoded
),
```

**After:**
```dart
enabledBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(_radius),
  borderSide: BorderSide(
    color: Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.outline.withOpacity(0.3)  // More visible in dark
        : AppColors.grey200,
    width: 1,
  ),
),
```

### 4. Fixed Hint Text and Labels

**Label Color:**
```dart
// Before
color: AppColors.textSecondary,

// After
color: Theme.of(context).textTheme.bodySmall?.color,
```

**Hint Text:**
```dart
// Before
color: AppColors.textTertiary,

// After
color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
```

**Counter Text:**
```dart
// Before
color: AppColors.textTertiary,

// After
color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
```

## Files Modified

1. **`lib/screens/search/search_screen.dart`**
   - Fixed `_buildAmenitySwitch()` method to use theme-aware text color

2. **`lib/widgets/custom_text_field.dart`**
   - Fixed `fillColor` to adapt based on theme brightness
   - Fixed `enabledBorder` to use theme-aware border color
   - Fixed `disabledBorder` to use theme-aware border color
   - Fixed `hintStyle` to use theme-aware hint color
   - Fixed `counterStyle` to use theme-aware counter color
   - Fixed label text color to use theme-aware color

## Result

✅ All equipment labels are now visible in dark mode
✅ Input fields have appropriate backgrounds in both themes
✅ Borders are visible in dark mode
✅ Hint text adapts to theme
✅ No harsh white backgrounds in dark mode
✅ Consistent visual hierarchy maintained

## Testing

Test the following in both light and dark modes:

- [ ] Open search screen
- [ ] Tap filter icon
- [ ] Scroll to "Équipements" section
- [ ] Verify all labels are visible (Meublé, Parking, Piscine, Balcon, Climatisation, Chauffage, Animaux autorisés)
- [ ] Check input fields (Chambres, SDB, Surface, Étage) have appropriate backgrounds
- [ ] Verify borders are visible
- [ ] Check hint text is readable
- [ ] Toggle switches work correctly
- [ ] Apply filters and verify functionality
