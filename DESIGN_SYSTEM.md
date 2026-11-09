# ArcFit Design System Specification

## Design Direction: Data-Dense & Functional

**Core Philosophy**: Information-rich, efficient for power users, clear hierarchy. Every pixel serves a purpose. High information density without visual clutter.

---

## Color Palette

### Light Theme
```dart
// Primary - Deep Slate Blue (trust, focus, performance)
static const Color primary = Color(0xFF2D4A6B);
static const Color primaryLight = Color(0xFF4A6FA5);
static const Color primaryDark = Color(0xFF1E344F);
static const Color primaryContainer = Color(0xFFE8EEF5);
static const Color onPrimaryContainer = Color(0xFF1E344F);

// Secondary - Warm Amber (energy, progress, strength)
static const Color secondary = Color(0xFFB8860B);
static const Color secondaryLight = Color(0xFFD4A83C);
static const Color secondaryContainer = Color(0xFFFFF3E0);
static const Color onSecondaryContainer = Color(0xFF5D4000);

// Accent - Emerald Green (success, completion, health)
static const Color success = Color(0xFF007A33);
static const Color successContainer = Color(0xFFE8F5E9);
static const Color warning = Color(0xFFE65100);
static const Color warningContainer = Color(0xFFFFF8E1);
static const Color error = Color(0xFFC62828);
static const Color errorContainer = Color(0xFFFDEDEC);

// Neutrals - High contrast, readable
static const Color background = Color(0xFFFAFAFA);        // Near white
static const Color surface = Color(0xFFFFFFFF);           // Pure white
static const Color surfaceVariant = Color(0xFFF5F5F5);    // Subtle grey
static const Color surfaceContainer = Color(0xFFEEEEEE);  // Card backgrounds
static const Color surfaceContainerHigh = Color(0xFFE0E0E0); // Borders, dividers

static const Color onBackground = Color(0xFF1A1A1A);      // Near black
static const Color onSurface = Color(0xFF1A1A1A);
static const Color onSurfaceVariant = Color(0xFF424242);
static const Color outline = Color(0xFFBDBDBD);
static const Color outlineVariant = Color(0xFFE0E0E0);

// Shadows - Subtle, layered
static const Color shadow = Color(0x0D000000);      // 5%
static const Color shadowMedium = Color(0x14000000); // 8%
static const Color shadowStrong = Color(0x1F000000); // 12%
```

### Dark Theme
```dart
static const Color darkBackground = Color(0xFF0D1117);       // GitHub-style dark
static const Color darkSurface = Color(0xFF161B22);
static const Color darkSurfaceVariant = Color(0xFF21262D);
static const Color darkSurfaceContainer = Color(0xFF30363D);
static const Color darkSurfaceContainerHigh = Color(0xFF484F58);

static const Color darkOnBackground = Color(0xFFF0F6FC);
static const Color darkOnSurface = Color(0xFFF0F6FC);
static const Color darkOnSurfaceVariant = Color(0xFF8B949E);
static const Color darkOutline = Color(0xFF30363D);
static const Color darkOutlineVariant = Color(0xFF21262D);

static const Color darkShadow = Color(0x33000000);
static const Color darkShadowMedium = Color(0x4D000000);
static const Color darkShadowStrong = Color(0x66000000);

// Adjusted primaries for dark
static const Color darkPrimary = Color(0xFF58A6FF);
static const Color darkPrimaryContainer = Color(0xFF1F3A5F);
static const Color darkSecondary = Color(0xFFD2A106);
static const Color darkSuccess = Color(0xFF3FB950);
```

---

## Typography

### Font Stack
- **Display**: `Space Grotesk` - Technical, geometric, highly readable at large sizes
- **Body**: `IBM Plex Sans` - Highly legible, distinct numerals, great for data
- **Mono**: `JetBrains Mono` - Tabular figures, code, timers

