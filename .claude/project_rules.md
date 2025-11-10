# Project Rules & Guidelines

## Development Guidelines

### 1. Code Style
- Follow Flutter's official style guide
- Use `flutter_lints` for code analysis
- Prefer `const` constructors whenever possible
- Use meaningful variable and function names
- Add documentation comments for public APIs

### 2. State Management
- **Always use Riverpod** for state management
- Use `StateNotifierProvider` for complex state
- Use `Provider` for dependency injection
- Use `Provider.family` for parameterized providers
- Never use `setState` for cross-widget state

### 3. API Integration
- **Always use Repository Pattern** for API calls
- Never call API services directly from widgets
- Use `DioService` for all HTTP requests (not `ApiService` or raw `http`)
- Handle errors at the repository level
- Rethrow exceptions to let providers handle UI state

### 4. Error Handling
- Use custom exceptions from `dio_service.dart`:
  - `TimeoutException` for timeouts
  - `NetworkException` for connection issues
  - `UnauthorizedException` for 401 errors
  - `NotFoundException` for 404 errors
  - `ServerException` for 5xx errors
- Display user-friendly error messages in UI
- Log errors for debugging (in debug mode)

### 5. Forms
- Use `reactive_forms` package for complex forms
- Use built-in validators when possible
- Display validation errors inline
- Show loading state during submission
- Handle form submission errors gracefully

### 6. Routing
- All routes defined in `lib/router/app_router.dart`
- Protected routes must use `ShellRoute` with `AppLayout`
- Public routes (like login) are direct routes
- Use named routes for navigation
- Handle redirect logic in router configuration

### 7. Responsive Design
- **Always** consider mobile, tablet, and desktop screens
- Use `MediaQuery.of(context).size.width` for breakpoints
- Breakpoints:
  - Small (mobile): `< 600px`
  - Medium (tablet): `600px - 1200px`
  - Large (desktop): `>= 1200px`
- Test on different screen sizes

### 8. File Organization
```
lib/
├── main.dart              # Entry point only
├── router/                # Routing configuration
├── providers/             # Riverpod state providers
├── services/              # API services (Dio)
├── repositories/          # Business logic layer
├── models/                # Data models with fromJson/toJson
├── pages/                 # Full page widgets
└── widgets/               # Reusable components
```

### 9. Widget Best Practices
- Create reusable widgets in `lib/widgets/`
- Pass data via constructor parameters
- Use `const` constructors when possible
- Keep widgets small and focused
- Extract complex widgets into separate files

### 10. Performance
- Use `const` constructors to reduce rebuilds
- Implement `select` in Riverpod to watch specific fields
- Use `ListView.builder` for long lists
- Avoid expensive operations in `build` method
- Dispose controllers and streams

## Naming Conventions

### Files
- Use snake_case: `user_repository.dart`, `dashboard_page.dart`
- Suffix with type: `*_page.dart`, `*_provider.dart`, `*_service.dart`

### Classes
- Use PascalCase: `UserRepository`, `DashboardPage`, `UsersNotifier`
- Suffix providers with `Provider`: `usersProvider`, `authProvider`
- Suffix notifiers with `Notifier`: `UsersNotifier`, `AuthNotifier`
- Suffix state classes with `State`: `UsersState`, `AuthState`

### Variables
- Use camelCase: `userName`, `isLoading`, `errorMessage`
- Boolean variables start with `is`, `has`, `can`: `isLoading`, `hasError`
- Private variables start with `_`: `_dioService`, `_repository`

### Constants
- Use lowerCamelCase for const variables: `baseUrl`, `cacheDuration`
- Use SCREAMING_SNAKE_CASE for compile-time constants: `MAX_RETRY_COUNT`

## Dependency Management

### Adding New Packages
1. Add to `pubspec.yaml` dependencies section
2. Run `C:\Users\rifla\Downloads\Github\flutter\bin\flutter.bat pub get`
3. Import in files where needed
4. Document in `.claude/context.md`

### Package Selection Criteria
- Actively maintained (updated within last 6 months)
- Good documentation
- High pub.dev score
- Compatible with Flutter web
- Null-safety support

## Git Workflow

### Commit Messages
- Use conventional commits format:
  - `feat:` for new features
  - `fix:` for bug fixes
  - `refactor:` for code refactoring
  - `docs:` for documentation changes
  - `style:` for formatting changes
  - `test:` for test additions

### Branches
- `main` - Production-ready code
- `develop` - Development branch
- Feature branches: `feature/feature-name`
- Bug fixes: `fix/bug-description`

