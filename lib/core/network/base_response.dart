/// Envelope-agnostic result returned by [ApiClient].
///
/// CBEX uses three response shapes (`{success,data}`, `{status,data}`, bare
/// `{data}`). The client treats any 2xx as success, unwraps `data` (or the whole
/// body), and exposes pagination `meta` here — so repositories consume only
/// [data] / [meta] and never branch on the envelope.
class ApiResult<T> {
  /// Parsed payload (null for `void`/no-`fromJson` calls).
  final T? data;

  /// Raw `meta` block from list responses (for [Pagination]).
  final Map<String, dynamic>? meta;

  /// Human-readable `message`, when the body carries one.
  final String? message;

  final int statusCode;

  const ApiResult({
    this.data,
    this.meta,
    this.message,
    required this.statusCode,
  });
}
