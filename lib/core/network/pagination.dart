/// Pagination metadata parsed from a list response's `meta` block.
///
/// CBEX lists use `limit`/`offset` (and sometimes Laravel-style
/// `current_page`/`last_page`/`per_page`/`total`); this reads whichever exist.
class Pagination {
  final int total;
  final int limit;
  final int offset;
  final int? currentPage;
  final int? lastPage;
  final int? perPage;

  const Pagination({
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
    this.currentPage,
    this.lastPage,
    this.perPage,
  });

  factory Pagination.fromMeta(Map<String, dynamic>? meta) {
    if (meta == null) return const Pagination();
    int i(String k) => (meta[k] as num?)?.toInt() ?? 0;
    int? io(String k) => (meta[k] as num?)?.toInt();
    final perPage = io('per_page');
    return Pagination(
      total: i('total'),
      limit: i('limit') != 0 ? i('limit') : (perPage ?? 0),
      offset: i('offset'),
      currentPage: io('current_page'),
      lastPage: io('last_page'),
      perPage: perPage,
    );
  }

  bool get hasMore {
    if (currentPage != null && lastPage != null) return currentPage! < lastPage!;
    if (total > 0 && limit > 0) return offset + limit < total;
    return false;
  }
}
