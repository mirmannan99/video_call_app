class ApiResponse<T> {
  T? data;
  bool error;
  String? errorMessage;
  int? responseCode;

  ApiResponse({
    this.data,
    this.errorMessage,
    this.responseCode,
    this.error = false,
  });
}
