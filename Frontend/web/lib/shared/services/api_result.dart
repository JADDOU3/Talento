/// Result of an authenticated HTTP call via [ApiService].
class ApiResult {
  const ApiResult({
    required this.status,
    this.body,
    this.rawText,
  });

  final int status;
  final dynamic body;
  final String? rawText;

  bool get isSuccess => status >= 200 && status < 300;
  bool get isUnauthorized => status == 401;
  bool get isNotFound => status == 404;
  bool get isNetworkFailure => status == 0;
}
