# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PocketSplit is a Flutter cross-platform application for expense splitting. This is currently a new Flutter project with the default counter app template. The project targets multiple platforms: Android, iOS, Web, macOS, Linux, and Windows.

## Development Commands

### Essential Flutter Commands
- `flutter run` - Run the app in debug mode on connected device/emulator
- `flutter run --release` - Run the app in release mode
- `flutter hot reload` (or press 'r' in terminal) - Apply code changes without full restart
- `flutter hot restart` (or press 'R' in terminal) - Full app restart preserving device connection

### Building
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (requires macOS and Xcode)
- `flutter build web` - Build web version
- `flutter build macos` - Build macOS app
- `flutter build windows` - Build Windows app
- `flutter build linux` - Build Linux app

### Testing and Code Quality
- `flutter test` - Run all unit and widget tests
- `flutter analyze` - Run static analysis (linting) on Dart code
- `flutter pub get` - Install/update dependencies from pubspec.yaml
- `flutter pub upgrade` - Upgrade dependencies to latest compatible versions
- `flutter pub outdated` - Check for newer versions of dependencies

### Development Tools
- `flutter doctor` - Check Flutter installation and dependencies
- `flutter devices` - List connected devices/emulators
- `flutter logs` - View device logs

## Project Structure

This is a standard Flutter project with the following key directories:

- `lib/` - Main Dart source code (currently contains default counter app)
- `android/` - Android-specific configuration and native code
- `ios/` - iOS-specific configuration and native code  
- `web/` - Web-specific assets and configuration
- `test/` - Unit and widget tests
- Platform-specific folders: `macos/`, `windows/`, `linux/`

## Configuration Files

- `pubspec.yaml` - Project configuration, dependencies, and metadata
- `analysis_options.yaml` - Dart/Flutter linting rules (uses flutter_lints package)
- Platform-specific build files in respective platform directories

## Current State

The project is in its initial state with the default Flutter counter app. The main application logic is in `lib/main.dart` and follows standard Flutter patterns with MaterialApp, StatefulWidget, and basic state management using setState().

----------------------

# PocketSplit

## Tagline
*Simplify Sharing, Instantly Split*

## Brand Essence
PocketSplit is the go-to app for friends who want to effortlessly manage and split expenses. Whether it's a dinner out, a group trip, or shared household costs, PocketSplit makes money matters smooth and stress-free.

## Key Features Highlight
- 🔹 Instant Expense Tracking
- 🔹 Easy Bill Splitting
- 🔹 Group Expense Management
- 🔹 Real-time Calculations
- 🔹 Seamless Settlements

## Color Palette
- Primary 1: #D2FF72 (Trust, Clarity)
- Primary 2: #73EC8B (Energy, Optimism)
- Secondary 1: #54C392 (Balance, Freshness)
- Secondary 2: #15B392 (Stability, Growth)
- White: #FFFFFFFF (Simplicity)
- Black: #000000 (Elegance)
- Light Gray: #F0F0F0 (Cleanliness)
- Dark Gray: #2C3E50 (Sophistication)
- Neutral Gray: #7f8c8d (Professionalism)

## Brand Personality
- Friendly
- Transparent
- Efficient
- Approachable
- Tech-savvy

## Target Audience
- Young professionals
- College students
- Friend groups
- Travel companions
- Roommates
- Anyone who shares expenses

## Messaging Tone
Casual, helpful, and straightforward. We speak the language of friends helping friends manage money simply.

------------------
# Splitwise Clone Flutter Development Guide

## Executive Summary

This guide outlines the complete development of a Splitwise clone using Flutter, featuring free core expense-sharing functionality with premium AI-powered features. The app will leverage Flutter's cross-platform capabilities, Firebase for backend services, and modern AI APIs for premium features like smart receipt scanning, expense categorization, and predictive spending insights.

**Core Strategy**: Provide all essential expense-sharing features free while monetizing advanced AI capabilities that enhance user experience without restricting basic functionality.

## Table of Contents

