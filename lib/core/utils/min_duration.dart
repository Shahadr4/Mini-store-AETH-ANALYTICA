/// Waits for [task], but not less than [minimum].
///
/// Used so a loading shimmer stays on screen long enough to be seen, even if
/// the request finishes (or fails) almost instantly.
Future<T> withMinDuration<T>(Future<T> task, Duration minimum) async {
  if (minimum == Duration.zero) return task;
  final results = await Future.wait<Object?>([
    task,
    Future<void>.delayed(minimum),
  ]);
  return results.first as T;
}
