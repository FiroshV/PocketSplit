# PocketSplit Phase 1 & 2 Implementation Guide

## Current Architecture Overview

### Existing Structure
```
lib/
├── core/
│   ├── services/auth_service.dart (✅ Complete)
│   ├── theme/app_theme.dart (✅ Complete)
│   ├── di/service_locator.dart (✅ Complete)
│   └── constants/currencies.dart (✅ Complete)
├── data/
│   ├── repositories/ (✅ Firebase repos implemented)
│   └── models/ (✅ User, Group, Expense models)
├── domain/
│   ├── entities/ (✅ Core entities defined)
│   └── usecases/ (✅ Basic usecases)
├── presentation/
│   ├── pages/
│   │   ├── auth/sign_in_screen.dart (✅ Complete)
│   │   ├── main/main_app_screen.dart (✅ Navigation only)
│   │   ├── main/groups_page.dart (✅ Basic implementation)
│   │   ├── main/activity_page.dart (❌ Placeholder only)
│   │   ├── main/friends_page.dart (❓ Unknown state)
│   │   └── main/account_page.dart (✅ Basic profile)
│   └── bloc/ (⚠️ Partial - only group and user_settings)
└── main.dart (✅ Firebase initialized, goes to SignInScreen)
```

---

## PHASE 1: Core UX Foundation

### 1. Welcome/Onboarding Screen Implementation

#### Current State
- **Missing**: No welcome screen exists
- **Current Flow**: App → SignInScreen directly
- **Issue**: No app introduction or feature highlights

#### Implementation Plan

**Files to Create:**
```
lib/presentation/pages/onboarding/
├── welcome_screen.dart
├── onboarding_page.dart
└── widgets/
    ├── feature_highlight_card.dart
    └── page_indicator.dart
```

**Changes Required:**
```dart
// main.dart - UPDATE
class PocketSplitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketSplit',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(), // CHANGED: from SignInScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
```

**New Components:**

1. **WelcomeScreen** (`lib/presentation/pages/onboarding/welcome_screen.dart`)
   - Hero section with PocketSplit logo
   - Feature highlights carousel (3-4 slides)
   - "Get Started" button → SignInScreen
   - "Learn More" button → OnboardingPage

2. **OnboardingPage** (`lib/presentation/pages/onboarding/onboarding_page.dart`)
   - PageView with 4 feature highlight screens
   - Page indicators
   - Skip/Next navigation
   - Final screen with sign-in CTA

3. **FeatureHighlightCard** (`lib/presentation/pages/onboarding/widgets/feature_highlight_card.dart`)
   - Reusable card component
   - Icon, title, description layout
   - Consistent styling

#### Manual Testing Flow

**Test Case 1.1: Welcome Screen Display**
```
1. Launch app
2. Verify welcome screen appears first
3. Check elements present:
   - PocketSplit logo/icon
   - App name: "PocketSplit"
   - Tagline: "Simplify Sharing, Instantly Split"
   - "Get Started" button
   - "Learn More" button
Expected: Clean, branded welcome interface
```

**Test Case 1.2: Feature Highlights Carousel**
```
1. From welcome screen, tap "Learn More"
2. Verify onboarding screens appear
3. Swipe through 4 feature screens:
   Screen 1: "Split Expenses Easily" + split bills icon
   Screen 2: "Track Group Spending" + groups icon  
   Screen 3: "Settle Up Instantly" + payment icon
   Screen 4: "Manage Friends & Groups" + friends icon
4. Test navigation:
   - Swipe left/right between screens
   - Tap page indicators
   - "Skip" button works from any screen
   - "Next" button advances screens
   - "Get Started" appears on final screen
Expected: Smooth carousel, proper navigation, clear feature presentation
```

**Test Case 1.3: Navigation Flow**
```
1. Welcome → "Get Started" → SignInScreen
2. Welcome → "Learn More" → Onboarding → "Get Started" → SignInScreen  
3. Welcome → "Learn More" → Onboarding → "Skip" → SignInScreen
Expected: Proper screen transitions, no navigation errors
```

