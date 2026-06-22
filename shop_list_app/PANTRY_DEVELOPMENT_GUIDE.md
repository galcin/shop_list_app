# Development Guide: Pantry Feature Extension

This guide explains how to extend the Pantry feature following the established patterns.

## Quick Reference

### Adding a New Use Case

1. Create `lib/features/pantry/domain/usecases/[operation]_pantry_[noun]_usecase.dart`
2. Import repository and failure types
3. Return `Either<Failure, T>` with validation and error handling:

```dart
class [VerbNoun]PantryUseCase {
  final IPantryRepository _repository;

  [VerbNoun]PantryUseCase(this._repository);

  Future<Either<Failure, [ReturnType]>> call([params]) async {
    // Validate inputs
    if (invalidCondition) {
      return Left(ValidationFailure('error message'));
    }

    try {
      // Perform operation
      final result = await _repository.operation();
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
```

4. Create provider in `pantry_providers.dart`:

```dart
final [operationName]UseCaseProvider = Provider<[VerbNoun]PantryUseCase>((ref) {
  return [VerbNoun]PantryUseCase(ref.watch(pantryRepositoryProvider));
});
```

### Adding a Repository Method

1. Add abstract method to `IPantryRepository`
2. Implement in `PantryRepository`:

```dart
// Interface
abstract class IPantryRepository {
  Future<List<PantryItem>> [operation]([params]);
}

// Implementation
@override
Future<List<PantryItem>> [operation]([params]) async {
  try {
    final query = _database.select(_database.pantryItems)
      ..where((tbl) => tbl.isDeleted.equals(false));
    
    // Add filtering logic
    
    final rows = await query.get();
    return rows.map(_pantryItemFromRow).toList();
  } catch (e) {
    rethrow;
  }
}
```

### Adding a UI Filter

1. Add filter state provider:

```dart
final pantry[FilterName]Provider = StateProvider.autoDispose<[Type]>((ref) => [default]);
```

2. Update `filteredPantryItemsProvider` to apply the filter:

```dart
final filteredPantryItemsProvider = Provider.autoDispose<List<PantryItem>>((ref) {
  final asyncItems = ref.watch(pantryItemsProvider);
  final [filterVar] = ref.watch(pantry[FilterName]Provider);
  
  return asyncItems.maybeWhen(
    data: (items) {
      var filtered = items;
      if ([filterVar] != null) {
        filtered = filtered.where((item) => item.[property] == [filterVar]).toList();
      }
      return filtered;
    },
    orElse: () => [],
  );
});
```

### Adding a Computed Property to PantryItem

```dart
class PantryItem {
  // ... existing fields ...
  
  /// Compute your property
  [Type] get [propertyName] {
    // Logic here
    return result;
  }
  
  // Update copyWith() to include the field in the constructor call
  // (Note: computed properties aren't included in copyWith parameters)
}
```

### Adding Widget Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('[WidgetName]', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: [YourWidget](),
            ),
          ),
        ),
      );

      expect(find.byType([WidgetName]), findsOneWidget);
    });

    testWidgets('handles user interactions', (WidgetTester tester) async {
      // Test interactions
    });
  });
}
```

## Common Patterns

### Error Handling
Always use SnackBar for user feedback:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Error message'),
    backgroundColor: Colors.red[400],
  ),
);
```

### Loading States
Use AsyncValue.when() for async data:

```dart
asyncData.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(error: err),
  data: (value) => ContentWidget(value),
)
```

### State Updates
Always use AsyncValue.guard() for mutations:

```dart
state = await AsyncValue.guard(_fetchUpdatedData);
```

### Color Constants
Always use AppColors enum:

```dart
// ✅ Correct
backgroundColor: AppColors.primary,

// ❌ Wrong
backgroundColor: 0xFFFFA500,
```

## Testing Checklist

- [ ] Unit tests for new use cases (validation + happy path)
- [ ] Unit tests for new entity properties if computed
- [ ] Widget tests for new screens/major widgets
- [ ] Integration tests for end-to-end flows
- [ ] Error case handling (empty states, failures)

## Performance Considerations

1. **Use `.autoDispose`** on UI state providers to free memory
2. **Stream-based watching** in repository for real-time updates
3. **Limit queries** with `.where()` at database level
4. **Pagination** for large lists (not implemented yet)

## Common Issues & Solutions

### Circular Dependencies
- Don't import from presentation/providers in domain/
- Keep use cases independent of Riverpod
- Inject dependencies via constructors

### State Not Updating
- Ensure mutations call `state = await AsyncValue.guard(_fetch())`
- Verify `ref.invalidate(provider)` if manual refresh needed
- Check that entity `==` is working (uses Equatable)

### Build Issues After Schema Changes
```bash
# Regenerate Drift code
flutter pub run build_runner build --delete-conflicting-outputs

# Bump schema version in app_database.dart
int get schemaVersion => 10; // Increased from 9
```

---

For detailed implementation reference, see `PANTRY_IMPLEMENTATION_SUMMARY.md`.
