---
name: food-ingredient-scanner-design
description: Visual identity for Food Ingredient Scanner app
status: draft
updated: 2026-10-22
design_system: Material Design 3 (iOS-adapted)
primary_color: #10B981
---

# Food Ingredient Scanner - Design System

## Brand & Style

**Brand Name:** FoodScan (placeholder)

**Brand Essence:** A welcoming, trustworthy companion for healthier eating decisions.

**Visual Personality:**
- **Fresh** - Natural, clean, alive with purpose
- **Supportive** - Never judgmental, always educational
- **Accessible** - Clear at a glance in a grocery aisle
- **Warm** - Family-friendly, inviting, not clinical

**Design Philosophy:**
This app serves people making real decisions while shopping. The design must be instantly readable under fluorescent lights, with a phone in one hand and a product in the other. Safety information is presented gently - educational rather than alarmist.

---

## Colors

### Primary Palette

| Role | Color | Usage |
|------|-------|-------|
| **Primary** | `#10B981` (Emerald 500) | Primary actions, active states, positive indicators |
| **Primary Dark** | `#059669` (Emerald 600) | Press states, elevated emphasis |
| **Primary Light** | `#D1FAE5` (Emerald 100) | Backgrounds, subtle highlights |
| **Primary Surface** | `#ECFDF5` (Emerald 50) | Card backgrounds, elevated surfaces |

### Safety Status Colors (Gentle Approach)

| Status | Background | Text | Icon |
|--------|------------|------|------|
| **Safe** | `#D1FAE5` | `#065F46` | ✓ Check |
| **Caution** | `#FEF3C7` | `#92400E` | ⚠ Alert |
| **Avoid** | `#FEE2E2` | `#991B1B` | ✗ X |
| **Unknown** | `#F3F4F6` | `#4B5563` | ? Question |

### Neutral Palette

| Role | Color | Usage |
|------|-------|-------|
| **Text Primary** | `#1F2937` (Gray 900) | Headlines, primary text |
| **Text Secondary** | `#6B7280` (Gray 500) | Body text, descriptions |
| **Text Tertiary** | `#9CA3AF` (Gray 400) | Hints, placeholders |
| **Border** | `#E5E7EB` (Gray 200) | Dividers, outlines |
| **Background** | `#FAFAFA` | App background |
| **Surface** | `#FFFFFF` | Cards, sheets |

### Semantic Colors

| Role | Color | Usage |
|------|-------|-------|
| **Success** | `#10B981` | Positive confirmations |
| **Warning** | `#F59E0B` | Caution states, warnings |
| **Error** | `#EF4444` | Errors, avoid list matches |
| **Info** | `#3B82F6` | Informational content |
| **Premium** | `#F59E0B` | Premium badges, upgrade CTAs |

### Dark Mode Mapping

| Light | Dark |
|-------|------|
| `#1F2937` | `#F9FAFB` |
| `#6B7280` | `#D1D5DB` |
| `#10B981` | `#10B981` (maintain) |
| `#FFFFFF` | `#1F2937` |
| `#D1FAE5` | `#064E3B` |

---

## Typography

### Font Family

**Primary:** SF Pro Display (iOS native)
**Fallback:** System sans-serif

### Type Scale

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| **Display Large** | 32pt | Bold (700) | 40pt | Hero headlines |
| **Headline** | 24pt | Bold (700) | 32pt | Screen titles |
| **Title** | 20pt | SemiBold (600) | 28pt | Section headers |
| **Body Large** | 17pt | Regular (400) | 24pt | Primary content |
| **Body** | 15pt | Regular (400) | 22pt | Standard text |
| **Body Small** | 13pt | Regular (400) | 18pt | Secondary info |
| **Caption** | 11pt | Regular (400) | 16pt | Labels, hints |
| **Button** | 17pt | SemiBold (600) | 24pt | Button text |

### Text Guidelines

- Never use all caps for body text
- Maintain minimum 4.5:1 contrast ratio for text
- Line length: 45-75 characters optimal
- Support dynamic type up to Accessibility Large

---

## Layout & Spacing

### Grid System

- **Columns:** 4-column grid for mobile
- **Gutter:** 16px between columns
- **Margins:** 16px on edges
- **Base Unit:** 4px (all spacing multiples of 4)

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Tight icon spacing |
| `sm` | 8px | Compact element spacing |
| `md` | 16px | Standard element spacing |
| `lg` | 24px | Section spacing |
| `xl` | 32px | Large section spacing |
| `2xl` | 48px | Screen-level spacing |

### Safe Areas

- Respect iOS notched device safe areas
- Bottom navigation: 84px height (includes home indicator)
- Status bar: 47px (Dynamic Island) / 44px (standard)

---

## Elevation & Depth

### Elevation Levels

| Level | Shadow | Usage |
|-------|--------|-------|
| **E0** | None | Flat elements |
| **E1** | 0 1px 3px rgba(0,0,0,0.12) | Cards, buttons |
| **E2** | 0 4px 6px rgba(0,0,0,0.1) | Floating elements |
| **E3** | 0 10px 15px rgba(0,0,0,0.1) | Dialogs, sheets |
| **E4** | 0 20px 25px rgba(0,0,0,0.15) | Modals |