---

### 2. Authentication BLoC Implementation

#### Current State
- **Issue**: Auth handled directly in SignInScreen widget
- **Missing**: Proper state management, auth state wrapper
- **Current**: Direct AuthService calls in UI

#### Implementation Plan

**Files to Create:**
```
lib/presentation/bloc/auth/
├── auth_bloc.dart
├── auth_event.dart
├── auth_state.dart
└── auth_wrapper.dart
```

**Changes Required:**
```dart
// main.dart - UPDATE
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => AuthBloc(getIt<AuthService>()),
    child: MaterialApp(
      title: 'PocketSplit',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(), // CHANGED: from WelcomeScreen
      debugShowCheckedModeBanner: false,
    ),
  );
}
```

**New Components:**

1. **AuthBloc** - Manages authentication states
2. **AuthWrapper** - Decides between Welcome/SignIn/MainApp based on auth state
3. **Updated SignInScreen** - Uses BLoC instead of direct service calls

#### Manual Testing Flow

**Test Case 2.1: Fresh Install Flow**
```
1. Fresh app install/clear data
2. Launch app
Expected: WelcomeScreen appears (unauthenticated state)

3. Complete sign-in process
Expected: Navigate to MainAppScreen, auth state persisted
```

**Test Case 2.2: Returning User Flow**
```
1. User previously signed in, app backgrounded
2. Relaunch app
Expected: Direct navigation to MainAppScreen (authenticated state)

3. Sign out from account settings
Expected: Return to WelcomeScreen
```

**Test Case 2.3: Auth State Management**
```
1. Sign in with Google
2. Verify AuthBloc states:
   - Initial: AuthInitial
   - Loading: AuthLoading  
   - Success: AuthAuthenticated
   - Error: AuthError (test with airplane mode)
Expected: Proper state transitions, loading indicators, error handling
```

---

### 3. Home Dashboard Implementation

#### Current State
- **Missing**: No central dashboard after sign-in
- **Current**: MainAppScreen shows bottom navigation tabs only
- **Issue**: No overview of user's financial state

#### Implementation Plan

**Files to Create:**
```
lib/presentation/pages/main/
├── home_page.dart (NEW - replace groups as default)
└── widgets/
    ├── balance_summary_card.dart
    ├── quick_actions_row.dart
    ├── recent_activity_list.dart
    └── monthly_stats_card.dart
```

**Changes Required:**
```dart
// main_app_screen.dart - UPDATE
final List<Widget> _pages = [
  const HomePage(),        // NEW: Home dashboard
  const GroupsPage(),      // MOVED: from index 0 to 1  
  const FriendsPage(),     // index 2
  const ActivityPage(),    // index 3
  const AccountPage(),     // index 4
];

// Update bottom navigation items accordingly
```

**New Components:**

1. **HomePage** - Main dashboard with 4 sections:
   - Balance summary (total owed/owing)
   - Quick actions (Add Expense, Settle Up, Create Group)
   - Recent activity (last 5 transactions)
   - Monthly spending stats

2. **Balance Summary** - Shows net balance with visual indicators
3. **Quick Actions** - FAB-style action buttons
4. **Recent Activity** - List of recent expenses/settlements
5. **Monthly Stats** - Simple spending overview

#### Manual Testing Flow

**Test Case 3.1: Home Dashboard Display**
```
1. Sign in successfully
2. Verify Home tab is selected by default
3. Check dashboard sections present:
   - Balance summary card at top
   - Quick actions row (3 buttons)
   - "Recent Activity" section header
   - "This Month" stats section
Expected: Complete dashboard layout, branded styling
```

**Test Case 3.2: Balance Summary Accuracy**
```
Test Setup: Create test data
- Group: "Test Group" with 2 members
- Expense 1: $100 dinner, split equally ($50 each, you paid)
- Expense 2: $60 groceries, split equally ($30 each, friend paid)

Expected Balance: You are owed $20 ($50-$30)

1. Navigate to Home dashboard
2. Check balance summary displays:
   - "You are owed: $20.00" in green
   - Or "You owe: $X.XX" in red for negative balance
   - Or "All settled up!" for $0 balance
Expected: Accurate balance calculation and color coding
```

