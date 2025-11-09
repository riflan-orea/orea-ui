# Best Practices for Fetching Data from Endpoints in Flutter

## Table of Contents
1. [Architecture Patterns](#architecture-patterns)
2. [Implementation Comparison](#implementation-comparison)
3. [Error Handling](#error-handling)
4. [Caching Strategies](#caching-strategies)
5. [Testing](#testing)
6. [Recommendations](#recommendations)

---

## Architecture Patterns

### 1. Simple StatefulWidget Approach (Current)
**File:** `lib/pages/users_page.dart`

**Use Case:** Small apps, prototypes, learning

```dart
class UsersPage extends StatefulWidget {
  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(url));
      final users = parseUsers(response.body);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}
```

**Pros:**
- ✅ Simple and straightforward
- ✅ Easy to understand for beginners
- ✅ No additional dependencies
- ✅ Quick to implement

**Cons:**
- ❌ Business logic mixed with UI
- ❌ Hard to test
- ❌ Code duplication across pages
- ❌ No separation of concerns
- ❌ Difficult to maintain

---

### 2. Repository Pattern ⭐ (RECOMMENDED)
**Files:**
- `lib/services/api_service.dart`
- `lib/repositories/user_repository.dart`
- `lib/providers/users_provider.dart`
- `lib/pages/users_page_improved.dart`

**Use Case:** Production apps, medium to large projects

#### Architecture Layers:

```
┌─────────────────────────────────────┐
│         UI Layer (Widget)           │  ← users_page_improved.dart
├─────────────────────────────────────┤
│    State Management (Riverpod)      │  ← users_provider.dart
├─────────────────────────────────────┤
│   Business Logic (Repository)       │  ← user_repository.dart
├─────────────────────────────────────┤
│    Network Layer (API Service)      │  ← api_service.dart
├─────────────────────────────────────┤
│         HTTP Package/Dio            │
└─────────────────────────────────────┘
```

#### Implementation:

**Step 1: API Service (Network Layer)**
```dart
// lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'https://api.example.com';

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200: return json.decode(response.body);
      case 401: throw UnauthorizedException();
      case 404: throw NotFoundException();
      case 500: throw ServerException();
      default: throw Exception('HTTP Error');
    }
  }
}
```

**Step 2: Repository (Business Logic)**
```dart
// lib/repositories/user_repository.dart
class UserRepository {
  final ApiService _apiService;

  Future<List<User>> getUsers() async {
    final response = await _apiService.get('/users');
    return response.map((json) => User.fromJson(json)).toList();
  }

  Future<User> getUserById(int id) async {
    final response = await _apiService.get('/users/$id');
    return User.fromJson(response);
  }
}
```

**Step 3: State Management (Riverpod)**
```dart
// lib/providers/users_provider.dart
class UsersNotifier extends StateNotifier<UsersState> {
  final UserRepository _repository;

  UsersNotifier(this._repository) : super(const UsersState());

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      final users = await _repository.getUsers();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UsersNotifier(repository);
});
```

**Step 4: UI Layer**
```dart
// lib/pages/users_page_improved.dart
class UsersPageImproved extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersProvider);

    if (usersState.isLoading) return LoadingWidget();
    if (usersState.errorMessage != null) return ErrorWidget();

    return ListView.builder(
      itemCount: usersState.users.length,
      itemBuilder: (context, index) {
        return UserCard(user: usersState.users[index]);
      },
    );
  }
}
```

**Pros:**
- ✅ Clean separation of concerns
- ✅ Easy to test each layer independently
- ✅ Reusable repository across multiple widgets
- ✅ Centralized error handling
- ✅ Easy to mock for testing
- ✅ Scalable for large apps
- ✅ State management built-in

**Cons:**
- ❌ More boilerplate code
- ❌ Steeper learning curve
- ❌ Requires understanding of Riverpod

---

### 3. Other Popular Patterns

#### A. **BLoC Pattern**
```dart
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository repository;

  UsersBloc(this.repository) : super(UsersInitial()) {
    on<FetchUsers>((event, emit) async {
      emit(UsersLoading());
      try {
        final users = await repository.getUsers();
        emit(UsersLoaded(users));
      } catch (e) {
        emit(UsersError(e.toString()));
      }
    });
  }
}
```

#### B. **GetX Pattern**
```dart
class UsersController extends GetxController {
  final UserRepository repository;
  var users = <User>[].obs;
  var isLoading = false.obs;

  Future<void> fetchUsers() async {
    isLoading.value = true;
    users.value = await repository.getUsers();
    isLoading.value = false;
  }
}
```

---

## Implementation Comparison

### Scenario: Fetch Users on Page Load

#### Simple Approach (StatefulWidget):
```dart
class UsersPage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _fetchUsers();  // Direct API call in widget
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse(url));
    // Parse and set state...
  }
}
```

#### Repository Pattern (Improved):
```dart
class UsersPageImproved extends ConsumerStatefulWidget {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).fetchUsers();  // Clean separation
    });
  }
}
```

---

## Error Handling

### Custom Exception Classes
```dart
// lib/services/api_service.dart
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super('Unauthorized access');
}

class NotFoundException extends ApiException {
  NotFoundException() : super('Resource not found');
}

class ServerException extends ApiException {
  ServerException() : super('Server error');
}
```

### Handling in Repository:
```dart
Future<List<User>> getUsers() async {
  try {
    final response = await _apiService.get('/users');
    return parseUsers(response);
  } on NetworkException catch (e) {
    // Log to analytics
    print('Network error: ${e.message}');
    rethrow;
  } on ServerException catch (e) {
    // Log to error tracking service
    print('Server error: ${e.message}');
    rethrow;
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
```

### Displaying in UI:
```dart
if (usersState.errorMessage != null) {
  return ErrorBanner(
    message: usersState.errorMessage!,
    onRetry: () => ref.read(usersProvider.notifier).fetchUsers(),
    onDismiss: () => ref.read(usersProvider.notifier).clearError(),
  );
}
```

---

## Caching Strategies

### 1. In-Memory Cache (Simple)
```dart
class UserRepository {
  List<User>? _cachedUsers;
  DateTime? _lastFetchTime;
  static const cacheDuration = Duration(minutes: 5);

  Future<List<User>> getUsers({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedUsers != null && _isCacheValid()) {
      return _cachedUsers!;
    }

    final users = await _apiService.get('/users');
    _cachedUsers = users;
    _lastFetchTime = DateTime.now();
    return users;
  }

  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < cacheDuration;
  }
}
```

### 2. Local Database (Hive/Drift)
```dart
class UserRepository {
  final ApiService _apiService;
  final HiveBox _cacheBox;

  Future<List<User>> getUsers() async {
    // Try cache first
    final cached = _cacheBox.get('users');
    if (cached != null) return cached;

    // Fetch from API
    final users = await _apiService.get('/users');

    // Save to cache
    _cacheBox.put('users', users);

    return users;
  }
}
```

---

## Testing

### Testing Repository:
```dart
void main() {
  group('UserRepository', () {
    late MockApiService mockApiService;
    late UserRepository repository;

    setUp(() {
      mockApiService = MockApiService();
      repository = UserRepository(apiService: mockApiService);
    });

    test('getUsers returns list of users', () async {
      // Arrange
      when(mockApiService.get('/users'))
          .thenAnswer((_) async => [{'id': 1, 'name': 'John'}]);

      // Act
      final users = await repository.getUsers();

      // Assert
      expect(users, isA<List<User>>());
      expect(users.length, 1);
      expect(users[0].name, 'John');
    });

    test('getUsers throws exception on error', () async {
      // Arrange
      when(mockApiService.get('/users'))
          .thenThrow(NetworkException('No internet'));

      // Act & Assert
      expect(
        () => repository.getUsers(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

### Testing Provider:
```dart
void main() {
  test('fetchUsers updates state correctly', () async {
    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(MockUserRepository()),
      ],
    );

    final notifier = container.read(usersProvider.notifier);

    await notifier.fetchUsers();

    final state = container.read(usersProvider);
    expect(state.isLoading, false);
    expect(state.users, isNotEmpty);
  });
}
```

---

## Recommendations

### For Different Project Sizes:

#### Small Project (< 10 screens)
✅ **Use:** Simple StatefulWidget approach
- Direct HTTP calls in widgets
- Minimal boilerplate
- Easy to understand

#### Medium Project (10-50 screens)
✅ **Use:** Repository Pattern + Riverpod
- Separation of concerns
- Reusable repositories
- Better testability

#### Large Project (50+ screens)
✅ **Use:** Repository Pattern + BLoC/Riverpod + Clean Architecture
- Multiple layers (Data, Domain, Presentation)
- Use cases/interactors
- Complete separation
- Highly testable

### Best Practices:

1. **Always handle errors gracefully**
   ```dart
   try {
     final data = await repository.fetchData();
   } on NetworkException {
     showSnackBar('No internet connection');
   } on ServerException {
     showSnackBar('Server error, please try again');
   } catch (e) {
     showSnackBar('Unexpected error');
   }
   ```

2. **Show loading states**
   ```dart
   if (isLoading) return CircularProgressIndicator();
   ```

3. **Implement timeout**
   ```dart
   final response = await http.get(url).timeout(Duration(seconds: 10));
   ```

4. **Use const constructors**
   ```dart
   const UsersState({this.users = const []});
   ```

5. **Cancel pending requests on dispose**
   ```dart
   @override
   void dispose() {
     _cancelToken.cancel();
     super.dispose();
   }
   ```

---

## Summary

| Pattern | Complexity | Testability | Scalability | Best For |
|---------|-----------|-------------|-------------|----------|
| StatefulWidget | Low | Low | Low | Prototypes, Learning |
| Repository + Riverpod | Medium | High | High | Production Apps |
| Clean Architecture | High | Very High | Very High | Enterprise Apps |

**For this project (orea-ui):**
- Current implementation (`users_page.dart`) is fine for learning
- Improved implementation (`users_page_improved.dart`) is better for production
- Choose based on your team's expertise and project requirements

---

## Files Created:

1. `lib/services/api_service.dart` - Network layer
2. `lib/repositories/user_repository.dart` - Business logic
3. `lib/providers/users_provider.dart` - State management
4. `lib/pages/users_page_improved.dart` - Improved UI

Compare both implementations to see the difference!
