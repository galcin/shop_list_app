import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list_app/core/network/network_info.dart';
import 'package:shop_list_app/core/providers/core_providers.dart';

// ---------------------------------------------------------------------------
// StubConnectivity
//
// Implements (not extends) Connectivity — Connectivity uses a factory +
// private constructor so subclassing is impossible.
// noSuchMethod satisfies any unimplemented members (e.g. deprecated APIs).
// ---------------------------------------------------------------------------

class StubConnectivity implements Connectivity {
  List<ConnectivityResult> _results;
  final _controller = StreamController<List<ConnectivityResult>>.broadcast();

  StubConnectivity([List<ConnectivityResult>? initial])
      : _results = initial ?? [ConnectivityResult.none];

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  /// Push a new state through [isConnected] and [connectivityStream].
  void emit(List<ConnectivityResult> results) {
    _results = results;
    _controller.add(results);
  }

  Future<void> close() => _controller.close();

  // Satisfies any other Connectivity members (e.g. deprecated helpers).
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late StubConnectivity stub;

  setUp(() => stub = StubConnectivity());
  tearDown(() => stub.close());

  // ── isConnected ────────────────────────────────────────────────────────────

  group('NetworkInfoImpl.isConnected', () {
    test('returns false when result is [none]', () async {
      stub.emit([ConnectivityResult.none]);
      expect(await NetworkInfoImpl(connectivity: stub).isConnected, isFalse);
    });

    test('returns true when result is [wifi]', () async {
      stub.emit([ConnectivityResult.wifi]);
      expect(await NetworkInfoImpl(connectivity: stub).isConnected, isTrue);
    });

    test('returns true when result is [mobile]', () async {
      stub.emit([ConnectivityResult.mobile]);
      expect(await NetworkInfoImpl(connectivity: stub).isConnected, isTrue);
    });

    test('returns true when result is [ethernet]', () async {
      stub.emit([ConnectivityResult.ethernet]);
      expect(await NetworkInfoImpl(connectivity: stub).isConnected, isTrue);
    });

    test('returns true when result contains [wifi, none]', () async {
      stub.emit([ConnectivityResult.wifi, ConnectivityResult.none]);
      expect(await NetworkInfoImpl(connectivity: stub).isConnected, isTrue);
    });

    test('returns false when result is an empty list', () async {
      stub.emit([]);
      expect(await NetworkInfoImpl(connectivity: stub).isConnected, isFalse);
    });
  });

  // ── connectivityStream ─────────────────────────────────────────────────────

  group('NetworkInfoImpl.connectivityStream', () {
    test('emits false when stream emits [none]', () async {
      final future =
          NetworkInfoImpl(connectivity: stub).connectivityStream.first;
      stub.emit([ConnectivityResult.none]);
      expect(await future, isFalse);
    });

    test('emits true when stream emits [wifi]', () async {
      final future =
          NetworkInfoImpl(connectivity: stub).connectivityStream.first;
      stub.emit([ConnectivityResult.wifi]);
      expect(await future, isTrue);
    });

    test('emits true when stream emits [mobile]', () async {
      final future =
          NetworkInfoImpl(connectivity: stub).connectivityStream.first;
      stub.emit([ConnectivityResult.mobile]);
      expect(await future, isTrue);
    });

    test('emits false when stream emits an empty list', () async {
      final future =
          NetworkInfoImpl(connectivity: stub).connectivityStream.first;
      stub.emit([]);
      expect(await future, isFalse);
    });

    test('maps multiple transitions in order', () async {
      final info = NetworkInfoImpl(connectivity: stub);
      final values = <bool>[];
      final sub = info.connectivityStream.listen(values.add);

      stub.emit([ConnectivityResult.wifi]);
      stub.emit([ConnectivityResult.none]);
      stub.emit([ConnectivityResult.mobile]);

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(values, [true, false, true]);
    });
  });

  // ── Riverpod providers ─────────────────────────────────────────────────────

  group('Riverpod providers', () {
    test('networkInfoProvider resolves to NetworkInfoImpl', () {
      final c = ProviderContainer(
        overrides: [connectivityProvider.overrideWithValue(stub)],
      );
      addTearDown(c.dispose);
      expect(c.read(networkInfoProvider), isA<NetworkInfoImpl>());
    });

    test('connectivityProvider override is reflected in networkInfoProvider',
        () {
      final c = ProviderContainer(
        overrides: [connectivityProvider.overrideWithValue(stub)],
      );
      addTearDown(c.dispose);
      final info = c.read(networkInfoProvider) as NetworkInfoImpl;
      expect(info.connectivity, same(stub));
    });
  });
}