**Test Case 3.3: Quick Actions Functionality**
```
1. Tap "Add Expense" quick action
Expected: Navigate to expense creation flow

2. Tap "Create Group" quick action  
Expected: Navigate to group creation page

3. Tap "Settle Up" quick action
Expected: Navigate to settlement/payment screen (may be placeholder)
```

**Test Case 3.4: Recent Activity Display**
```
Test Setup: Create 3+ expenses in different groups

1. Check recent activity section shows:
   - Last 5 expenses chronologically
   - Expense description
   - Amount and your share
   - Group name
   - Time ago ("2 hours ago", "Yesterday")
   
2. Tap on activity item
Expected: Navigate to expense detail or group detail
```

---

### 4. Assets Integration Setup

#### Current State
- **Issue**: Assets folder exists but not configured in pubspec.yaml
- **Missing**: Google logo, app icons, brand images
- **Problem**: Image.asset calls fail with error fallbacks

#### Implementation Plan

**Files to Update:**
```
pubspec.yaml - ADD assets section
assets/images/ - ADD required images
assets/icons/ - ADD app icons
```

**Required Assets:**
```
assets/
├── images/
│   ├── google_logo.png
│   ├── pocketsplit_logo.png
│   ├── welcome_hero.png
│   └── onboarding/
│       ├── feature_1.png (split expenses)
│       ├── feature_2.png (track groups)  
│       ├── feature_3.png (settle up)
│       └── feature_4.png (manage friends)
├── icons/
│   ├── app_icon.png (1024x1024)
│   └── adaptive_icon_foreground.png
└── fonts/
    └── [custom fonts if needed]
```

**pubspec.yaml Changes:**
```yaml
flutter:
  uses-material-design: true
  
  # ADD THIS SECTION:
  assets:
    - assets/images/
    - assets/images/onboarding/
    - assets/icons/
    - assets/lottie/
  
  # OPTIONAL - if custom fonts needed:
  # fonts:
  #   - family: PocketSplitCustom
  #     fonts:
  #       - asset: assets/fonts/custom_font.ttf
```

#### Manual Testing Flow

**Test Case 4.1: Google Logo Display**
```
1. Navigate to SignInScreen
2. Verify Google logo appears in sign-in button
3. If logo missing, verify fallback icon appears
Expected: Proper Google branding or clean fallback
```

**Test Case 4.2: App Branding Assets**
```
1. Check WelcomeScreen displays:
   - PocketSplit logo/icon properly
   - Welcome hero image (if added)
   
2. Check OnboardingScreens display:
   - Feature highlight images
   - Consistent branding elements
Expected: Professional visual presentation, no broken image icons
```

**Test Case 4.3: Asset Loading Performance**
```
1. Navigate between screens with images
2. Check for:
   - Fast image loading
   - No flickering or layout shifts
   - Proper image sizing and aspect ratios
Expected: Smooth visual experience
```

---

## PHASE 2: Core Functionality

### 5. Activity Page Implementation

#### Current State
- **Issue**: ActivityPage is placeholder with empty state
- **Missing**: Real expense history, activity feed
- **Current**: Static "Coming soon" message

#### Implementation Plan

**Files to Update:**
```
lib/presentation/pages/main/activity_page.dart - COMPLETE REWRITE
```

**Files to Create:**
```
lib/presentation/widgets/
├── expense_list_item.dart
├── activity_filter_chips.dart
└── empty_state_widget.dart

lib/presentation/bloc/activity/
├── activity_bloc.dart
├── activity_event.dart  
└── activity_state.dart
```

**New Components:**

1. **ActivityBloc** - Manages expense history and filtering
2. **ExpenseListItem** - Reusable expense display widget
3. **ActivityFilterChips** - Filter by date/group/category
4. **Updated ActivityPage** - Real expense history with search/filter

#### Manual Testing Flow

