---
name: food-ingredient-scanner-experience
description: Experience specification for Food Ingredient Scanner app
status: draft
updated: 2026-10-22
design_reference: DESIGN.md
---

# Food Ingredient Scanner - Experience Specification

## Foundation

### Form Factor
- **Primary:** iPhone (iOS)
- **Breakpoints:** 
  - Compact: 375pt width (iPhone SE)
  - Standard: 390-393pt width (most iPhones)
  - Large: 428pt width (iPhone Pro Max)
- **Orientation:** Portrait only
- **Platform:** iOS 15+

### UI System
- **Design Language:** Material Design 3 adapted for iOS Human Interface Guidelines
- **Navigation Pattern:** Bottom tab bar with FAB
- **Gestures:** Standard iOS gestures + swipe actions on lists

### Design Token Reference
Visual styling is defined in DESIGN.md:
- Colors: `#10B981` (primary), safety colors per status
- Typography: SF Pro Display scale (11pt - 32pt)
- Spacing: 4px base unit (4/8/16/24/32/48)
- Components: Buttons, cards, inputs per DESIGN.md

---

## Information Architecture

### App Structure

```
┌─────────────────────────────────────┐
│           App Bar                   │
├─────────────────────────────────────┤
│                                     │
│          Screen Content             │
│       (Tab-specific view)           │
│                                     │
├─────────────────────────────────────┤
│  Home  │  Avoid  │ Library │ Settings │
│        │  List   │         │    +     │
└─────────────────────────────────────┘
```

### Primary Tabs (4)

| Tab | Icon | Destination | Purpose |
|-----|------|-------------|---------|
| Home | `house` | Dashboard | Quick stats, last scan, recent activity |
| Avoid List | `list.bullet` | Manage avoid list | View, search, add/remove items |
| Library | `book` | Ingredient encyclopedia | Browse allergens, additives, education |
| Settings | `gear` | App preferences | Profile, family, account, preferences |

### Floating Action Button
- **Location:** Center-docked (bottom, between tabs)
- **Action:** Open scan screen (barcode or OCR)
- **States:** Active (default), disabled (no camera permission)

### Modal Screens (non-tab)

| Screen | Trigger | Dismiss |
|--------|---------|---------|
| Scan Screen | FAB, tab shortcuts | Back button, swipe |
| Product Detail | Tap scan result | Back button |
| Add Avoid Item | + in Avoid List | Cancel/Save |
| Family Profile Selector | Profile switch | Tap outside |
| Premium Upgrade | Limit reached action | Dismiss |

---

## Voice and Tone

### Brand Voice

**Supportive, not judgmental**
- ✅ "This contains ingredients on your avoid list"
- ❌ "DANGER! This product is unsafe!"

**Educational, not alarming**
- ✅ "Artificial colors may cause sensitivity in some individuals"
- ❌ "Toxic dyes! AVOID AT ALL COSTS!"

**Empowering, not overwhelming**
- ✅ "You've successfully scanned 10 products this week!"
- ❌ "Only 2% of your scans were completely safe"

### Microcopy Guidelines

| Context | Use | Avoid |
|---------|-----|-------|
| **Empty state** | "Tap + to add your first ingredient" | "No items yet" |
| **Success** | "Added to your avoid list" | "Item saved" |
| **Error** | "Couldn't connect. Check your connection" | "Network error" |
| **Loading** | "Looking up product..." | "Loading..." |
| **Limit reached** | "Upgrade for unlimited items" | "Limit exceeded" |
| **Caution state** | "Contains ingredients you may want to review" | "WARNING" |

### Accessibility Language

- Screen reader labels must describe purpose, not just content
- Safety status: "Safe - no concerns detected" not just "Safe"
- Actions: "Add [ingredient] to avoid list" not just "Add"

---

## Component Patterns

### Safety Indicator

**Purpose:** Instant visual feedback on product safety

