/// Small JSON-unwrapping helpers used by [ApiClient] and repositories.
///
/// CBEX uses three response envelopes (`{success,data}`, `{status,data}`, bare
/// `{data}`); these normalize the payload regardless of the envelope.
library;

/// Unwraps the meaningful payload: the `data` value when present, else the body.
Object? unwrapData(Object? body) =>
    (body is Map && body.containsKey('data')) ? body['data'] : body;

/// Pulls the `meta` block (pagination) from a list response, if any.
Map<String, dynamic>? extractMeta(Object? body) =>
    (body is Map && body['meta'] is Map)
        ? Map<String, dynamic>.from(body['meta'] as Map)
        : null;

Map<String, dynamic> asMap(Object? json) =>
    json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};

List<Map<String, dynamic>> asMapList(Object? json) {
  if (json is List) {
    return json
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  // Some list endpoints still nest items under `data` after the outer unwrap.
  if (json is Map && json['data'] is List) {
    return (json['data'] as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return const [];
}
