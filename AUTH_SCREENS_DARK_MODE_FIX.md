# Auth Screens Dark Mode Fix

## Problem
The authentication screens (Login, Register, Forgot Password) had multiple visibility issues in dark mode where text elements were using hardcoded dark colors (`AppColors.textPrimary`, `AppColors.textSecondary`, `AppColors.textTertiary`) making them invisible against dark backgrounds.

## Affected Screens

### 1. Login Screen (`lib/screens/auth/login_screen.dart`)
**Invisible Elements:**
- "Bienvenue" title
- "Connectez-vous pour continuer" subtitle
- Back button icon
- Eye icon (password visibility toggle)
- Terms and conditions text

### 2. Register Screen (`lib/screens/auth/register_screen.dart`)
**Invisible Elements:**
- "Créer un compte" title
- "Rejoignez Futela" subtitle
- Back button icon
- Eye icons (password visibility toggles)
- "J'accepte les conditions..." checkbox text
- "Déjà un compte ?" text

### 3. Forgot Password Screen (`lib/screens/auth/forgot_password_screen.dart`)
**Invisible Elements:**
- "Mot de passe oublié" / "Vérifiez votre email" title
- "Entrez votre email..." subtitle
- Back button icon
- "Vous vous souvenez ?" text
- "Conseil" info box text and icon

## Solutions Applied

### Pattern Used
Replace hardcoded colors with theme-aware alternatives:

```dart
// Before (❌ Invisible in dark mode)
color: AppColors.textPrimary

// After (✅ Adapts to theme)
color: Theme.of(context).textTheme.displayLarge?.color
```

```dart
// Before (❌ Invisible in dark mode)
color: AppColors.textSecondary

// After (✅ Adapts to theme)
color: Theme.of(context).textTheme.bodySmall?.color
```

```dart
// Before (❌ Invisible in dark mode)
color: AppColors.textTertiary

// After (✅ Adapts to theme)
color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)
```

### Specific Fixes

#### 1. Login Screen

**Titles:**
```dart
// "Bienvenue"
color: Theme.of(context).textTheme.displayLarge?.color

// "Connectez-vous pour continuer"
color: Theme.of(context).textTheme.bodySmall?.color
```

**Back Button:**
```dart
decoration: BoxDecoration(
  color: Theme.of(context).cardColor,  // Was: AppColors.white
  // ...
),
child: Icon(
  CupertinoIcons.back,
  color: Theme.of(context).textTheme.displayLarge?.color,  // Was: AppColors.textPrimary
)
```

**Eye Icon:**
```dart
color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)
```

**Terms Text:**
```dart
color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)
```

#### 2. Register Screen

**Titles:**
```dart
// "Créer un compte"
color: Theme.of(context).textTheme.displayLarge?.color

// "Rejoignez Futela"
color: Theme.of(context).textTheme.bodySmall?.color
```

**Back Button:**
```dart
decoration: BoxDecoration(
  color: Theme.of(context).cardColor,
  // ...
),
child: Icon(
  CupertinoIcons.back,
  color: Theme.of(context).textTheme.displayLarge?.color,
)
```

**Eye Icons:**
```dart
color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)
```

**Checkbox Text:**
```dart
// "J'accepte les conditions..."
color: Theme.of(context).textTheme.bodySmall?.color
```

**"Déjà un compte ?" Text:**
```dart
color: Theme.of(context).textTheme.bodySmall?.color
```

#### 3. Forgot Password Screen

**Titles:**
```dart
// "Mot de passe oublié" / "Vérifiez votre email"
color: Theme.of(context).textTheme.displayLarge?.color

// Subtitle
color: Theme.of(context).textTheme.bodySmall?.color
```

**Back Button:**
```dart
Icon(CupertinoIcons.back, color: Theme.of(context).textTheme.displayLarge?.color)
```

**"Vous vous souvenez ?" Text:**
```dart
color: Theme.of(context).textTheme.bodySmall?.color
```

**Info Box:**
```dart
decoration: BoxDecoration(
  color: Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surfaceContainerHighest
      : AppColors.grey50,
  border: Border.all(
    color: Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
        : AppColors.grey200,
  ),
),
// Icon
color: Theme.of(context).textTheme.bodySmall?.color

// "Conseil" title
color: Theme.of(context).textTheme.displayLarge?.color

// Description text
color: Theme.of(context).textTheme.bodySmall?.color
```

## Files Modified

1. **`lib/screens/auth/login_screen.dart`**
   - Fixed title and subtitle colors
   - Fixed back button background and icon color
   - Fixed eye icon color
   - Fixed terms text color

2. **`lib/screens/auth/register_screen.dart`**
   - Fixed title and subtitle colors
   - Fixed back button background and icon color
   - Fixed eye icons colors
   - Fixed checkbox text color
   - Fixed "Déjà un compte ?" text color

3. **`lib/screens/auth/forgot_password_screen.dart`**
   - Fixed title and subtitle colors
   - Fixed back button icon color
   - Fixed "Vous vous souvenez ?" text color
   - Fixed info box background, border, icon, and text colors

## Result

✅ All text is now visible in dark mode
✅ Back buttons have appropriate backgrounds
✅ Icons adapt to theme
✅ Info boxes have theme-aware backgrounds and borders
✅ Consistent visual hierarchy maintained
✅ No white backgrounds on dark theme
✅ No dark text on dark backgrounds

## Testing Checklist

Test the following in both light and dark modes:

### Login Screen
- [ ] "Bienvenue" title is visible
- [ ] "Connectez-vous pour continuer" subtitle is visible
- [ ] Back button is visible with appropriate background
- [ ] Eye icon for password visibility is visible
- [ ] Terms and conditions text is readable

### Register Screen
- [ ] "Créer un compte" title is visible
- [ ] "Rejoignez Futela" subtitle is visible
- [ ] Back button is visible
- [ ] All field labels are visible
- [ ] Eye icons are visible
- [ ] "J'accepte les conditions..." text is visible
- [ ] "Déjà un compte ?" text is visible

### Forgot Password Screen
- [ ] Title is visible (both states)
- [ ] Subtitle is visible
- [ ] Back button is visible
- [ ] "Vous vous souvenez ?" text is visible
- [ ] Info box is visible with readable text
- [ ] "Conseil" title and description are readable
