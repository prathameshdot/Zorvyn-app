<div align="center">

# 🏦 Zorvyn — Personal Finance Companion

<img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
<img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
<img src="https://img.shields.io/badge/Firebase-FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
<img src="https://img.shields.io/badge/Node.js-Backend-339933?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js"/>
<img src="https://img.shields.io/badge/SQLite-Offline_First-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite"/>

**A beautifully crafted, offline-first personal finance companion mobile app with AI-powered insights, gamification, and a claymorphic UI.**

[Features](#-features) · [Architecture](#-architecture) · [Setup](#-setup) · [Screenshots](#-screenshots) · [Tech Stack](#-tech-stack)

</div>

---

## 📋 Problem Statement

> Build a personal finance companion app that helps users understand their daily money habits in a simple and engaging way. The app should allow users to track transactions, view spending patterns, monitor simple goals, and receive useful insights in a mobile-friendly format.

**Zorvyn** goes beyond the requirements — it's a full-stack, production-ready finance companion with:
- Real backend API (60+ endpoints)
- AI-powered spending analysis & predictions
- Gamified savings challenges with XP & leaderboards
- Offline-first architecture with SQLite caching
- Push notifications via Firebase Cloud Messaging
- Dark mode with a unique claymorphic design system

---

## ✅ Assignment Requirements Completion

| # | Requirement | Status | Implementation |
|---|------------|--------|---------------|
| 1 | **Home Dashboard** | ✅ Complete | Balance card, income/expenses/savings, quick actions, recent transactions |
| 2 | **Transaction Tracking** | ✅ Complete | Full CRUD, filter by type/category, search, swipe actions, detail view |
| 3 | **Goal / Challenge Feature** | ✅ Complete | Savings goals with progress tracking + gamified challenges with XP, streaks & leaderboard |
| 4 | **Insights Screen** | ✅ Complete | 4 tabs: Overview, Financial Health score, Spending Patterns, Expense Trends |
| 5 | **Smooth Mobile UX** | ✅ Complete | iOS Cupertino design, empty/loading/error states, pull-to-refresh, smooth navigation |
| 6 | **Data Handling** | ✅ Complete | Real REST API backend + SQLite offline cache + SharedPreferences |
| 7 | **Code Structure** | ✅ Complete | Clean architecture: config/models/services/providers/screens/widgets |

### Optional Enhancements Implemented

| Enhancement | Status |
|------------|--------|
| 🌙 Dark Mode | ✅ Full dark theme with toggle |
| 🔔 Push Notifications | ✅ FCM + local notifications |
| 🤖 AI-Powered Insights | ✅ Spending analysis, predictions, budget optimization |
| 📴 Offline-First | ✅ SQLite cache + connectivity monitoring |
| 🏆 Gamification | ✅ Challenges, XP, streaks, leaderboard |
| 💡 Financial Tips | ✅ Daily tips, bookmarks, personalized advice |
| 👤 Profile Settings | ✅ Edit profile, change password, delete account |
| 📱 Onboarding | ✅ 4-page animated onboarding flow |
| ⚖️ Legal Pages | ✅ Terms, Privacy Policy, FAQ |

---

## ✨ Features

### 🏠 Home Dashboard
- Real-time balance, monthly income, expenses & savings
- Gradient hero card with financial summary
- Quick action buttons for frequent tasks
- Recent transactions feed with category icons

### 💳 Transaction Management
- Add income/expense with category, date, notes
- Full transaction history with pull-to-refresh
- Filter by type (income/expense) and category
- Detailed transaction view with edit/delete
- 13 expense categories + 8 income categories

### 🎯 Goals & Progress
- Create savings goals with target amounts & deadlines
- Visual progress bars with percentage tracking
- Add incremental progress toward goals
- Goal types: savings, expense limit, income target, savings streak

### 💰 Budget Tracking
- Set weekly/monthly budgets per category
- Visual usage bars (green → yellow → red)
- Overspend alerts with clear indicators
- Budget summary overview

### 📊 Insights (4 Tabs)
- **Overview**: Total income/expense, net amount, top spending categories
- **Financial Health**: Score (0-100), grade, actionable metrics
- **Spending Patterns**: Daily averages, most active day/category, day-of-week chart
- **Expense Trends**: Monthly trend analysis with visual progress bars

### 🤖 AI Financial Advisor
- Chat-based interface with conversation history
- **Analyze Spending**: AI-powered spending breakdown & recommendations
- **Predict Expenses**: Forecasted spending with confidence scores
- **Optimize Budget**: AI suggestions to save money

### 🏆 Gamification
- **Challenges**: Join savings challenges (no-spend, save-X, etc.)
- **XP System**: Earn experience points for completing challenges
- **Streaks**: Track consecutive saving days
- **Leaderboard**: Compete with other users by XP rank

### 🔔 Notifications
- Push notifications via Firebase Cloud Messaging
- In-app notification center with mark-read/delete
- Device token auto-registration after login

### 📴 Offline-First Architecture
- SQLite caching for all GET API responses
- Automatic fallback to cached data when offline
- "You're offline" banner with real-time connectivity monitoring
- Seamless reconnection when network returns

### 🌙 Dark Mode
- Beautiful dark theme with claymorphic shadows
- Persistent toggle in settings
- System-wide theme propagation

---

## 🏗 Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point + service initialization
├── config/
│   ├── constants.dart                 # API base URL, categories, storage keys
│   ├── exceptions.dart                # Custom exception hierarchy
│   ├── router.dart                    # GoRouter configuration (25+ routes)
│   └── theme.dart                     # Light/dark themes, claymorphism helpers
├── models/                            # Data classes with JSON serialization
│   ├── user_model.dart
│   ├── transaction_model.dart
│   ├── goal_model.dart
│   ├── budget_model.dart
│   ├── insights_model.dart
│   ├── ai_model.dart
│   ├── notification_model.dart
│   ├── leaderboard_model.dart
│   ├── tip_model.dart
│   └── challenge_model.dart
├── services/                          # Platform & external integrations
│   ├── api_service.dart               # Dio HTTP client + offline caching
│   ├── local_storage_service.dart     # SharedPreferences wrapper
│   ├── database_service.dart          # SQLite cache (sqflite)
│   ├── connectivity_service.dart      # Network state monitoring
│   └── push_notification_service.dart # FCM + local notifications
├── providers/                         # Riverpod state management
│   ├── auth_provider.dart             # Auth state, login/register/profile
│   ├── dashboard_provider.dart        # Dashboard data
│   ├── transaction_provider.dart      # Transaction CRUD + summary
│   ├── goal_provider.dart             # Goal CRUD + progress
│   ├── budget_provider.dart           # Budget CRUD + summary
│   ├── insights_provider.dart         # Overview, health, patterns
│   ├── ai_provider.dart               # AI chat, analyze, predict, optimize
│   ├── notification_provider.dart     # Notification management
│   ├── leaderboard_provider.dart      # Rankings & user rank
│   ├── tips_provider.dart             # Tips, daily tips, bookmarks
│   └── challenge_provider.dart        # Challenges, XP, streaks
├── widgets/
│   └── common_widgets.dart            # 15+ reusable UI components
└── screens/                           # 24 screens organized by feature
    ├── splash_screen.dart
    ├── main_shell.dart                # Bottom navigation shell
    ├── onboarding/
    ├── auth/                          # login, register, forgot/reset password
    ├── home/                          # Dashboard
    ├── transactions/                  # List, add/edit, detail
    ├── goals/                         # List, add/edit, detail
    ├── budgets/                       # List, add/edit
    ├── insights/                      # 4-tab insights
    ├── ai/                            # Conversations, chat, AI insights
    ├── notifications/
    ├── leaderboard/
    ├── tips/                          # 3-tab tips
    ├── challenges/                    # 2-tab challenges
    ├── settings/                      # Settings, profile, help
    └── legal/                         # Terms, privacy, FAQ
```

### Architecture Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │   Home   │ │Transact. │ │ Insights │ │ AI Chat  │ │ Settings │ │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ │
│       │             │            │             │            │        │
│  ┌────┴─────────────┴────────────┴─────────────┴────────────┴────┐  │
│  │                    GoRouter (Navigation)                      │  │
│  └──────────────────────────────┬────────────────────────────────┘  │
└─────────────────────────────────┼───────────────────────────────────┘
                                  │
┌─────────────────────────────────┼───────────────────────────────────┐
│                         STATE LAYER                                 │
│  ┌──────────────────────────────┴────────────────────────────────┐  │
│  │              Riverpod (StateNotifier + FutureProvider)        │  │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐  │  │
│  │  │ Auth │ │Trans.│ │Goals │ │Budget│ │  AI  │ │Challenge │  │  │
│  │  └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └────┬─────┘  │  │
│  └─────┼────────┼────────┼────────┼────────┼──────────┼─────────┘  │
└────────┼────────┼────────┼────────┼────────┼──────────┼─────────────┘
         │        │        │        │        │          │
┌────────┼────────┼────────┼────────┼────────┼──────────┼─────────────┐
│        └────────┴────────┴────────┴────────┴──────────┘             │
│                         SERVICE LAYER                               │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │   ApiService (Dio + JWT + Offline Cache + Error Handling)    │   │
│  └───────────┬──────────────────────────────────┬───────────────┘   │
│              │                                  │                   │
│  ┌───────────┴──────────┐          ┌────────────┴───────────────┐   │
│  │  DatabaseService     │          │  ConnectivityService       │   │
│  │  (SQLite Cache)      │          │  (Network Monitoring)      │   │
│  └──────────────────────┘          └────────────────────────────┘   │
│                                                                     │
│  ┌──────────────────────┐          ┌────────────────────────────┐   │
│  │ LocalStorageService  │          │ PushNotificationService    │   │
│  │ (SharedPreferences)  │          │ (FCM + Local Notif.)      │   │
│  └──────────────────────┘          └────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         BACKEND API                                 │
│     https://zorvyn-backend-9536.onrender.com/api/v1                │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐           │
│  │ Auth │ │Trans.│ │Goals │ │Budget│ │  AI  │ │Chall.│  + more   │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘           │
│                    60+ REST Endpoints                              │
│                    Node.js + Firebase                               │
└─────────────────────────────────────────────────────────────────────┘
```

### Navigation Flow

```
                         ┌──────────┐
                         │  Splash  │
                         └────┬─────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
              ┌─────┴──────┐    ┌──────┴──────┐
              │ Onboarding │    │    Login     │
              │ (first run)│    │              │
              └─────┬──────┘    ├──────────────┤
                    │           │   Register   │
                    └───┬───────┤──────────────┤
                        │       │ Forgot Pass  │
                        │       ├──────────────┤
                        │       │ Reset Pass   │
                        │       └──────┬───────┘
                        │              │
                        └──────┬───────┘
                               │
                    ┌──────────┴──────────┐
                    │     Main Shell      │
                    │  (Bottom Nav Bar)   │
                    └──────────┬──────────┘
                               │
          ┌──────────┬────────┬┴────────┬──────────┐
          │          │        │         │          │
     ┌────┴───┐ ┌───┴───┐ ┌──┴──┐ ┌───┴───┐ ┌───┴───┐
     │  Home  │ │Trans. │ │Ins. │ │AI Chat│ │  More │
     └────┬───┘ └───┬───┘ └──┬──┘ └───┬───┘ └───┬───┘
          │         │        │        │         │
     ┌────┘    ┌────┤    4 tabs   ┌───┤    ┌────┼────────┐
     │         │    │             │   │    │    │        │
  Notif.     Add  Detail    New Chat Conv. Profile  Help
  Goals      Edit            AI Insights   Terms   Privacy
  Budgets    Filter                        FAQ     DarkMode
  Challenges                               Logout
  Tips
  Leaderboard
```

### Offline-First Data Flow

```
┌──────────┐         ┌──────────────┐         ┌──────────────┐
│  Screen  │──GET──> │  ApiService  │──HTTP──> │  Backend API │
│          │         │              │          │              │
│          │         │  ┌────────┐  │  Success │              │
│          │<─data───│  │ Cache  │<─┼──────────│              │
│          │         │  │(SQLite)│  │          │              │
│          │         │  └────┬───┘  │          └──────────────┘
│          │         │       │      │
│          │         │  On network  │
│          │<─cached─│  failure,    │
│          │  data   │  serve cache │
└──────────┘         └──────────────┘

┌──────────────────────────────────────────────────────┐
│              ConnectivityService                     │
│  Monitors network -> Shows offline banner -> Auto-   │
│  reconnects when network returns                     │
└──────────────────────────────────────────────────────┘
```

### Error Handling Architecture

```
┌───────────────┐     ┌─────────────────┐     ┌──────────────────────┐
│  DioException │────>│  ApiService     │────>│  Custom Exceptions   │
│  (raw HTTP)   │     │  _handleError() │     │                      │
└───────────────┘     └─────────────────┘     │  AppException        │
                                              │  ├─ NetworkException  │
                                              │  ├─ ServerException   │
                                              │  ├─ ValidationExcep.  │
                                              │  └─ UnauthorizedExc.  │
                                              └──────────┬───────────┘
                                                         │
                                              ┌──────────┴───────────┐
                                              │  friendlyError()     │
                                              │  Converts ANY error  │
                                              │  to user-friendly    │
                                              │  message string      │
                                              └──────────┬───────────┘
                                                         │
                                              ┌──────────┴───────────┐
                                              │  ErrorDisplay widget │
                                              │  + Retry button      │
                                              │  (no raw exceptions) │
                                              └──────────────────────┘
```

---

## 🎨 Design System

### Claymorphism
The app uses a **claymorphic design system** — a soft, tactile UI style with dual-directional shadows creating a "clay-like" feel:

```dart
// Raised clay card (convex)
BoxDecoration(
  color: surface,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(color: darkShadow, offset: Offset(4, 4), blurRadius: 12),
    BoxShadow(color: lightShadow, offset: Offset(-4, -4), blurRadius: 12),
  ],
)

// Inset clay field (concave)
BoxDecoration(
  color: background,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(color: darkShadow, offset: Offset(2, 2), blurRadius: 6, spreadRadius: -1),
    BoxShadow(color: lightShadow, offset: Offset(-2, -2), blurRadius: 6, spreadRadius: -1),
  ],
)
```

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| 🟣 Primary | `#6C63FF` | Buttons, active states, navigation |
| 🔵 Secondary | `#00D2FF` | Accent highlights |
| 🔴 Accent | `#FF6B6B` | Expenses, warnings, destructive actions |
| 🟢 Success | `#4CAF50` | Income, positive changes, goals met |
| 🟡 Warning | `#FFB74D` | Budget alerts, offline banner |
| ⚪ Background (Light) | `#F2F0F7` | App background |
| ⚫ Background (Dark) | `#121218` | Dark mode background |
| ⬜ Surface (Light) | `#FFFFFF` | Cards, sheets |
| 🔲 Surface (Dark) | `#1E1E2C` | Dark mode cards |

---

## 🛠 Tech Stack

| Category | Technology | Version |
|----------|-----------|---------|
| **Framework** | Flutter | 3.10+ |
| **Language** | Dart | 3.10+ |
| **State Management** | flutter_riverpod | 2.6.1 |
| **Navigation** | go_router | 12.1.3 |
| **HTTP Client** | dio | 5.3.4 |
| **Local Cache** | sqflite | 2.4.1 |
| **Key-Value Storage** | shared_preferences | 2.2.2 |
| **Connectivity** | connectivity_plus | 6.1.1 |
| **Push Notifications** | firebase_messaging | 15.2.6 |
| **Local Notifications** | flutter_local_notifications | 18.0.1 |
| **Permissions** | permission_handler | 11.3.1 |
| **Charts** | fl_chart / syncfusion_flutter_charts | 0.65.0 / 33.1.46 |
| **Typography** | google_fonts (Inter) | 6.1.0 |
| **JWT** | jwt_decoder | 2.0.1 |
| **Backend** | Node.js + Firebase | — |
| **Hosting** | Render.com | — |

---

## 🚀 Setup

### Prerequisites
- Flutter SDK 3.10+
- Android Studio / Xcode
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/prathameshdot/Zorvyn-app.git
cd Zorvyn-app

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build release APK
flutter build apk --release
```

### Backend API
The backend is already deployed and running at:
```
https://zorvyn-backend-9536.onrender.com/api/v1
```

No additional setup is required — the app connects to the live backend automatically.

### Firebase Configuration
- `google-services.json` is included for Android
- FCM push notifications work out of the box on Android
- iOS requires adding `GoogleService-Info.plist` (not included for security)

---

## 📱 App Screens (24 Total)

| Screen | Description |
|--------|------------|
| **Splash** | Logo + auth check with auto-redirect |
| **Onboarding** | 4-page animated introduction (shown once) |
| **Login** | Email/password with validation |
| **Register** | Name/email/password with strength checks |
| **Forgot Password** | Email-based reset token request |
| **Reset Password** | Token + new password form |
| **Home Dashboard** | Balance card, quick actions, recent transactions |
| **Transactions List** | Filterable list with type/category chips |
| **Add/Edit Transaction** | Form with amount, type toggle, category, date, notes |
| **Transaction Detail** | Full details with edit/delete actions |
| **Goals List** | Active goals with progress bars |
| **Add/Edit Goal** | Name, target, type, priority, deadline |
| **Goal Detail** | Progress hero + add progress input |
| **Budgets List** | Budget cards with usage bars |
| **Add/Edit Budget** | Category, limit, period pickers |
| **Insights** | 4 tabs: Overview, Health, Patterns, Trends |
| **AI Conversations** | Chat history with swipe-to-delete |
| **AI Chat** | Real-time chat with AI financial advisor |
| **AI Insights** | 3 tabs: Analysis, Predict, Optimize |
| **Notifications** | Notification center with mark-read/delete |
| **Leaderboard** | Top-3 podium + full rankings |
| **Tips** | 3 tabs: Daily, All Tips, Saved |
| **Challenges** | XP header + Available/My Challenges tabs |
| **Settings** | Profile, dark mode, password, help, legal, logout |
| **Profile** | Edit name & email |
| **Help & Support** | Quick links, contact, app info |
| **Terms / Privacy / FAQ** | Legal content pages |

---

## 📡 API Endpoints (60+)

<details>
<summary>Click to expand full API reference</summary>

### Authentication
| Method | Endpoint | Description |
|--------|---------|-------------|
| POST | `/auth/register` | Create account |
| POST | `/auth/login` | Login |
| POST | `/auth/logout` | Logout |
| GET | `/auth/me` | Get current user |
| PUT | `/auth/profile` | Update profile |
| POST | `/auth/change-password` | Change password |
| POST | `/auth/forgot-password` | Request reset token |
| POST | `/auth/reset-password` | Reset with token |
| POST | `/auth/refresh-token` | Refresh JWT |
| DELETE | `/auth/account` | Delete account |
| GET | `/auth/dashboard` | Dashboard summary |

### Transactions
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/transactions` | List (filter, paginate) |
| POST | `/transactions` | Create |
| GET | `/transactions/:id` | Get by ID |
| PUT | `/transactions/:id` | Update |
| DELETE | `/transactions/:id` | Delete |
| GET | `/transactions/summary` | Income/expense totals |
| GET | `/transactions/breakdown/category` | Category breakdown |
| GET | `/transactions/trends/expenses` | Expense trends |

### Goals
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/goals` | List goals |
| POST | `/goals` | Create |
| GET | `/goals/:id` | Get by ID |
| PUT | `/goals/:id` | Update |
| DELETE | `/goals/:id` | Delete |
| POST | `/goals/:id/progress` | Add progress |
| GET | `/goals/stats` | Goal statistics |

### Budgets
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/budgets` | List budgets |
| POST | `/budgets` | Create |
| PUT | `/budgets/:id` | Update |
| DELETE | `/budgets/:id` | Delete |
| GET | `/budgets/summary` | Budget summary |

### Insights
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/insights/overview` | Financial overview |
| GET | `/insights/comparison` | Period comparison |
| GET | `/insights/patterns` | Spending patterns |
| GET | `/insights/health` | Financial health score |

### AI
| Method | Endpoint | Description |
|--------|---------|-------------|
| POST | `/ai/chat` | Send message |
| GET | `/ai/chat/:id` | Get conversation |
| GET | `/ai/chats` | List conversations |
| DELETE | `/ai/chat/:id` | Delete conversation |
| POST | `/ai/analyze-spending` | AI spending analysis |
| POST | `/ai/predict` | Expense prediction |
| POST | `/ai/optimize-budget` | Budget optimization |

### Notifications
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/notifications` | List notifications |
| PUT | `/notifications/:id/read` | Mark read |
| PUT | `/notifications/read-all` | Mark all read |
| DELETE | `/notifications/:id` | Delete |
| POST | `/notifications/device-token` | Register FCM token |

### Leaderboard
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/leaderboard` | Rankings |
| GET | `/leaderboard/me` | My rank |

### Tips
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/tips` | All tips |
| GET | `/tips/daily` | Daily tips |
| GET | `/tips/advice` | Personalized advice |
| POST | `/tips/bookmark` | Bookmark tip |
| GET | `/tips/bookmarks` | My bookmarks |
| DELETE | `/tips/bookmarks/:id` | Remove bookmark |

### Challenges
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/challenges` | Available challenges |
| GET | `/challenges/me` | My challenges |
| POST | `/challenges/join` | Join challenge |
| POST | `/challenges/:id/checkin` | Daily check-in |
| POST | `/challenges/:id/abandon` | Abandon |
| GET | `/challenges/xp` | My XP |
| GET | `/challenges/streak` | Savings streak |

</details>

---

## 🧩 State Management

The app uses **Riverpod 2.x** with two patterns:

1. **StateNotifier** — For complex state with loading/error/data (transactions, goals, budgets, auth, notifications)
2. **FutureProvider** — For read-only data (dashboard, insights, leaderboard, tips, challenges)

```
┌────────────────────────────────────────────┐
│              Riverpod Providers             │
├────────────────────┬───────────────────────┤
│  StateNotifier     │  FutureProvider       │
├────────────────────┼───────────────────────┤
│  AuthNotifier      │  dashboardProvider    │
│  TransactionNotif. │  insightsOverview     │
│  GoalNotifier      │  financialHealth      │
│  BudgetNotifier    │  spendingPatterns     │
│  NotificationNot.  │  leaderboardProvider  │
│  AiChatNotifier    │  tipsProvider         │
│  ThemeModeNotif.   │  challengesProvider   │
│                    │  aiAnalyzeProvider    │
│                    │  aiPredictProvider    │
│                    │  expenseTrendsProvider│
└────────────────────┴───────────────────────┘
```

---

## 🔐 Security

- JWT-based authentication with auto-attach via Dio interceptor
- Token stored in SharedPreferences (encrypted on device)
- Session-expired auto-redirect to login
- No raw exception details exposed to users
- Input validation on all forms
- Backend CORS + rate limiting

---

## 📝 Assumptions & Design Decisions

1. **Real Backend over Mock Data** — Built a full Node.js Firebase backend (60+ endpoints) for realistic data handling instead of mocked JSON
2. **Claymorphism over Material** — Chose a unique visual style for differentiation while maintaining usability
3. **Riverpod 2.x** — Stayed on version 2 for stability (v3 has breaking changes with StateNotifier removal)
4. **Offline Cache Strategy** — GET responses cached for 24 hours; write operations require connectivity
5. **iOS-First Design Language** — Cupertino widgets + iOS navigation patterns for a polished mobile feel
6. **AI Features** — Integrated AI spending analysis/prediction as a meaningful value-add beyond basic tracking
7. **Gamification** — Added challenges + XP + leaderboard to increase engagement and encourage saving habits

---

## 👨‍💻 Developer

**Prathamesh Raut**  
📧 111975prathamesh@gmail.com  
🔗 [GitHub](https://github.com/prathameshdot)

---

## 📄 License

This project was built as an assignment for **Zorvyn FinTech Pvt. Ltd.**  
All rights reserved &copy; 2026

---

<div align="center">

Built with Flutter

</div>
