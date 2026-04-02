import 'dart:collection';

import 'package:basic_interfaces/basic_interfaces.dart';
import 'package:bon_signals/bon_signals.dart';

class Controller implements Disposable {
  final _signals = HashMap.of(<int, ReadonlySignal>{});
  EffectCleanup? _cleanup;
  final _effects = <EffectCleanup>[];

  void disposeSignal(int id) {
    final s = _signals.remove(id);
    if (s == null) return;
    s.dispose();
  }

  S _register<V, S extends ReadonlySignal<V>>(S target) {
    if (_signals[target.globalId] != null) {
      return target;
    }

    _signals[target.globalId] = target;

    return target;
  }

  FutureSignal<S> createComputedFrom<S, A>(
    List<ReadonlySignal<A>> signals,
    Future<S> Function(List<A> args) fn, {
    S? initialValue,
    String? debugLabel,
    bool lazy = true,
  }) {
    return _register(
      computedFrom<S, A>(
        signals,
        fn,
        initialValue: initialValue,
        debugLabel: debugLabel,
        lazy: lazy,
      ),
    );
  }

  FutureSignal<S> createComputedAsync<S>(
    Future<S> Function() fn, {
    S? initialValue,
    String? debugLabel,
    List<ReadonlySignal<dynamic>> dependencies = const [],
    bool lazy = true,
  }) {
    return _register(
      computedAsync<S>(
        fn,
        dependencies: dependencies,
        initialValue: initialValue,
        debugLabel: debugLabel,
        lazy: lazy,
      ),
    );
  }

  FutureSignal<S> createFutureSignal<S>(
    Future<S> Function() fn, {
    S? initialValue,
    String? debugLabel,
    List<ReadonlySignal<dynamic>> dependencies = const [],
    bool lazy = true,
  }) {
    return _register(
      futureSignal<S>(
        fn,
        initialValue: initialValue,
        debugLabel: debugLabel,
        dependencies: dependencies,
        lazy: lazy,
      ),
    );
  }

  StreamSignal<S> createStreamSignal<S>(
    Stream<S> Function() callback, {
    S? initialValue,
    String? debugLabel,
    List<ReadonlySignal<dynamic>> dependencies = const [],
    void Function()? onDone,
    bool? cancelOnError,
    bool lazy = true,
  }) {
    return _register(
      streamSignal<S>(
        callback,
        initialValue: initialValue,
        debugLabel: debugLabel,
        dependencies: dependencies,
        onDone: onDone,
        cancelOnError: cancelOnError,
        lazy: lazy,
      ),
    );
  }

  AsyncSignal<S> createAsyncSignal<S>(
    AsyncState<S> value, {
    String? debugLabel,
  }) {
    return _register(asyncSignal<S>(value, debugLabel: debugLabel));
  }

  FlutterSignal<V> createSignal<V>(V val, {String? debugLabel}) {
    return _register(signal<V>(val, debugLabel: debugLabel));
  }

  ListSignal<V> createListSignal<V>(List<V> list, {String? debugLabel}) {
    return _register(ListSignal<V>(list, debugLabel: debugLabel));
  }

  SetSignal<V> createSetSignal<V>(Set<V> set, {String? debugLabel}) {
    return _register(SetSignal<V>(set, debugLabel: debugLabel));
  }

  QueueSignal<V> createQueueSignal<V>(Queue<V> queue, {String? debugLabel}) {
    return _register(QueueSignal<V>(queue, debugLabel: debugLabel));
  }

  MapSignal<K, V> createMapSignal<K, V>(Map<K, V> value, {String? debugLabel}) {
    return _register(MapSignal<K, V>(value, debugLabel: debugLabel));
  }

  FlutterComputed<V> createComputed<V>(V Function() cb, {String? debugLabel}) {
    return _register(computed<V>(cb, debugLabel: debugLabel));
  }

  /// Create a effect.
  EffectCleanup createEffect(
    dynamic Function() cb, {
    String? debugLabel,
    dynamic Function()? onDispose,
  }) {
    final s = effect(cb, debugLabel: debugLabel, onDispose: onDispose);
    _effects.add(s);
    return () {
      _effects.remove(s);
      s();
    };
  }

  /// Reset all stored signals and effects
  void clearSignalsAndEffects() {
    _cleanup?.call();
    _cleanup = null;
    final signals = _signals.values;
    for (final s in signals) {
      s.dispose();
    }
    for (final cb in _effects) {
      cb();
    }
    _effects.clear();
    _signals.clear();
  }

  @override
  void dispose() {
    clearSignalsAndEffects();
  }
}
