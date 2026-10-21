/// Source of the current time. Injected everywhere "now" matters so that every
/// date rule can be tested at a fixed moment and nothing reads the system clock
/// behind the caller's back.
typedef Clock = DateTime Function();

/// The production clock.
DateTime systemClock() => DateTime.now();