**Test Case 5.1: Activity Feed Display**
```
Test Setup: Create test expenses across 2+ groups
- Group A: $50 dinner (today)
- Group A: $30 coffee (yesterday) 
- Group B: $100 groceries (2 days ago)

1. Navigate to Activity tab
2. Verify expense list shows:
   - All expenses chronologically (newest first)
   - Expense description and amount
   - Group name
   - Your share amount
   - Date/time information
Expected: Complete expense history in timeline format
```

**Test Case 5.2: Empty State Handling**
```
1. Fresh user with no expenses
2. Navigate to Activity tab
Expected: Empty state with message "No expenses yet" and "Add your first expense" CTA
```

**Test Case 5.3: Activity Filtering**
```
Test Setup: Multiple expenses in different categories and groups

1. Test date filters:
   - "Today" - shows only today's expenses
   - "This Week" - shows last 7 days
   - "This Month" - shows current month
   
2. Test group filter:
   - Select specific group
   - Shows only expenses from that group
   
3. Test category filter:
   - Select "Food & Dining"
   - Shows only restaurant/food expenses
Expected: Accurate filtering, clear filter indicators
```

**Test Case 5.4: Search Functionality**
```
1. Enter search term in activity search bar
2. Test searches:
   - "dinner" - finds expenses with dinner in description
   - "50" - finds expenses with $50 amount
   - Group name - finds expenses from that group
Expected: Real-time search results, highlight matches
```

---

### 6. Friends Management System

#### Current State
- **Unknown**: FriendsPage implementation status
- **Available**: flutter_contacts dependency already added
- **Missing**: Contact permissions, friend invitations

#### Implementation Plan

**Files to Analyze/Update:**
```
lib/presentation/pages/main/friends_page.dart - UPDATE
```

**Files to Create:**
```
lib/presentation/bloc/friends/
├── friends_bloc.dart
├── friends_event.dart
└── friends_state.dart

lib/presentation/widgets/
├── friend_list_item.dart
├── contact_permission_widget.dart
└── invite_friend_sheet.dart

lib/domain/entities/
└── friend.dart

lib/data/repositories/
└── friends_repository.dart
```

**New Components:**

1. **FriendsBloc** - Manages friend list and contact integration
2. **ContactPermissionWidget** - Handles contact access request
3. **InviteFriendSheet** - Bottom sheet for friend invitations
4. **FriendListItem** - Individual friend display with balance info

#### Manual Testing Flow

**Test Case 6.1: Contact Permissions**
```
1. Navigate to Friends tab (first time)
2. Verify contact permission request appears
3. Test permission flows:
   - Grant permission: Loads contacts successfully
   - Deny permission: Shows manual invite option
   - Previously denied: Shows settings redirect
Expected: Proper permission handling, clear user guidance
```

**Test Case 6.2: Friend List Display**
```
Test Setup: Add 2+ friends to groups

1. Navigate to Friends tab
2. Verify friend list shows:
   - Friend name and email/phone
   - Profile picture or initials
   - Net balance with each friend
   - Color coding (green for owed to you, red for you owe)
Expected: Complete friend overview with balance information
```

**Test Case 6.3: Add Friend Functionality**
```
1. Tap "Add Friend" FAB
2. Test invitation methods:
   - From contacts: Select contact, send invite
   - Manual entry: Enter email/phone, send invite
   - Share invite link: Generate shareable link
Expected: Multiple invitation options, proper sharing flow
```

**Test Case 6.4: Friend Balance Calculation**
```
Test Setup:
- Friend John in Group A: You owe John $25
- Friend John in Group B: John owes you $40  
- Net: John owes you $15

1. Navigate to Friends tab
2. Find John in friend list
3. Verify balance shows: "Owes you $15.00" in green
Expected: Accurate cross-group balance calculation
```

---

### 7. Settlement System Implementation

#### Current State
- **Missing**: No settlement/payment functionality
- **Current**: Basic group management without debt resolution
- **Issue**: No "who owes whom" calculations

#### Implementation Plan

