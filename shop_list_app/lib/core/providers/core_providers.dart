import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_list_app/core/database/app_database.dart';
import 'package:shop_list_app/core/network/network_info.dart';

/// Provides the singleton [AppDatabase] instance.
/// Disposed automatically when the provider scope is destroyed.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.instance;
  ref.onDispose(() => database.close());
  return database;
});

/// Provides the [Connectivity] instance from `connectivity_plus`.
/// Kept separate so tests can override it independently.
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Provides a [NetworkInfo] implementation.
/// Override in tests using [ProviderContainer] / [ProviderScope] overrides.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(
    connectivity: ref.watch(connectivityProvider),
  );
});
