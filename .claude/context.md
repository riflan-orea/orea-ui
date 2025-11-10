# Orea UI - Flutter Web Application

## Project Overview
A Flutter web application demonstrating modern Flutter development practices, including authentication, routing, state management, and API integration.

## Tech Stack

### Core
- **Flutter**: 3.35.7
- **Dart**: 3.9.2
- **Target Platform**: Web (Chrome/Edge)

### Key Packages
- `flutter_riverpod: ^2.6.1` - State management
- `go_router: ^14.6.2` - Navigation and routing
- `shared_preferences: ^2.3.4` - Local storage (authentication tokens)
- `reactive_forms: ^17.0.1` - Form state management (similar to react-hook-form)
- `dio: ^5.4.0` - HTTP client with interceptors
- `http: ^1.1.0` - Basic HTTP client (legacy, migrating to Dio)

## Architecture

### Folder Structure
```
lib/
├── main.dart                 # App entry point
├── router/
│   └── app_router.dart       # GoRouter configuration with ShellRoute
├── providers/
│   ├── auth_provider.dart    # Authentication state
│   └── users_provider.dart   # Users state management
├── services/
│   ├── api_service.dart      # Legacy HTTP service
│   └── dio_service.dart      # Dio HTTP service with interceptors
├── repositories/
│   └── user_repository.dart  # User data repository (uses DioService)
├── models/
│   └── user.dart             # User, Company, Address, Geo models
├── pages/
│   ├── login_page.dart       # Authentication page
│   ├── dashboard_page.dart   # Main dashboard with custom widgets
│   ├── users_page.dart       # User table with API integration
│   ├── users_page_improved.dart  # Repository pattern implementation
│   └── reactive_form_page.dart   # Reactive forms demo
└── widgets/
    ├── app_layout.dart       # Common layout with header/sidebar
    ├── stat_card.dart        # Dashboard stat card component
    ├── activity_card.dart    # Activity list component
    └── chart_card.dart       # Animated bar chart component
```

### Design Patterns

#### 1. Repository Pattern (RECOMMENDED)
**Architecture Layers:**
```
UI Layer (Widget)
    ↓
State Management (Riverpod)
    ↓
Business Logic (Repository)
    ↓
Network Layer (DioService)
    ↓
HTTP Package (Dio)
```

**Files:**
- `lib/services/dio_service.dart` - Network layer with interceptors
- `lib/repositories/user_repository.dart` - Business logic
- `lib/providers/users_provider.dart` - State management
- `lib/pages/users_page_improved.dart` - UI layer

#### 2. State Management (Riverpod)
- `StateNotifierProvider` for complex state (users, auth)
- `Provider` for dependency injection (repositories)
- `Provider.family` for parameterized providers (filtering, search)

#### 3. Routing (GoRouter with ShellRoute)
- Public routes: `/login`
- Protected routes wrapped in `ShellRoute` with `AppLayout`:
  - `/dashboard`
  - `/users`
  - `/reactive-form`
- Redirect logic based on authentication state

## Authentication

### Implementation
- Credentials stored in `SharedPreferences` (localStorage equivalent)
- Demo credentials: `admin@example.com` / `password123`
- `AuthNotifier` manages login/logout state
- Route guards in `app_router.dart`

### Flow
```dart
Login → Store in SharedPreferences → Update Riverpod state → Redirect to dashboard
Logout → Clear SharedPreferences → Update state → Redirect to login
```

## API Integration

### Current Setup (Dio-based)
- **Base URL**: `https://jsonplaceholder.typicode.com`
- **Service**: `DioService` with interceptors
- **Repository**: `UserRepository` handles business logic
- **Provider**: `UsersNotifier` manages UI state

### DioService Features
1. **Interceptors**:
   - Request interceptor: Add auth tokens, log requests
   - Response interceptor: Log responses
   - Error interceptor: Handle 401 (token refresh), log errors

2. **Error Handling**:
   - Custom exceptions: `TimeoutException`, `NetworkException`, `UnauthorizedException`, etc.
   - HTTP status code mapping (400, 401, 403, 404, 500, etc.)

3. **Timeout Configuration**:
   - Connect: 10 seconds
   - Receive: 10 seconds
   - Send: 10 seconds

4. **Advanced Features**:
   - File upload with progress tracking
   - File download with progress tracking
   - Request cancellation support

## Forms

### Reactive Forms (reactive_forms package)
Similar to react-hook-form in React:

```dart
final form = FormGroup({
  'email': FormControl<String>(
    validators: [Validators.required, Validators.email],
  ),
  'password': FormControl<String>(
    validators: [Validators.required, Validators.minLength(6)],
  ),
});
```

**Features:**
- Built-in validators (required, email, minLength, pattern, etc.)
- Nested form groups
- Form state tracking (value, valid, touched, errors)
- `ReactiveValueListenableBuilder` for watching field changes