## Testing Strategy

### Unit Tests
- Test repositories with mocked services
- Test providers with mocked repositories
- Test utility functions
- Target: 80% code coverage

### Widget Tests
- Test page widgets with mocked providers
- Test custom widgets in isolation
- Test user interactions
- Verify correct UI state rendering

### Integration Tests
- Test complete user flows
- Test navigation
- Test API integration (with mock server)

## Security Guidelines

### Authentication
- Never store plain passwords
- Use secure storage for tokens (SharedPreferences is demo only)
- Implement token refresh mechanism
- Add expiration checks
- Logout on 401 errors

### API Calls
- Always use HTTPS in production
- Validate all user input
- Sanitize data before displaying
- Handle CORS properly for web
- Rate limit requests if needed

### Data Privacy
- Don't log sensitive data
- Clear local storage on logout
- Use appropriate HTTP-only cookies
- Follow GDPR guidelines if applicable

## Documentation

### Code Comments
- Use `///` for public API documentation
- Explain **why**, not **what**
- Document complex algorithms
- Add TODOs for future improvements

### README Updates
- Keep dependencies list current
- Document setup steps
- Add screenshots of features
- Include troubleshooting section

### Claude Context
- Update `.claude/context.md` when adding major features
- Update `.claude/project_rules.md` when changing conventions
- Document architectural decisions

## Common Mistakes to Avoid

### ❌ Don't
- Don't use `http` package directly (use `DioService`)
- Don't use `ApiService` (legacy, use `DioService`)
- Don't call API from widgets (use repositories)
- Don't use `setState` for global state (use Riverpod)
- Don't ignore errors (always handle gracefully)
- Don't forget to dispose controllers
- Don't hardcode values (use constants)
- Don't mix business logic in UI

### ✅ Do
- Use `DioService` for all HTTP requests
- Use Repository Pattern for API integration
- Use Riverpod for state management
- Use `reactive_forms` for complex forms
- Handle all error cases
- Write meaningful tests
- Keep widgets small and focused
- Follow responsive design principles

## Performance Optimization

### Build Optimization
- Use `const` constructors aggressively
- Avoid anonymous functions in build methods
- Use `RepaintBoundary` for expensive widgets
- Implement `shouldRebuild` in custom widgets

### State Optimization
- Use `.select()` in Riverpod to watch specific fields
- Use `.family` for parameterized providers
- Use `.autoDispose` for temporary state
- Avoid unnecessary provider rebuilds

### Network Optimization
- Implement caching in repositories
- Use pagination for large datasets
- Cancel requests on widget disposal
- Implement retry logic with exponential backoff

## Debugging Tips

### Common Issues
1. **"http package" errors**: Switch to DioService
2. **Provider not found**: Ensure provider is declared before use
3. **Route not found**: Check `app_router.dart` configuration
4. **Auth not persisting**: Check SharedPreferences initialization
5. **CORS errors**: Backend must allow web origin

### Debug Tools
- Flutter DevTools for performance
- Riverpod Inspector for state
- Network tab in browser for API calls
- Flutter Doctor for environment issues

## Environment-Specific Configuration

### Development
- Use JSONPlaceholder API
- Enable debug logging
- Use demo credentials
- Skip some validations

### Production (Future)
- Use real backend API
- Disable logging
- Enforce all validations
- Use environment variables
- Enable analytics

## Questions to Ask Before Coding

1. Does this need to be a new widget or can I reuse existing?
2. Should this state be local or global (Riverpod)?
3. Is this widget responsive across all screen sizes?
4. Does this follow the Repository Pattern?
5. Have I handled all error cases?
6. Is this code testable?
7. Have I added proper documentation?
8. Does this follow Flutter best practices?

## Resources

### Official Documentation
- Flutter: https://flutter.dev/docs
- Riverpod: https://riverpod.dev
- GoRouter: https://pub.dev/packages/go_router
- Dio: https://pub.dev/packages/dio
- Reactive Forms: https://pub.dev/packages/reactive_forms

### Project-Specific Docs
- `API_FETCHING_GUIDE.md` - Comprehensive API integration guide
- `.claude/context.md` - Project overview and architecture
- `.claude/project_rules.md` - This file

## Changelog

Keep track of major changes:

### 2024-01-XX
- Migrated from http to Dio for all API calls
- Implemented Repository Pattern for users
- Added reactive_forms for form management
- Created AppLayout with collapsible sidebar
- Added custom responsive widgets (StatCard, ChartCard, etc.)