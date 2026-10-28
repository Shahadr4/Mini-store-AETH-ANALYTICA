import 'failures.dart';

/// Either a value or a [Failure]. Pure Dart so the domain layer can use it.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => switch (this) {
    Success<T>(:final data) => success(data),
    Fail<T>(failure: final error) => failure(error),
  };

  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Fail<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Fail<T>(:final failure) => failure,
  };
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class Fail<T> extends Result<T> {
  const Fail(this.failure);

  final Failure failure;
}