**Files to Create:**
```
lib/presentation/pages/settlements/
├── settlements_page.dart
├── settle_up_page.dart
└── payment_methods_page.dart

lib/presentation/widgets/
├── debt_summary_card.dart
├── settlement_suggestion_item.dart
└── payment_confirmation_sheet.dart

lib/domain/entities/
├── settlement.dart
└── debt_calculation.dart

lib/core/utils/
└── debt_optimizer.dart
```

**New Components:**

1. **SettlementsPage** - Overview of all debts and settlements
2. **DebtOptimizer** - Algorithm to minimize transaction count
3. **SettleUpPage** - Initiate settlement with specific person
4. **PaymentMethodsPage** - Configure payment options

#### Manual Testing Flow

**Test Case 7.1: Debt Calculation Accuracy**
```
Test Setup: Complex group with multiple expenses
Group: Alice, Bob, Charlie
- Expense 1: $120 dinner, Alice paid, split equally ($40 each)
- Expense 2: $60 coffee, Bob paid, split equally ($20 each)  
- Expense 3: $90 groceries, Charlie paid, split equally ($30 each)

Expected Net Balances:
- Alice: Paid $120, owes $50 → Net: +$70 (owed to Alice)
- Bob: Paid $60, owes $70 → Net: -$10 (Bob owes)
- Charlie: Paid $90, owes $60 → Net: +$30 (owed to Charlie)

1. Navigate to Settlements page
2. Verify debt calculations match expected values
3. Check optimization suggests: Bob pays Alice $10
Expected: Accurate math, optimized settlement suggestions
```

**Test Case 7.2: Settlement Suggestions**
```
1. Open Settlements page with active debts
2. Verify suggestions section shows:
   - Minimal number of transactions to settle all debts
   - Clear "X owes Y $Z" format
   - "Settle Up" buttons for each suggestion
Expected: Clear settlement recommendations, actionable buttons
```

**Test Case 7.3: Settlement Flow**
```
1. Tap "Settle Up" on a debt suggestion
2. Follow settlement process:
   - Confirm amount and people involved
   - Select payment method (Venmo/PayPal/Manual)
   - Add optional note
   - Mark as paid
3. Verify debt is removed from calculations
Expected: Complete settlement workflow, debt properly cleared
```

**Test Case 7.4: Cross-Group Debt Consolidation**
```
Test Setup: Same people in multiple groups with different debts

1. Navigate to Settlements page
2. Verify debts are consolidated across all groups
3. Check "View by Group" option shows group-specific debts
4. Check "View by Person" shows consolidated person debts
Expected: Accurate cross-group debt calculations
```

---

## Testing Environment Setup

### Required Test Data Creation
```
Test User: your.email@gmail.com
Test Groups:
1. "Weekend Trip" - 3 members (you + 2 mock members)
2. "Roommates" - 2 members (you + 1 mock member)

Test Expenses:
1. Weekend Trip: $150 hotel (you paid, split 3 ways)
2. Weekend Trip: $90 dinner (mock member paid, split 3 ways)
3. Roommates: $200 utilities (mock member paid, split equally)
4. Roommates: $80 groceries (you paid, split equally)
```

### Manual Testing Checklist
- [ ] All Phase 1 test cases pass
- [ ] All Phase 2 test cases pass  
- [ ] Cross-feature integration works
- [ ] No crashes or error states
- [ ] Consistent UI/UX across features
- [ ] Proper loading states and error handling
- [ ] Data persistence across app restarts

---

## Implementation Priority Order

### Phase 1 (Foundation) - Week 1
1. **Assets Integration** - Set up pubspec.yaml and basic assets first
2. **Welcome/Onboarding Screen** - Create user-friendly entry point
3. **Authentication BLoC** - Proper state management foundation
4. **Home Dashboard** - Central user experience hub

### Phase 2 (Core Features) - Week 2
5. **Activity Page** - Real expense tracking and history
6. **Friends Management** - Social features and contact integration
7. **Settlement System** - Debt calculations and payment flows

This implementation guide provides complete specifications for building out the core PocketSplit functionality with clear testing procedures to validate each feature works correctly.