**Behavior:**
- Displays as pill badge with icon + text
- Color + icon + text (never color alone)
- Appears on product cards, list items, detail headers

**States:**
| Status | When | Visual |
|--------|------|--------|
| Safe | No avoid list matches, no allergens | Green badge |
| Caution | Minor matches, no allergens | Yellow badge |
| Avoid | High-priority matches (allergens) | Red badge |
| Unknown | No ingredient data | Gray badge |

**Accessibility:**
- VoiceOver: "[Product name], [status], [brief explanation]"
- Reduce motion: No animated transitions

### Scan Result Card

**Purpose:** Display scanned product summary

**Layout:**
```
┌─────────────────────────────────────┐
│  [Safety]  [Product Name]    [> ]  │
│             Brand (optional)        │
└─────────────────────────────────────┘
```

**Taps:** Navigate to full product detail

**Empty State:**
- First scan: "Tap the + button to scan your first product"
- No recent: "Your recent scans will appear here"

### Avoid List Item Card

**Purpose:** Display individual avoid list entry with actions

**Layout:**
```
┌─────────────────────────────────────┐
│ [A]  Ingredient Name           [2x]│
│      Description (optional)         │
└─────────────────────────────────────┘
```

**Swipe Actions:**
- Left: Quick add to another scan (premium)
- Right: Delete (with confirmation)

**Tap:** Edit item details

### Family Profile Selector

**Purpose:** Switch between family member profiles

**Behavior:**
- Triggered from Settings or quick-access header
- Shows all profiles as horizontal scrollable list
- Selected profile gets emphasized state
- Tap to switch, tap outside to close

**Empty State:**
- Single profile: "Your profile"
- No profiles: "Add family members to personalize scans"

### Ingredient Education Card

**Purpose:** Explain why an ingredient is on the avoid list

**Layout:**
```
┌─────────────────────────────────────┐
│ ⚠  Artificial Colors               │
│                                     │
│  Common in: Candies, sodas,       │
│  processed snacks                   │
│                                     │
│  Why avoid: May cause sensitivity  │
│  in some individuals                │
│                                     │
│  [Learn more] →                     │
└─────────────────────────────────────┘
```

**Expand/Collapse:** Tap to see full health context

### Onboarding Flow

**Purpose:** Guide new users through initial setup

**Screens (4):**

1. **Welcome**
   - Headline: "Eat with confidence"
   - Subhead: "Know exactly what you're putting in your body"
   - CTA: "Get Started"

2. **Build Your Profile**
   - Headline: "What should we watch for?"
   - Checkboxes: Allergies, dietary preferences, health conditions
   - Optional: Add family members

3. **How Scanning Works**
   - Headline: "Scan barcodes in seconds"
   - Visual: Simple illustration of scanning
   - Subtext: "We check ingredients against your needs"

4. **Ready to Start**
   - Headline: "You're all set!"
   - CTA: "Try Your First Scan"

**Skip:** "Maybe Later" button available throughout

---

## State Patterns

### Loading States

**Skeleton Screens:**
- List items: Shimmer effect with rounded placeholders
- Cards: Gray blocks matching content shape
- Never show spinners for content loads > 1s

**Loading Indicators:**
- Pull to refresh: Circular progress
- Action in progress: Button shows inline spinner
- Full-screen wait: Overlay with "Working on it..."

### Error States

**Network Error:**
- Icon: Cloud with slash
- Message: "Couldn't connect. Check your internet"
- Action: "Retry" button
- Fallback: Show cached data if available

**Product Not Found:**
- Icon: Question mark
- Message: "We don't have this product yet"
- Actions: "Try another barcode", "Report this product"

**Permission Denied:**
- Icon: Camera with slash
- Message: "Camera access needed to scan"
- Action: "Open Settings"

**Empty States:**
- Always include encouragement + action
- No "No data" without a path forward

### Success States