1. [Project Architecture](#project-architecture)
2. [Technology Stack](#technology-stack)
3. [Core Features Overview](#core-features-overview)
4. [Database Schema](#database-schema)
5. [App Flow & Navigation](#app-flow--navigation)
6. [Detailed Page Specifications](#detailed-page-specifications)
7. [AI Premium Features](#ai-premium-features)
8. [Implementation Timeline](#implementation-timeline)
9. [Monetization Strategy](#monetization-strategy)

## Project Architecture

### Flutter Project Structure
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── services/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   ├── bloc/
│   └── theme/
└── main.dart
```

### Architecture Pattern
- **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
- **BLoC Pattern**: State management using flutter_bloc
- **Repository Pattern**: Abstract data access with multiple data sources
- **Dependency Injection**: Using get_it for service location

## Technology Stack

### Core Framework
- **Flutter 3.16+**: Cross-platform mobile development
- **Dart 3.0+**: Programming language

### State Management
- **flutter_bloc**: Reactive state management
- **equatable**: Value equality for models

### Backend Services
- **Firebase Auth**: User authentication
- **Firestore**: NoSQL database
- **Firebase Storage**: File storage for receipts
- **Cloud Functions**: Serverless backend logic
- **Firebase Analytics**: User behavior tracking

### AI Services (Premium Features)
- **Google ML Kit**: On-device text recognition
- **OpenAI GPT-4**: Expense categorization and insights
- **Google Cloud Vision API**: Advanced receipt processing
- **Custom ML Models**: Spending pattern analysis

### Additional Packages
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  get_it: ^7.6.4
  injectable: ^2.3.2
  auto_route: ^7.8.4
  flutter_localizations: ^3.16.0
  shared_preferences: ^2.2.2
  image_picker: ^1.0.4
  camera: ^0.10.5+5
  google_ml_kit: ^0.16.3
  http: ^1.1.0
  intl: ^0.18.1
  charts_flutter: ^0.12.0
  pdf: ^3.10.7
  path_provider: ^2.1.1
  connectivity_plus: ^5.0.1
  permission_handler: ^11.0.1
```

**Tip**: Use flutterfire to set up Firebase services.

## Core Features Overview

### Free Features
1. **Expense Management**
   - Add/edit/delete expenses
   - Split equally or custom amounts
   - Multiple split methods (equal, exact amounts, percentages)
   - Multi-currency support
   - Offline capability with sync

2. **Group Management**
   - Create/join groups
   - Invite members via email/link
   - Group settings and permissions
   - Member management

3. **Debt Tracking**
   - Real-time balance calculations
   - Debt simplification algorithm
   - Settlement tracking
   - Payment history

4. **Basic Analytics**
   - Monthly spending summaries
   - Category-wise breakdowns
   - Simple charts and graphs

### Premium AI Features
1. **Smart Receipt Scanning**
   - OCR with AI-powered item extraction
   - Automatic amount and tax calculation
   - Merchant and category identification
   - Multi-receipt batch processing

2. **Intelligent Categorization**
   - AI-powered expense categorization
   - Learning from user behavior
   - Custom category suggestions
   - Bulk categorization

3. **Predictive Insights**
   - Spending pattern analysis
   - Budget recommendations
   - Future expense predictions
   - Anomaly detection

4. **Natural Language Processing**
   - Voice-to-expense conversion
   - Smart expense descriptions
   - Context-aware suggestions

## Database Schema

### Firestore Collection Structure

```javascript
// Users Collection
users: {
  userId: {
    email: string,
    displayName: string,
    photoUrl: string,
    phoneNumber: string,
    createdAt: timestamp,
    lastLoginAt: timestamp,
    preferences: {
      defaultCurrency: string,
      notifications: boolean,
      theme: string
    },
    subscription: {
      plan: 'free' | 'premium',
      expiresAt: timestamp,
      features: string[]
    }
  }
}

// Groups Collection
groups: {
  groupId: {
    name: string,
    description: string,
    currency: string,
    createdBy: string,
    createdAt: timestamp,
    members: [
      {
        userId: string,
        role: 'admin' | 'member',
        joinedAt: timestamp,
        displayName: string,
        email: string
      }
    ],
    settings: {
      allowMemberInvites: boolean,
      requireApproval: boolean,
      defaultSplitMethod: string
    }
  }
}

// Expenses Collection
expenses: {
  expenseId: {
    groupId: string,
    description: string,
    amount: number,
    currency: string,
    category: string,
    createdBy: string,
    createdAt: timestamp,
    updatedAt: timestamp,
    date: timestamp,
    receipt: {
      url: string,
      filename: string,
      size: number
    },
    splits: [
      {
        userId: string,
        amount: number,
        percentage: number,
        paid: boolean
      }
    ],
    metadata: {
      location: string,
      notes: string,
      tags: string[],
      aiProcessed: boolean,
      confidence: number
    }
  }
}

// Settlements Collection
settlements: {
  settlementId: {
    groupId: string,
    fromUserId: string,
    toUserId: string,
    amount: number,
    currency: string,
    status: 'pending' | 'completed' | 'cancelled',
    createdAt: timestamp,
    completedAt: timestamp,
    method: string,
    notes: string
  }
}
```

## App Flow & Navigation

### Main Navigation Structure
```
AuthWrapper
├── LoginFlow (if not authenticated)
│   ├── WelcomeScreen
│   ├── LoginScreen
│   ├── RegisterScreen
│   └── ForgotPasswordScreen
└── MainApp (if authenticated)
    ├── BottomNavigation
    │   ├── HomeScreen (Tab 1)
    │   ├── GroupsScreen (Tab 2)
    │   ├── ExpensesScreen (Tab 3)
    │   ├── AnalyticsScreen (Tab 4)
    │   └── ProfileScreen (Tab 5)
    ├── AddExpenseFlow
    ├── GroupManagementFlow
    ├── SettingsFlow
    └── PremiumFlow
```

### Navigation Flow Diagram
```
Welcome → Login/Register → Home Dashboard
    ↓
Home Dashboard ←→ Groups ←→ Expenses ←→ Analytics ←→ Profile
    ↓
Add Expense → Camera/Gallery → AI Processing (Premium) → Split Configuration → Save
    ↓
Group Detail → Members → Settings → Invite → Expenses List
    ↓
Settlement → Payment Methods → Confirmation → History
```

## Detailed Page Specifications

### 1. Welcome Screen
**Purpose**: First impression and app introduction
**Components**:
- App logo and branding
- Feature highlights carousel
- "Get Started" CTA button
- "Already have an account?" link

**Layout**:
```dart
Column(
  children: [
    Expanded(
      flex: 2,
      child: PageView(
        children: [
          FeatureCard(
            icon: Icons.group,
            title: "Split with Friends",
            description: "Easily divide expenses among groups"
          ),
          FeatureCard(
            icon: Icons.camera_alt,
            title: "Smart Receipt Scanning",
            description: "AI-powered receipt processing (Premium)"
          ),
          FeatureCard(
            icon: Icons.analytics,
            title: "Spending Insights",
            description: "Track and analyze your expenses"
          )
        ]
      )
    ),
    Expanded(
      flex: 1,
      child: AuthButtons()
    )
  ]
)
```

### 2. Authentication Screens

#### Login Screen
**Components**:
- Email/phone input field
- Password input field
- "Remember me" checkbox
- Login button
- Social login options (Google, Apple)
- "Forgot password?" link
- "Create account" link

**Validation**:
- Email format validation
- Password strength requirements
- Real-time error display

#### Register Screen
**Components**:
- Full name input
- Email input
- Phone number input (optional)
- Password input with strength meter
- Confirm password input
- Terms of service checkbox
- Register button
- Social registration options

### 3. Home Dashboard
**Purpose**: Central hub showing overview of all activities
**Components**:

**Header Section**:
- Welcome message with user name
- Total balance (amount owed/owed to you)
- Quick action buttons (Add Expense, Settle Up)

**Recent Activity Section**:
- Last 5 expenses with group names
- Settlement notifications
- Pending approvals

**Quick Stats**:
- This month's spending
- Most active group
- Upcoming settlements

**Layout Structure**:
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 200,
      flexibleSpace: BalanceCard(),
      actions: [NotificationIcon(), SettingsIcon()]
    ),
    SliverToBoxAdapter(
      child: QuickActions()
    ),
    SliverToBoxAdapter(
      child: RecentActivity()
    ),
    SliverToBoxAdapter(
      child: MonthlyStats()
    )
  ]
)
```

### 4. Groups Screen
**Purpose**: Manage all expense groups
**Components**:

**Groups List**:
- Group cards showing:
  - Group name and member count
  - Your current balance in the group
  - Last activity timestamp
  - Group avatar/image

**Floating Action Button**: Create new group

**Search/Filter**:
- Search groups by name
- Filter by active/inactive
- Sort by balance/activity

**Group Card Design**:
```dart
Card(
  child: ListTile(
    leading: CircleAvatar(
      child: Icon(Icons.group)
    ),
    title: Text(group.name),
    subtitle: Text('${group.memberCount} members'),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          balance > 0 ? '+\$${balance.abs()}' : '-\$${balance.abs()}',
          style: TextStyle(
            color: balance > 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold
          )
        ),
        Text(
          timeAgo(group.lastActivity),
          style: TextStyle(fontSize: 12)
        )
      ]
    ),
    onTap: () => navigateToGroupDetail(group.id)
  )
)
```

### 5. Group Detail Screen
**Purpose**: Manage specific group activities and settings

**App Bar**:
- Group name
- Member avatars
- Options menu (Edit, Leave, Settings)

**Tab Structure**:
1. **Expenses Tab**:
   - Chronological list of all expenses
   - Filter by date/category/member
   - Add expense FAB

2. **Balances Tab**:
   - Who owes whom matrix
   - Simplified debts view
   - Settle up buttons

3. **Members Tab**:
   - Member list with roles
   - Add member button
   - Individual balance with each member

**Expense List Item**:
```dart
Card(
  child: ListTile(
    leading: CategoryIcon(expense.category),
    title: Text(expense.description),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paid by ${expense.paidBy}'),
        Text(DateFormat.yMd().format(expense.date))
      ]
    ),
    trailing: Column(
      children: [
        Text(
          '\$${expense.amount}',
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        Text(
          'You owe \$${expense.yourShare}',
          style: TextStyle(fontSize: 12)
        )
      ]
    )
  )
)
```

### 6. Add Expense Screen
**Purpose**: Create new expenses with multiple input methods

**Screen Structure**:
1. **Input Method Selection**:
   - Manual entry
   - Camera capture
   - Gallery selection
   - Voice input (Premium)

2. **Expense Details Form**:
   - Description input
   - Amount input with currency selector
   - Category picker
   - Date picker
   - Group selector

3. **Split Configuration**:
   - Split method selector (Equal, Exact, Percentage)
   - Member selection with amounts
   - Who paid selector

4. **Receipt Attachment** (Optional):
   - Image preview
   - AI processing indicator (Premium)
   - Manual entry fallback

**Split Methods UI**:
```dart
Column(
  children: [
    SegmentedButton(
      segments: [
        ButtonSegment(value: 'equal', label: Text('Equal')),
        ButtonSegment(value: 'exact', label: Text('Exact')),
        ButtonSegment(value: 'percentage', label: Text('%'))
      ],
      selected: {splitMethod},
      onSelectionChanged: (method) => setSplitMethod(method.first)
    ),
    Expanded(
      child: ListView.builder(
        itemCount: selectedMembers.length,
        itemBuilder: (context, index) {
          return MemberSplitTile(
            member: selectedMembers[index],
            amount: splitAmounts[index],
            splitMethod: splitMethod,
            onAmountChanged: (amount) => updateSplit(index, amount)
          );
        }
      )
    )
  ]
)
```

### 7. Camera/Receipt Scanning Screen (Premium Feature)
**Purpose**: AI-powered receipt processing

**Camera Interface**:
- Camera preview with overlay guides
- Capture button
- Flash toggle
- Gallery access
- Multiple photo mode

**Processing Screen**:
- Upload progress indicator
- AI processing animation
- Processing status messages
- Cancel option

**Review Screen**:
- Extracted data preview
- Edit capabilities for each field
- Confidence indicators
- Accept/reject AI suggestions

**AI Processing Flow**:
```dart
class ReceiptProcessor {
  Future<ProcessedReceipt> processReceipt(File image) async {
    // Step 1: OCR Text Extraction
    final extractedText = await MLKit.extractText(image);
    
    // Step 2: AI Analysis (Premium)
    final aiAnalysis = await OpenAIService.analyzeReceipt(extractedText);
    
    // Step 3: Structure Data
    return ProcessedReceipt(
      merchant: aiAnalysis.merchant,
      total: aiAnalysis.total,
      items: aiAnalysis.items,
      date: aiAnalysis.date,
      category: aiAnalysis.category,
      confidence: aiAnalysis.confidence
    );
  }
}
```

### 8. Analytics Screen
**Purpose**: Spending insights and reports

**Free Analytics**:
- Monthly spending chart
- Category breakdown pie chart
- Top expenses list
- Group spending comparison

**Premium Analytics**:
- AI-powered spending insights
- Predictive analytics
- Anomaly detection
- Custom date ranges
- Export capabilities

**Chart Components**:
```dart
Column(
  children: [
    Card(
      child: Column(
        children: [
          Text('Monthly Spending'),
          LineChart(monthlySpendingData)
        ]
      )
    ),
    Card(
      child: Column(
        children: [
          Text('Categories'),
          PieChart(categoryData)
        ]
      )
    ),
    if (isPremium) ...[
      AIInsightsCard(),
      PredictiveAnalyticsCard()
    ]
  ]
)
```

### 9. Profile Screen
**Purpose**: User settings and account management

**Profile Section**:
- User avatar with edit option
- Name and email display
- Subscription status

**Preferences**:
- Default currency
- Notification settings
- Theme selection
- Language selection

**Premium Section**:
- Subscription status
- Feature comparison
- Upgrade button
- Usage statistics

**Account Actions**:
- Export data
- Delete account
- Logout

### 10. Premium Upgrade Screen
**Purpose**: Subscription management and feature showcase

**Feature Comparison**:
- Side-by-side free vs premium features
- Benefits highlighting
- Pricing options
- User testimonials

**Subscription Options**:
- Monthly/Annual toggle
- Price display with savings
- Feature access details
- Payment methods

**Upgrade Flow**:
```dart
class PremiumUpgradeScreen extends StatefulWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FeatureComparisonTable(),
          PricingOptions(),
          TestimonialCarousel(),
          UpgradeButton()
        ]
      )
    );
  }
}
```

## AI Premium Features Implementation

### 1. Smart Receipt Scanning

**Technology Stack**:
- Google ML Kit (on-device OCR)
- OpenAI GPT-4 (receipt analysis)
- Custom trained models (merchant recognition)

**Implementation**:
```dart
class SmartReceiptScanner {
  Future<ReceiptData> scanReceipt(File imageFile) async {
    try {
      // Step 1: On-device OCR
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      // Step 2: Cloud AI Analysis
      final aiAnalysis = await _analyzeWithAI(recognizedText.text);
      
      // Step 3: Validate and structure
      return _validateAndStructure(aiAnalysis);
    } catch (e) {
      throw ReceiptProcessingException(e.toString());
    }
  }
  
