/// Stream generator that emits a countdown tick every second
class TimerTicker {
  const TimerTicker();

  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
      const Duration(seconds: 1),
      (x) => ticks - x - 1,
    ).take(ticks);
  }
}
