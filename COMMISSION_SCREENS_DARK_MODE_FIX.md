# Commission Screens Dark Mode Fix

## Problem
The commission-related screens had invisible titles and back buttons in dark mode due to hardcoded colors.

## Screens Fixed

### 1. Wallet Screen (`lib/screens/commission/wallet_screen.dart`)
**Issues:**
- Title "Mon Wallet" was invisible (`AppColors.textPrimary`)
- Back button had white background (`AppColors.white`)
- Back button icon was invisible (`AppColors.textPrimary`)

**Fixes:**
```dart
// Title
color: Theme.of(context).textTheme.displayLarge?.color

// Back button background
color: Theme.of(context).cardColor

// Back button icon
color: Theme.of(context).textTheme.displayLarge?.color
```

---

### 2. Commissions List Screen (`lib/screens/commission/commissions_list_screen.dart`)
**Issues:**
- Title "Mes Commissions" was invisible
- Back button had white background
- Back button icon was invisible

**Fixes:**
```dart
// Title
color: Theme.of(context).textTheme.displayLarge?.color

// Back button background
color: Theme.of(context).cardColor

// Back button icon
color: Theme.of(context).textTheme.displayLarge?.color
```

---

### 3. Commissionnaire Dashboard (`lib/screens/commission/commissionnaire_dashboard.dart`)
**Issues:**
- Title "Commissionnaire" was invisible

**Fixes:**
```dart
// Title
color: Theme.of(context).textTheme.displayLarge?.color
```

---

### 4. Commission Verification Screen (`lib/screens/commission/commission_verification_screen.dart`)
**Issues:**
- Title "Vérifier une commission" was invisible
- Background was hardcoded (`AppColors.background`)
- Back button had white background
- Back button icon was invisible
- Border color was hardcoded

**Fixes:**
```dart
// Background
backgroundColor: Theme.of(context).scaffoldBackgroundColor

// Title
color: Theme.of(context).textTheme.displayLarge?.color

// Back button background
color: Theme.of(context).cardColor

// Back button border
border: Border.all(
  color: Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
      : AppColors.border.withValues(alpha: 0.3),
)

// Back button icon
color: Theme.of(context).textTheme.displayLarge?.color
```

## Pattern Used

All screens now follow the same adaptive pattern:

### AppBar Title
```dart
Text(
  'Title',
  style: TextStyle(
    fontWeight: FontWeight.w600,
    color: Theme.of(context).textTheme.displayLarge?.color,  // Adaptive
  ),
)
```

### Back Button Container
```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,  // Adaptive background
    borderRadius: BorderRadius.circular(12),
    // Optional adaptive border
    border: Border.all(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
          : AppColors.border.withValues(alpha: 0.3),
    ),
  ),
  child: Icon(
    Icons.arrow_back_rounded,
    color: Theme.of(context).textTheme.displayLarge?.color,  // Adaptive icon
  ),
)
```

### Background
```dart
Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,  // Adaptive
  // ...
)
```

## Files Modified

1. ✅ `lib/screens/commission/wallet_screen.dart`
2. ✅ `lib/screens/commission/commissions_list_screen.dart`
3. ✅ `lib/screens/commission/commissionnaire_dashboard.dart`
4. ✅ `lib/screens/commission/commission_verification_screen.dart`

## Result

✅ All commission screen titles are now visible in dark mode
✅ All back buttons have appropriate backgrounds
✅ All icons adapt to theme
✅ Consistent visual hierarchy maintained
✅ No white backgrounds on dark theme
✅ No dark text on dark backgrounds

## Testing Checklist

### Wallet Screen
- [ ] "Mon Wallet" title is visible in dark mode
- [ ] Back button is visible with appropriate background
- [ ] Back button icon is visible

### Commissions List Screen
- [ ] "Mes Commissions" title is visible in dark mode
- [ ] Back button is visible with appropriate background
- [ ] Back button icon is visible

### Commissionnaire Dashboard
- [ ] "Commissionnaire" title is visible in dark mode
- [ ] All content is readable

### Commission Verification Screen
- [ ] "Vérifier une commission" title is visible in dark mode
- [ ] Background adapts to theme
- [ ] Back button is visible with appropriate background
- [ ] Back button icon is visible
- [ ] Border is visible in dark mode