### Type Scale (Mobile-first)
```dart
// Display - Space Grotesk
displayLarge: 57px / 64px / w400 / -0.25 tracking  // Hero numbers
displayMedium: 45px / 52px / w400 / 0 tracking     // Screen titles
displaySmall: 36px / 44px / w400 / 0 tracking      // Section heroes

// Headline - Space Grotesk
headlineLarge: 32px / 40px / w500 / 0 tracking     // Card titles
headlineMedium: 28px / 36px / w500 / 0 tracking    // Sub-section
headlineSmall: 24px / 32px / w500 / 0 tracking     // Group headers

// Title - Space Grotesk (lg) / IBM Plex Sans (md, sm)
titleLarge: 22px / 28px / w500 / 0 tracking        // List items
titleMedium: 16px / 24px / w600 / 0.15 tracking    // Button labels, chips
titleSmall: 14px / 20px / w600 / 0.1 tracking      // Meta labels

// Body - IBM Plex Sans
bodyLarge: 16px / 24px / w400 / 0.5 tracking       // Primary content
bodyMedium: 14px / 20px / w400 / 0.25 tracking     // Secondary content
bodySmall: 12px / 16px / w400 / 0.4 tracking       // Captions, hints

// Label - IBM Plex Sans
labelLarge: 14px / 20px / w600 / 0.1 tracking      // Form labels
labelMedium: 12px / 16px / w600 / 0.5 tracking     // Chip text
labelSmall: 11px / 16px / w600 / 0.5 tracking      // Overline, badges

// Data - JetBrains Mono (tabular nums)
dataLarge: 20px / 28px / w700 / 0 tracking         // Big metrics
dataMedium: 16px / 24px / w600 / 0 tracking        // Standard metrics
dataSmall: 13px / 20px / w600 / 0 tracking         // Inline metrics
dataMicro: 11px / 16px / w500 / 0 tracking         // Tiny badges
```

---

## Spacing System (4px base unit)
```dart
space1: 4px
space2: 8px
space3: 12px
space4: 16px
space5: 20px
space6: 24px
space7: 28px
space8: 32px
space10: 40px
space12: 48px
space16: 64px
```

### Layout Grid
- **Mobile**: 16px side gutters, 4px baseline grid
- **Content max-width**: 400px (comfortable reading)
- **Card internal padding**: 16px (space4)
- **Section spacing**: 24px (space6)
- **Component gap**: 12px (space3)

---

## Border Radius
```dart
radiusXs: 4px    // Chips, badges
radiusSm: 8px    // Buttons, inputs
radiusMd: 12px   // Cards, sheets
radiusLg: 16px   // Modals, bottom sheets
radiusXl: 24px   // Full-screen modals
radiusFull: 999px // Pills, avatars
```

---

## Elevation / Shadows (Layered)
```dart
// Level 0 - Flat (default)
elevation0: none

// Level 1 - Card resting
elevation1: 0 1px 3px 0 rgba(0,0,0,0.05), 0 1px 2px -1px rgba(0,0,0,0.04)

// Level 2 - Card hover / pressed
elevation2: 0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -2px rgba(0,0,0,0.04)

// Level 3 - Modal / dropdown
elevation3: 0 10px 15px -3px rgba(0,0,0,0.05), 0 4px 6px -4px rgba(0,0,0,0.04)

// Level 4 - Floating (FAB, toast)
elevation4: 0 20px 25px -5px rgba(0,0,0,0.05), 0 8px 10px -6px rgba(0,0,0,0.04)
```

---

## Component Specifications

### Cards
- **Background**: surface / darkSurface
- **Border**: 1px outlineVariant / darkOutlineVariant
- **Radius**: 12px (radiusMd)
- **Padding**: 16px (space4)
- **Shadow**: elevation1 (light) / none (dark)