  Future<AIReceiptAnalysis> _analyzeWithAI(String text) async {
    final prompt = '''
    Analyze this receipt text and extract:
    - Merchant name
    - Total amount
    - Individual items with prices
    - Date and time
    - Category (restaurant, grocery, etc.)
    - Tax amount
    
    Receipt text: $text
    
    Return structured JSON response.
    ''';
    
    final response = await OpenAIService.complete(prompt);
    return AIReceiptAnalysis.fromJson(jsonDecode(response));
  }
}
```

### 2. Intelligent Categorization

**Machine Learning Approach**:
- User behavior learning
- Merchant database matching
- Context-aware suggestions
- Continuous improvement

**Implementation**:
```dart
class ExpenseCategorizer {
  Future<String> categorizeExpense(ExpenseData expense) async {
    // Combine multiple signals
    final signals = CategorySignals(
      description: expense.description,
      merchant: expense.merchant,
      amount: expense.amount,
      location: expense.location,
      timeOfDay: expense.timestamp.hour,
      dayOfWeek: expense.timestamp.weekday,
      userHistory: await _getUserCategoryHistory(expense.userId)
    );
    
    // AI categorization
    final prediction = await _predictCategory(signals);
    
    // Learn from user corrections
    await _updateLearningModel(expense.userId, prediction, expense.actualCategory);
    
    return prediction.category;
  }
}
```

### 3. Predictive Analytics

**Analytics Engine**:
```dart
class PredictiveAnalytics {
  Future<SpendingPredictions> generatePredictions(String userId) async {
    final historicalData = await _getHistoricalSpending(userId);
    final seasonalPatterns = await _analyzeSeasonalPatterns(historicalData);
    final trends = await _calculateTrends(historicalData);
    
    return SpendingPredictions(
      nextMonthEstimate: _predictNextMonth(trends, seasonalPatterns),
      categoryForecasts: _predictByCategory(historicalData),
      budgetRecommendations: _generateBudgetRecommendations(trends),
      anomalyAlerts: _detectAnomalies(historicalData)
    );
  }
}
```

## Implementation Timeline

### Phase 1: Foundation (Weeks 1-4)
- Project setup and architecture
- Firebase configuration
- Authentication system
- Basic navigation structure
- User profile management

### Phase 2: Core Features (Weeks 5-10)
- Group management
- Basic expense creation
- Split calculation algorithms
- Debt tracking and balances
- Settlement functionality

### Phase 3: Enhanced UX (Weeks 11-14)
- Receipt photo capture
- Offline functionality
- Push notifications
- Data synchronization
- Basic analytics

### Phase 4: AI Integration (Weeks 15-20)
- OCR implementation
- AI service integration
- Smart categorization
- Receipt processing pipeline
- Premium feature gating

### Phase 5: Advanced Features (Weeks 21-24)
- Predictive analytics
- Advanced reporting
- Export functionality
- Performance optimization
- Testing and debugging

### Phase 6: Launch Preparation (Weeks 25-28)
- App store optimization
- Payment system integration
- Marketing materials
- Beta testing
- Final bug fixes

## Monetization Strategy

### Pricing Structure
- **Free Tier**: All core expense sharing features
- **Premium Tier**: $4.99/month or $39.99/year
  - Smart receipt scanning
  - AI categorization
  - Predictive analytics
  - Advanced reporting
  - Priority support

### Revenue Projections
- Target: 10% conversion rate from free to premium
- Average revenue per user: $40/year
- Break-even at 5,000 premium subscribers

### Key Performance Indicators
- Monthly active users
- Premium conversion rate
- Feature usage analytics
- User retention rates
- Customer lifetime value

## Technical Considerations

### Performance Optimization
- Image compression for receipts
- Lazy loading for large expense lists
- Efficient state management
- Database query optimization
- Caching strategies

### Security Measures
- End-to-end encryption for sensitive data
- Secure API communication
- User data privacy compliance
- Regular security audits
- Penetration testing

### Scalability Planning
- Horizontal database scaling
- CDN for image storage
- Load balancing
- Caching layers
- Microservices architecture consideration

This comprehensive guide provides the foundation for building a competitive Splitwise clone that leverages AI for premium features while keeping core functionality free. The Flutter implementation ensures cross-platform compatibility while the strategic focus on AI differentiates the product in a crowded market.

------------------

# Splitwise Feature Ecosystem Analysis

Splitwise faces a critical turning point as aggressive monetization strategies clash with evolving user expectations and competitive pressure. **The expense-sharing leader has transformed from a generous freemium model to subscription-focused restrictions, creating significant user backlash while expanding payment processing capabilities**. Recent changes limit free users to just 3-4 expenses daily with mandatory 10-second cooldowns, pushing users toward a $40-60 annual Pro subscription. Meanwhile, competitors offer comparable core features completely free, and the company's Tink partnership signals strategic expansion beyond expense tracking into payment facilitation.

This comprehensive analysis reveals Splitwise maintains technical leadership in debt optimization and payment integration, but faces existential challenges from user migration to free alternatives and damaged brand reputation from perceived "predatory" monetization tactics.

## Complete Splitwise feature inventory reveals stark free vs premium divide

Splitwise's feature architecture now centers on driving Pro subscriptions through strategic free tier limitations. **Free users receive core expense splitting, group management, and basic mobile/web access but face daily transaction caps and forced advertising**. The free tier includes essential functionality like unlimited groups, debt simplification algorithms, multi-currency support (100+ currencies), basic Venmo/PayPal integrations, and CSV export capabilities.

The **Splitwise Pro subscription ($40-60 annually, varying by region) unlocks unlimited daily expenses, ad-free experience, and advanced features**. Premium capabilities include OCR receipt scanning with 10GB cloud storage, spending analytics and budgeting tools, advanced search functionality, currency conversion using Open Exchange Rates, and early access to beta features. US subscribers additionally gain credit/debit card connection for automatic expense import and enhanced banking integrations.

Platform differences create interesting trade-offs between mobile and web experiences. Mobile apps excel in receipt scanning, push notifications, offline functionality, and native payment integrations, while the web platform offers superior expense management capabilities, better search functionality, and more robust data export options. However, **iPad users face significant limitations with no split-screen support and poor tablet optimization**.

Recent 2024 developments focus heavily on payment processing expansion. The Tink partnership launched "Pay by Bank" functionality in the UK, enabling direct bank-to-bank transfers within Splitwise. The proprietary Splitwise Pay system (US-only) provides FDIC-insured banking services with free electronic transfers, while the limited-access Splitwise Card offers automatic expense splitting for purchases.

## User frustration centers on monetization strategy and missing functionality gaps

The most significant user complaints stem from **recent monetization changes that transformed previously free core functionality into subscription requirements**. Daily expense limits of 3-4 transactions create unusable conditions for travel groups and regular users, while 10-second forced cooldowns with mandatory ad viewing generate widespread frustration. Users consistently describe these restrictions as "predatory" and "unusable," leading to active migration toward competitors.

**Receipt scanning limitations represent the second-most criticized functionality gap**. Users cannot scan receipts from existing photos in their gallery, requiring new pictures through the app exclusively. Digital receipts, PDFs, and email attachments remain unsupported, while itemization accuracy requires frequent manual corrections. The web platform lacks receipt scanning entirely, forcing users to mobile apps for this premium feature.

Geographic payment limitations create significant user pain points. Current integrations only support US (Venmo, PayPal, Splitwise Pay) and India (Paytm) markets, leaving European, Australian, and other regional users without direct settlement options. Users frequently request UPI integration for India, Interac e-Transfer for Canada, and various European payment systems.

Advanced splitting functionality gaps include missing custom default ratios for couples and roommates, limited per-item percentage customization beyond 50/50 splits, and poor handling of unit-based splitting where people consume different quantities. Users consistently request "bank" functionality allowing one person to collect payments and redistribute, automated debt reminders, and better group templates for recurring scenarios.

**Platform optimization issues particularly affect iPad users, who lack split-screen multitasking support and proper tablet interface scaling**. Cross-platform feature inconsistencies create confusion, while poor app switching integration causes users to lose progress when accessing calculators or other tools mid-transaction.

## Integration ecosystem shows strong foundation with expansion opportunities

Splitwise maintains a robust integration landscape centered on payment processing and automation platforms. **Current payment integrations include PayPal (global), Venmo (US), Paytm (India), and the new Tink Open Banking partnership (UK, expanding to Europe)**. The proprietary Splitwise Pay system provides direct bank account linking with FDIC insurance for US residents, while automation platforms like Zapier (8,000+ apps), Integrately (1,200+ apps), and Make enable extensive workflow integrations.

The **public REST API following OpenAPI v3 specifications enables third-party development**, though conservative rate limits restrict commercial applications. Community-built SDKs exist for JavaScript, Python, Dart, and PHP, while enterprise API options serve large-scale implementations. Popular integrations include YNAB synchronization through multiple community solutions, QuickBooks Online automation via Zapier, and Wave Accounting connections through Make platform.

High-priority integration opportunities include **Zelle for US bank-to-bank transfers, enhanced YNAB integration for budgeting workflows, and Plaid banking APIs for automatic expense detection**. International expansion possibilities encompass UPI (India), PIX (Brazil), SEPA Instant (Europe), and Interac e-Transfer (Canada) for global payment coverage.

Advanced integration potential exists with modern corporate cards (Ramp, Brex), buy-now-pay-later platforms (Klarna, Afterpay), and enhanced accounting software beyond current QuickBooks Online support. **Banking API integrations through Plaid could enable automatic expense detection from transaction data**, significantly reducing manual entry requirements. Cryptocurrency platforms and neobank partnerships represent emerging opportunities, while Apple Pay/Google Pay integration could streamline mobile settlement experiences.

The existing integration ecosystem demonstrates strong technical capabilities, but geographic limitations and API rate restrictions constrain expansion potential. Enhanced banking partnerships and international payment platform integrations represent the highest-impact opportunities for user experience improvement and global market expansion.

## Competitive landscape reveals Splitwise's premium position under siege

Splitwise faces intense competitive pressure from both feature-rich alternatives and completely free solutions. **Primary competitors include Settle Up (superior offline capabilities and multi-currency handling), Tricount (completely free with travel optimization), Splid (permanently free with no registration required), and Splitser (free with direct Splitwise import functionality)**. Secondary threats emerge from Expensify Split (enterprise-grade features), SplitMyExpenses (modern UX with AI features), and open-source alternatives like Spliit and SplitPro.

**Head-to-head comparison reveals Splitwise's unique strengths in debt simplification algorithms and integrated payment processing**, but significant disadvantages in pricing and feature accessibility. While Splitwise restricts basic functionality behind subscription walls, competitors offer unlimited expense entry, multi-currency support, and offline functionality completely free. Settle Up provides superior weight-based splitting with default ratios, Tricount excels in travel scenarios with automatic currency conversion, and Splid eliminates registration barriers entirely.

Splitwise's **key differentiators include the most sophisticated debt triangle resolution algorithm, comprehensive payment ecosystem integration, credit card linking for automatic expense import, and enterprise-grade features like OCR receipt scanning**. However, recent monetization changes have significantly undermined these advantages by creating friction in basic usage scenarios.

Competitive positioning analysis reveals **Splitwise occupying the premium feature leader segment while losing ground in travel-focused and completely free market segments**. User sentiment has shifted dramatically negative, with active switching campaigns by competitors and "migration tool" development specifically targeting dissatisfied Splitwise users. The $40-60 annual subscription cost significantly exceeds competitor pricing, while core features like multi-currency support remain free elsewhere.

## Strategic implications point toward payment processing pivot

The research reveals **Splitwise's strategic evolution from expense tracking toward payment facilitation and financial services**. The Tink partnership, Splitwise Pay launch, and planned Splitwise Card represent significant expansion beyond traditional expense sharing into direct payment processing and banking services. This diversification strategy aims to generate transaction fee revenue streams while differentiating from free alternatives.

However, the aggressive monetization approach has created substantial user retention risks and competitive vulnerabilities. **Open-source alternatives and completely free competitors are successfully capitalizing on user frustration**, while Splitwise's brand reputation suffers from perceived "corporate greed." The company faces a critical balance between revenue generation and user experience that will determine long-term market position.

Success metrics for Splitwise's strategic pivot will depend on **payment processing adoption rates, international expansion of banking partnerships, and ability to retain core user base despite subscription friction**. The comprehensive feature ecosystem provides strong technical capabilities, but execution of the payment processing strategy while addressing user experience gaps will determine whether Splitwise maintains market leadership or faces continued user migration to increasingly capable free alternatives.

## Conclusion

Splitwise maintains technical leadership in expense sharing with sophisticated debt algorithms and expanding payment capabilities, but faces existential challenges from monetization strategy backlash and competitive pressure. The comprehensive feature analysis reveals a mature platform with strong integration potential, yet critical gaps in user experience and pricing strategy that competitors are successfully exploiting. The company's strategic pivot toward payment processing may provide new revenue streams, but success depends on balancing subscription revenue with user retention in an increasingly competitive landscape dominated by free alternatives.

------------------

# PocketSplit Development Todo List

## Phase 1: Firebase Authentication & Welcome Pages

### 🔄 Feature 1.1: Firebase Configuration & Authentication Setup
**Status**: In Progress
**Priority**: High
**Description**: Set up Firebase project, add dependencies, configure Google Sign-In service
**Tasks**:
- [ ] Add Firebase dependencies to pubspec.yaml
- [ ] Configure Firebase project and add configuration files
- [ ] Set up Google Sign-In authentication
- [ ] Create authentication service structure
- [ ] Test Firebase connection

### ⏳ Feature 1.2: Welcome Screen
**Status**: Pending
**Priority**: High  
**Description**: Create welcome/onboarding screen with PocketSplit branding
**Tasks**:
- [ ] Design welcome screen layout
- [ ] Add feature highlight carousel
- [ ] Implement PocketSplit brand colors and theme
- [ ] Add navigation to authentication screens
- [ ] Test welcome screen UI and navigation

### ⏳ Feature 1.3: Google Sign-In Registration/Login
**Status**: Pending
**Priority**: High
**Description**: Implement complete Google authentication flow
**Tasks**:
- [ ] Create registration screen with Google Sign-In
- [ ] Create login screen with Google Sign-In
- [ ] Handle authentication states and errors
- [ ] Implement user profile creation flow
- [ ] Test complete authentication flow

### ⏳ Feature 1.4: Authentication State Management
**Status**: Pending
**Priority**: High
**Description**: Implement BLoC pattern for authentication state handling
**Tasks**:
- [ ] Create authentication BLoC
- [ ] Implement auth wrapper for state management
- [ ] Add automatic login persistence
- [ ] Implement logout functionality
- [ ] Test authentication state management

### ⏳ Feature 1.5: Basic User Profile Setup
**Status**: Pending
**Priority**: High
**Description**: Create user profile setup and Firestore integration
**Tasks**:
- [ ] Create user profile screen
- [ ] Implement user data storage in Firestore
- [ ] Add basic navigation structure
- [ ] Handle user preferences
- [ ] Test profile creation and data persistence

## Future Phases (Planned)

### Phase 2: Core App Structure
- Home Dashboard
- Basic Navigation Structure
- User Profile Management

### Phase 3: Group Management
- Create/Join Groups
- Group Member Management
- Basic Group Settings

### Phase 4: Expense Management
- Add/Edit/Delete Expenses
- Basic Split Calculations
- Expense Categories

### Phase 5: Advanced Features
- Receipt Scanning (Premium)
- Analytics Dashboard
- Settlement System

## Completion Legend
- 🔄 In Progress
- ⏳ Pending
- ✅ Completed
- ❌ Blocked/Issues

## Notes
- Each feature includes a testing break for user validation
- Features are developed incrementally with immediate testing
- Architecture follows clean code principles with BLoC pattern
- Firebase backend integration throughout all features
- This project is only for ios and android platforms
- Ensure all features are responsive and optimized for both platforms