**Immediate feedback:**
- Add to avoid list: Toast "Added ✓"
- Complete scan: Show result card with confetti (reduced motion: fade in)
- Profile saved: Brief checkmark animation

**Persisted confirmation:**
- Sync indicator in header (when cloud sync enabled)
- Usage count badge on avoid list items

---

## Interaction Primitives

### Swipe Gestures

| Element | Direction | Action |
|---------|-----------|--------|
| Scan history item | Left | Delete (confirm) |
| Avoid list item | Left | Quick add (premium) |
| Avoid list item | Right | Delete (confirm) |
| Library chip | Left | Add to avoid list |
| Any sheet | Down | Dismiss |

### Tap Targets

- Minimum 44x44pt for all interactive elements
- Buttons: 48pt height standard
- Icons: 24pt with 44pt tap area
- List items: Full height tappable

### Haptic Feedback

| Action | Type |
|--------|------|
| Scan successful | Light impact |
| Add to avoid list | Selection |
| Delete item | Light impact |
| Warning (caution) | Medium impact |
| Error | Error feedback |

### Pull to Refresh

- Available on: Home, Avoid List, Library
- Content: Refresh current view
- Indicator: SF Symbols rotating arrow

---

## Accessibility Floor

### VoiceOver Support

**Required labels:**
- All icons (scan, settings, delete, etc.)
- Safety status (include meaning)
- Navigation items
- Form inputs
- Empty states

**Announcement order:**
1. Element content
2. State (selected, disabled)
3. Action available

**Example:**
"Organic Almond Milk, Safe to eat, scanned 2 hours ago, double tap to view details"

### Dynamic Type

- Support up to Accessibility Large (175% of default)
- Layout adapts vertically (no horizontal overflow)
- Minimum tap target 44pt regardless of text size

### Contrast Requirements

- Text: Minimum 4.5:1 against background
- Large text (18pt+): Minimum 3:1
- Icons: Minimum 3:1
- Interactive elements: Maintain focus indicators

### Reduce Motion

- Respect iOS Reduce Motion setting
- Replace transitions with instant changes
- Disable parallax, scaling animations
- Use fade instead of slide for modals

### Color Independence

**Never rely on color alone:**
- ✅ Green badge + check icon + "Safe" text
- ❌ Green badge only

**Safety status always includes:**
- Color
- Icon (✓, ⚠, ✗, ?)
- Text label

### Assistive Touch

- All actions available via menu commands
- Custom gestures: None required
- Switch Control: Full label support

---

## Key Flows

### Flow 1: Quick Product Scan

**Protagonist:** Maria, busy parent, in grocery aisle

**Goal:** Quickly determine if product is safe for her family

**Steps:**
1. Maria opens app (lands on Home)
2. Taps FAB (scan screen opens)
3. Points camera at barcode
4. Auto-capture recognizes product
5. Results screen shows within 2 seconds:
   - Product name
   - Safety status (large, clear)
   - Brief reason if concerning
   - "View Details" or "Back to scanning"

**Climax:** 3-second verification at the shelf

**Success Metrics:**
- Time to result: < 3 seconds
- One-tap return to scanning
- Clear verdict without reading details

---

### Flow 2: First-Time Setup

**Protagonist:** James, newly diagnosed with diabetes

**Goal:** Configure app for his dietary needs

**Steps:**
1. James downloads app, opens it
2. Sees welcome screen, taps "Get Started"
3. Selects health concerns:
   - Checks "Diabetes"
   - Optionally adds family members
4. Reviews how scanning works (skippable)
5. Ready screen, taps "Start Scanning"
6. App requests camera permission
7. Lands on Home with tutorial overlay on FAB

**Climax:** Personalized experience ready immediately

**Success Metrics:**
- Setup completed in < 2 minutes
- No confusing decisions required
- Clear path to first scan

---

### Flow 3: Building the Avoid List

**Protagonist:** Sarah, mom of three with different allergies

**Goal:** Add all family members' allergens to avoid list

