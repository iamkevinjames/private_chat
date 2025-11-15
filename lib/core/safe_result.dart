class SafeResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  SafeResult.success(this.data) : error = null, isSuccess = true;

  SafeResult.failure(this.error) : data = null, isSuccess = false;
}