**Example**: `lib/pages/reactive_form_page.dart`

## Theming

### Material Design 3
- `useMaterial3: true`
- Color scheme: Blue primary, custom seed color
- Dark/Light mode support (configured in `ThemeData`)

### Responsive Design
Breakpoints used throughout the app:
- Small: `< 600px` (mobile)
- Medium: `600px - 1200px` (tablet)
- Large: `>= 1200px` (desktop)

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isSmallScreen = screenWidth < 600;
final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
```

## Custom Widgets

### 1. AppLayout (`lib/widgets/app_layout.dart`)
Common layout for protected routes:
- Collapsible sidebar (250px expanded, 70px collapsed)
- Header with user info and logout
- Navigation menu with active route highlighting

### 2. StatCard (`lib/widgets/stat_card.dart`)
Dashboard statistics card:
- Gradient background
- Hover effect with scale animation
- Responsive sizing
- Icon, value, label, percentage change

### 3. ChartCard (`lib/widgets/chart_card.dart`)
Animated bar chart:
- `TweenAnimationBuilder` for smooth animations
- Staggered animation (each bar animates sequentially)
- Responsive bar width and spacing

### 4. ActivityCard (`lib/widgets/activity_card.dart`)
Activity feed component:
- List rendering with custom icons
- Time-based color coding
- Hover effects

## Development Setup

### Flutter Path
- **Location**: `C:\Users\rifla\Downloads\Github\flutter`
- **Bin**: `C:\Users\rifla\Downloads\Github\flutter\bin\flutter.bat`

### Running the App
```bash
cd c:\Users\rifla\Downloads\Github\orea-ui
C:\Users\rifla\Downloads\Github\flutter\bin\flutter.bat run -d chrome
```

### Installing Dependencies
```bash
C:\Users\rifla\Downloads\Github\flutter\bin\flutter.bat pub get
```

## Key Learnings & Decisions

### Why Repository Pattern?
- **Separation of concerns**: UI doesn't know about HTTP
- **Testability**: Easy to mock repositories
- **Reusability**: Same repository used across multiple widgets
- **Centralized error handling**: One place for API errors

### Why Dio over http?
- **Interceptors**: Automatic token injection, logging
- **Better error handling**: Typed exceptions
- **Request cancellation**: Clean up on widget disposal
- **File upload/download**: Built-in progress tracking
- **Global configuration**: Set timeouts/headers once

### Why Riverpod over Provider?
- **Compile-time safety**: No runtime errors
- **Better testing**: Easy to override providers
- **More flexible**: Family, autoDispose, select, etc.
- **No BuildContext required**: Access state anywhere

### Why reactive_forms?
- **Declarative**: Similar to react-hook-form
- **Built-in validators**: No need to write custom validation
- **Form state management**: Automatic dirty/touched/valid tracking
- **Less boilerplate**: Compared to Flutter's built-in forms

## Common Patterns

### 1. Fetching Data on Page Load
```dart
class MyPage extends ConsumerStatefulWidget {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myProvider.notifier).fetchData();
    });
  }
}
```

### 2. Watching State in UI
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(myProvider);

  if (state.isLoading) return CircularProgressIndicator();
  if (state.errorMessage != null) return ErrorWidget();

  return DataWidget(data: state.data);
}
```

### 3. Error Handling in Repository
```dart
try {
  final response = await _dioService.get('/endpoint');
  return parseData(response.data);
} on NetworkException catch (e) {
  // Handle network error
  rethrow;
} on ServerException catch (e) {
  // Handle server error
  rethrow;
} catch (e) {
  throw Exception('Unexpected error: $e');
}
```

### 4. Responsive Widgets
```dart
final isSmallScreen = MediaQuery.of(context).size.width < 600;

return Container(
  padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
  child: Text(
    'Title',
    style: TextStyle(fontSize: isSmallScreen ? 16 : 24),
  ),
);
```

## Documentation

See `API_FETCHING_GUIDE.md` for comprehensive guide on:
- Different API fetching patterns
- Error handling strategies
- Caching approaches
- Testing methods
- Best practices by project size

## Future Improvements

### Planned
- [ ] Token refresh mechanism (commented in `dio_service.dart:69-82`)
- [ ] Offline caching with Hive/Drift
- [ ] Unit tests for repositories
- [ ] Widget tests for pages
- [ ] Environment-based configuration (.env)

### Considerations
- Clean Architecture for larger projects
- BLoC pattern alternative to Riverpod
- GraphQL with `graphql_flutter`
- Firebase integration
- Analytics and error tracking

## Notes

- Project is in learning/development phase
- Some features are demonstrations (e.g., users_page.dart vs users_page_improved.dart)
- Authentication is simplified (no real backend)
- API uses JSONPlaceholder (read-only mock API)
- Focus is on Flutter best practices and architecture patterns