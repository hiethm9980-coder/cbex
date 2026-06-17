/// How the UI should present a [UiError].
enum ErrorAction {
  /// Transient snackbar.
  snackbar,

  /// Modal dialog (e.g. session expired).
  dialog,

  /// Inline field errors only (the screen renders them; no snackbar needed).
  fieldErrors,
}

/// A presentation-ready error: a title, a message, and how to show it.
///
/// Produced by `GlobalErrorHandler.handle(...)` from an [ApiException].
class UiError {
  final String title;
  final String message;
  final ErrorAction action;
  final String? traceId;

  const UiError({
    required this.title,
    required this.message,
    this.action = ErrorAction.snackbar,
    this.traceId,
  });
}