**Steps:**
1. Sarah opens app, taps Avoid List tab
2. Sees empty state, taps FAB
3. Dialog opens: "Add to Avoid List"
4. Selects ingredient from library OR enters manually
5. Chooses category: Allergen, Additive, Other
6. Adds description (optional): "Son allergic to peanuts"
7. Item appears in list with usage counter (initially 0)
8. Repeats for remaining items

**Climax:** Family's critical allergens captured

**Success Metrics:**
- Add item in < 30 seconds
- Clear categorization
- Easy to review/edit later

---

### Flow 4: Family Profile Management

**Protagonist:** David, dad managing multiple family dietary needs

**Goal:** Switch context to scan for specific family member

**Steps:**
1. David taps profile icon (top of Settings)
2. Family selector opens as bottom sheet
3. Shows: David, Maria, Child 1 (peanut allergy), Child 2 (dairy allergy)
4. Taps "Child 1"
5. Active profile updates
6. Next scans reflect Child 1's avoid list

**Climax:** Context switched in 2 taps

**Success Metrics:**
- Switch in < 3 seconds
- Clear visual feedback on active profile
- Scan history tagged by context

---

### Flow 5: Educational Deep Dive

**Protagonist:** Lisa, curious about why ingredients matter

**Goal:** Learn about ingredients beyond simple safe/unsafe

**Steps:**
1. Lisa scans a product with caution-level ingredients
2. Sees yellow "Caution" badge
3. Taps "View Details"
4. Product detail shows:
   - Full ingredient list
   - Highlighted items (yellow bar)
   - Tap ingredient for explanation
5. Reads: "Artificial Yellow #5 - May cause sensitivity in some individuals"
6. Taps "Learn More" for full article
7. Option to add to avoid list

**Climax:** Understanding the "why" behind the warning

**Success Metrics:**
- Education accessible without leaving scan context
- Explanations clear, not medical jargon
- Easy path to action (add to avoid list)

---

## Platform Considerations

### iOS Specifics

**Navigation Bar:**
- Use SF Symbols for icons
- Back button in standard position (top left)
- Title truncates with ellipsis
- Large titles for primary screens (Home, Settings)

**Bottom Sheets:**
- Dismissible by swipe down
- Snap points: Full, half, quarter
- Handle bar visible

**Haptics:**
- Use UIImpactFeedbackGenerator for scan feedback
- UINotificationFeedbackGenerator for success/error

**Dark Mode:**
- Full support via semantic colors
- Status bar: Inverted (white on dark)

### Offline Behavior

**Available offline:**
- View cached products
- Scan history
- Avoid list
- Add items to avoid list

**Requires connection:**
- Fetch new products
- Cloud sync
- Share functionality

**Offline indicator:**
- Subtle banner when disconnected
- Syncs automatically when reconnected

---

## Event Log (for Analytics)

Track for product improvement:

| Event | Data Points |
|-------|-------------|
| `scan_completed` | duration_ms, method (barcode/ocr), result |
| `product_viewed` | product_id, scan_id |
| `avoid_item_added` | category, from_library |
| `profile_switched` | from_profile, to_profile |
| `upgrade_tapped` | source_screen, limit_reached |
| `error_encountered` | error_type, recovery_action |

---

## Appendix: Screen Inventory

| Screen | Type | Primary Action |
|--------|------|----------------|
| Home | Tab | Quick stats, recent scans |
| Avoid List | Tab | Manage avoid list |
| Library | Tab | Browse ingredients |
| Settings | Tab | Configure app |
| Scan | Modal | Barcode/OCR capture |
| Product Detail | Modal | View product info |
| Add Avoid Item | Dialog | Create new item |
| Family Selector | Sheet | Switch context |
| Premium Upgrade | Dialog | Purchase |
| Onboarding | Flow | Initial setup |

---

*Document follows BMad UX methodology. DESIGN.md is the source of truth for visual styling.*