### Buttons
| Variant | Height | Padding | Radius | Weight |
|---------|--------|---------|--------|--------|
| Primary (Filled) | 48px | 24px horiz | 12px | w600 |
| Secondary (Outlined) | 48px | 24px horiz | 12px | w600 |
| Tertiary (Text) | 40px | 16px horiz | 8px | w600 |
| Icon Button | 40x40 | - | 12px | - |

### Input Fields
- **Height**: 52px (comfortable touch target)
- **Padding**: 16px horiz, 14px vert
- **Radius**: 12px
- **Border**: 1px outlineVariant (default), 2px primary (focus)
- **Label**: 12px above field when focused

### Navigation Bar
- **Height**: 72px (safe area aware)
- **Background**: surface@85% blur / darkSurface@85% blur
- **Indicator**: primaryContainer, 4px top radius
- **Label**: labelSmall, always show

### Chips / Pills
- **Height**: 28px
- **Padding**: 10px horiz
- **Radius**: radiusFull
- **Border**: 1px outlineVariant (unselected)

### Data Display
- **Metric cards**: Icon (24px) + Label (labelSmall) + Value (dataLarge)
- **Progress rings**: 8px stroke, rounded caps, primary color
- **Bar charts**: 16px bar width, 4px gap, rounded top radius
- **Tables**: 12px cell padding, outlineVariant dividers

---

## Motion
```dart
durationFast: 150ms    // Micro-interactions
durationNormal: 250ms  // Standard transitions
durationSlow: 350ms    // Page transitions, modals

curveStandard: Cubic(0.4, 0.0, 0.2, 1.0)      // Material standard
curveEmphasized: Cubic(0.4, 0.0, 0.2, 1.0)    // Same
curveDecelerated: Cubic(0.0, 0.0, 0.2, 1.0)   // Exits
curveAccelerated: Cubic(0.4, 0.0, 1.0, 1.0)   // Entrances
```

---

## Accessibility
- **Minimum touch target**: 48x48px
- **Contrast ratio**: 4.5:1 (AA), 7:1 (AAA for key metrics)
- **Focus indicators**: 2px primary outline, 2px offset
- **Reduced motion**: Respect `prefers-reduced-motion`
- **Dynamic type**: Support system font scaling up to 200%

---

## Screen-Specific Patterns

### Dashboard
- Hero metric ring (100px) + 3 stat pills horizontal scroll
- Weekly bar chart (200px height, 7 bars)
- Quick actions: 3-column grid, 48px min height
- Progress card: Inline metrics row

### Workout Logging
- Sticky header: Title + Timer + Rest button
- Exercise cards: Expandable, inline steppers (sets/reps/weight)
- Inline rest timer per exercise
- Bottom bar: Cancel / Finish (primary)

### Nutrition
- Date picker inline (compact)
- Macro rings: 3 donut charts horizontal (120px each)
- Calorie progress bar (full width)
- Meal sections: Collapsible, inline add food

### Leaderboard
- Podium view (top 3) with gradient backdrop
- Category chips (scrollable)
- List: Rank + Avatar + Name + Metric + Streak badge
- Current user row highlighted

---

## Implementation Checklist

### Phase 1: Core Theme (app_theme.dart)
- [ ] Update color palette
- [ ] Update typography with Google Fonts
- [ ] Update all component themes
- [ ] Add dark theme parity

### Phase 2: UI Components (ui_components.dart)
- [ ] MetricCard / StatPill
- [ ] DataCard / ProgressRing
- [ ] ExerciseCard / SetStepper
- [ ] MealSection / FoodTile
- [ ] LeaderboardTile / PodiumView

### Phase 3: Screens
- [ ] DashboardScreen
- [ ] WorkoutLoggingScreen
- [ ] NutritionScreen
- [ ] LeaderboardScreen
- [ ] MainNavigationScaffold

### Phase 4: Polish
- [ ] Animations / transitions
- [ ] Accessibility audit
- [ ] Dark mode refinement
- [ ] Tablet layout adaptations