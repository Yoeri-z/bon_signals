## bon_signals

This package does two things:

- Re-exports [signals_flutter](https://pub.dev/packages/signals_flutter), without `signals_core` or extended behavior.
- Adds a new `Controller` abstract class that implements the `Dispose` interface from [basic_interfaces](https://pub.dev/packages/basic_interfaces) and allows for creation of managed signals in extending class bodies.
