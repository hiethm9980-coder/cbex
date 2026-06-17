import 'package:flutter/material.dart';

import '../../core/errors/errors.dart';
import '../../core/errors/exceptions.dart';

/// Maps an [ApiException] (or any error) to a presentation [UiError] and shows it.
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static UiError handle(Object error) {
    if (error is ValidationException) {
      return UiError(
        title: 'تحقّق من البيانات',
        message: error.message,
        action: ErrorAction.fieldErrors,
        traceId: error.traceId,
      );
    }
    if (error is AuthRequiredException) {
      return UiError(
        title: 'انتهت الجلسة',
        message: error.message,
        action: ErrorAction.dialog,
        traceId: error.traceId,
      );
    }
    if (error is ForbiddenException) {
      return UiError(
        title: 'غير مسموح',
        message: error.message,
        traceId: error.traceId,
      );
    }
    if (error is RateLimitedException) {
      return UiError(
        title: 'محاولات كثيرة',
        message: error.message,
        traceId: error.traceId,
      );
    }
    if (error is NetworkException || error is TimeoutException) {
      return UiError(
        title: 'مشكلة في الاتصال',
        message: (error as ApiException).message,
      );
    }
    if (error is ApiException) {
      return UiError(
        title: 'خطأ',
        message: error.message,
        traceId: error.traceId,
      );
    }
    return const UiError(title: 'خطأ', message: 'حدث خطأ غير متوقع.');
  }

  static void show(BuildContext context, UiError error) {
    if (error.action == ErrorAction.dialog) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(error.title),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error.message)));
  }
}