### Z-Index Scale

| Layer | Z-Index |
|-------|---------|
| Background | 0 |
| Content | 10 |
| Cards | 50 |
| Floating Action | 100 |
| Modal Sheet | 200 |
| Dialog | 300 |
| Toast/Snackbar | 400 |

---

## Shapes

### Border Radius

| Element | Radius |
|---------|--------|
| **Buttons** | 12px |
| **Cards** | 16px |
| **Chips** | 16px (full) |
| **Inputs** | 12px |
| **Modals** | 20px |
| **Avatar** | 50% (circle) |
| **Safety Badges** | 20px (pill) |

### Image Shapes

- Product images: 12px radius
- User avatars: Circle
- Safety icons: Circle background

---

## Components

### Buttons

**Primary Button**
```
Background: Primary (#10B981)
Text: White
Height: 48px
Radius: 12px
Weight: SemiBold
```

**Secondary Button**
```
Background: Transparent (outlined)
Border: 1px Primary
Text: Primary
Height: 48px
```

**Tertiary Button**
```
Background: Transparent
Text: Primary
Height: 44px
No border
```

**Floating Action Button**
```
Size: 56px circular
Background: Primary
Elevation: E2
```

### Cards

**Elevated Card**
```
Background: White
Radius: 16px
Shadow: E1
Padding: 16px
```

**Outlined Card**
```
Background: White
Border: 1px Border
Radius: 16px
Padding: 16px
```

**Interactive Card**
```
Tap feedback: Scale 0.98
Highlight: Primary Light overlay
```

### Navigation

**Bottom Navigation**
```
Height: 84px (includes safe area)
Background: White
Unselected: Gray 400
Selected: Primary
Icons: 24pt
Labels: 11pt
Items: 3-5 max
```

**App Bar**
```
Height: 56px (standard)
Background: White
Title: Headline style
Actions: 24pt icons
```

### Inputs

**Text Field**
```
Height: 56px
Background: Gray 50
Border: 1px Gray 200 (focused: Primary)
Radius: 12px
Padding: 16px
Label: Gray 500
```

**Dropdown**
```
Same as text field
Trailing chevron icon
```

### Badges & Chips

**Safety Badge**
```
Pill-shaped
Background: Status color (light)
Text: Status color (dark)
Padding: 8px 16px
```

**Filter Chip**
```
Background: Gray 100 (selected: Primary Light)
Text: Gray 700 (selected: Primary)
Radius: 16px
Height: 36px
```

### Lists

**List Item**
```
Height: 64px (default)
Leading: 40pt icon/avatar
Trailing: Chevron or action
Divider: 1px Gray 100
```

**Swipeable Item**
```
Left swipe: Add to avoid list (green)
Right swipe: Remove (red)
```

---

## Iconography

### Icon Sizes

| Size | Usage |
|------|-------|
| 16pt | Inline, small lists |
| 20pt | Standard lists |
| 24pt | App bar, buttons |
| 30pt | Featured, emphasis |
| 40pt | Empty states |
| 64pt | Hero illustrations |

### Icon Style

- Use SF Symbols (iOS native)
- Filled for active, outline for inactive
- Consistent stroke weight

---

## Motion

### Duration

| Action | Duration |
|--------|----------|
| **Micro-interaction** | 150ms |
| **Standard** | 300ms |
| **Complex** | 500ms |

### Easing

- **Enter:** cubic-bezier(0.0, 0.0, 0.2, 1)
- **Exit:** cubic-bezier(0.4, 0.0, 1, 1)
- **Emphasis:** cubic-bezier(0.2, 0.0, 0, 1)

### Principles

- Always meaningful, never decorative
- Respect reduce motion settings
- Preserve context during transitions

---

## Do's and Don'ts

### DO
- ✅ Use green for positive/safe - it's universally understood
- ✅ Keep safety info readable at 40ft (grocery aisle distance)
- ✅ Use gentle language even for dangerous allergens
- ✅ Provide educational context for every warning
- ✅ Support large text accessibility
- ✅ Design for one-handed thumb use (bottom 60% of screen)

### DON'T
- ❌ Use red for everything that's "bad" - too alarming
- ❌ Shame users for scanning products with allergens
- ❌ Hide critical info behind taps or swipes
- ❌ Use small text for safety warnings
- ❌ Rely on color alone - include icons and text
- ❌ Create complex flows during shopping (time-pressured context)

---

## Assets

### Required Icons
- Scan/QR code
- Camera
- Gallery
- Search
- Settings
- Library/Book
- List/Avoid List
- Star/Premium
- Warning/Alert
- Check/Safe
- X/Avoid
- Info/Education
- Plus/Add
- Trash/Delete
- Share
- Family/Profiles

### Product Assets
- App icon: Clean, recognizable at small sizes
- Splash screen: Brand color + logo
- Onboarding illustrations: Friendly, diverse, inclusive
