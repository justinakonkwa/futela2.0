# Property Screens Dark Mode Adaptation

## Overview
The following screens need to be adapted for dark mode to ensure all UI elements are visible and properly styled in both light and dark themes:

1. **Property Detail Screen** (`lib/screens/property/property_detail_screen.dart`)
2. **Property Reviews Screen** (`lib/screens/property/property_reviews_screen.dart`)
3. **Public Profile Screen** (`lib/screens/user/public_profile_screen.dart`)

## Changes Required

### Common Pattern
Replace hardcoded colors with theme-aware alternatives:

- `AppColors.white` → `Theme.of(context).cardColor` (for card/button backgrounds)
- `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- `AppColors.textSecondary` → `Theme.of(context).textTheme.bodySmall?.color`
- `AppColors.textTertiary` → `Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)`
- `AppColors.background` → `Theme.of(context).scaffoldBackgroundColor`
- `AppColors.grey100`, `AppColors.grey200` → Use theme-aware shimmer colors

### 1. Property Detail Screen

#### Action Buttons (AppBar)
- Back button background: `AppColors.white` → `Theme.of(context).cardColor`
- Back button icon: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Favorite button background: `AppColors.white` → `Theme.of(context).cardColor`
- Favorite button icon (not favorited): `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Share button background: `AppColors.white` → `Theme.of(context).cardColor`
- Share button icon: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Edit button background: `AppColors.white` → `Theme.of(context).cardColor`
- Edit button icon: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Delete button background: `AppColors.white` → `Theme.of(context).cardColor`

#### Error States
- Error title: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Error message: `AppColors.textSecondary` → `Theme.of(context).textTheme.bodySmall?.color`
- "Property not found" title: `AppColors.textPrimary` → Remove (use default theme color)

#### Image Placeholders
- Empty image background: `AppColors.grey100` → Conditional based on theme brightness
- Empty image icon: `AppColors.textTertiary` → `Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)`

#### Shimmer Loaders
- Base color: `AppColors.grey200` → `isDark ? Colors.grey[800]! : Colors.grey[200]!`
- Highlight color: `AppColors.grey100` → `isDark ? Colors.grey[700]! : Colors.grey[100]!`

#### Content Cards
- All card backgrounds: `AppColors.white` → `Theme.of(context).cardColor`
- Card borders: Add adaptive opacity (0.3 in dark mode, 0.15 in light mode)

#### Text Colors
- All primary text: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- All secondary text: `AppColors.textSecondary` → `Theme.of(context).textTheme.bodySmall?.color`
- All tertiary text: `AppColors.textTertiary` → `Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)`

### 2. Property Reviews Screen

#### AppBar
- Background: `AppColors.white` → `Theme.of(context).appBarTheme.backgroundColor`
- Title: `AppColors.textPrimary` → Remove (use default theme color)
- Back button background: `AppColors.white` → `Theme.of(context).cardColor`
- Back button icon: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`

#### Stats Header
- Card background: Keep gradient (it's decorative)
- Text colors: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Secondary text: `AppColors.textSecondary` → `Theme.of(context).textTheme.bodySmall?.color`

#### Add Review Sheet
- Sheet background: `AppColors.white` → `Theme.of(context).cardColor`
- Handle bar: `AppColors.grey200` → Conditional based on theme
- Title: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Input field background: `AppColors.background` → `Theme.of(context).scaffoldBackgroundColor`
- Input field border: `AppColors.border` → Adaptive opacity
- Input text: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Hint text: `AppColors.textTertiary` → `Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)`

#### Filter Chips
- Background: `AppColors.white` → `Theme.of(context).cardColor`
- Border: `AppColors.border` → Adaptive opacity
- Text: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`

#### Empty/Error States
- All text colors should be theme-aware

### 3. Public Profile Screen

#### AppBar
- Background: `AppColors.white` → `Theme.of(context).appBarTheme.backgroundColor`
- Title: `AppColors.textPrimary` → Remove (use default theme color)
- Back button background: `AppColors.white` → `Theme.of(context).cardColor`
- Back button icon: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`

#### Profile Header Card
- Card background: `AppColors.white` → `Theme.of(context).cardColor`
- Name: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Business name: Keep `AppColors.primary` (brand color)
- Stats labels: `AppColors.textTertiary` → `Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)`
- Divider: `AppColors.border` → Adaptive opacity

#### Property Items
- Card background: `AppColors.white` → `Theme.of(context).cardColor`
- Title: `AppColors.textPrimary` → `Theme.of(context).textTheme.displayLarge?.color`
- Location text: `AppColors.textTertiary` → `Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)`
- Price: Keep `AppColors.primary` (brand color)
- Arrow icon: `AppColors.textTertiary` → `Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)`

#### Shimmer Placeholders
- Background: `AppColors.white` → `Theme.of(context).cardColor`
- Shimmer boxes: `AppColors.grey200` → Conditional based on theme

#### Empty State
- Background: Keep gradient (decorative)
- Text: `AppColors.textSecondary` → `Theme.of(context).textTheme.bodySmall?.color`

## Implementation Notes

1. **Gradients**: Keep decorative gradients (primary colors, warning colors) as they are brand elements
2. **Icons in gradients**: Keep white icons on colored gradient backgrounds
3. **SnackBars**: Keep white text on colored backgrounds (success, error, warning)
4. **Borders**: Make more visible in dark mode by increasing opacity from 0.15 to 0.3
5. **Shimmer**: Use conditional colors based on `Theme.of(context).brightness == Brightness.dark`

## Testing Checklist

- [ ] All text is visible in both light and dark modes
- [ ] All buttons and cards have appropriate backgrounds
- [ ] Borders are visible in dark mode
- [ ] Shimmer loaders adapt to theme
- [ ] Error states are readable
- [ ] Empty states are readable
- [ ] Icons are visible against their backgrounds
- [ ] No white cards on white backgrounds (light mode)
- [ ] No dark text on dark backgrounds (dark mode)
