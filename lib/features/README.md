# features/

كل ميزة (feature) في هذا المجلد وحدة مستقلة تتبع **Clean Architecture (data / presentation)**،
بنفس نمط مشروع `hrportal`. هذا المجلد فارغ عمدًا — أضِف ميزات CBEX بنفس البنية أدناه.

Each feature here is a self-contained module following **Clean Architecture
(data / presentation)**, mirroring the `hrportal` project. This folder is
intentionally empty — add CBEX features using the structure below.

## النمط الداخلي للميزة / Per-feature structure

```
features/
└── <feature>/
    ├── data/
    │   ├── models/              # نماذج البيانات (Equatable) — <feature>_models.dart
    │   └── repositories/        # المستودعات (تعتمد على ApiClient) — <feature>_repository.dart
    └── presentation/
        ├── providers/           # حالة Riverpod (StateNotifier / AsyncValue) — <feature>_providers.dart
        ├── screens/             # الشاشات (ConsumerWidget) — <feature>_screen.dart
        ├── widgets/             # عناصر واجهة خاصة بالميزة (اختياري)
        └── utils/               # منطق مساعد خاص بالميزة (اختياري)
```

## اصطلاحات التسمية / Naming conventions

| العنصر / Element        | اللاحقة / Suffix      | مثال / Example            |
| ----------------------- | --------------------- | ------------------------- |
| ملفات / Files           | `snake_case`          | `leave_repository.dart`   |
| Repository              | `Repository`          | `LeaveRepository`         |
| Riverpod provider       | `Provider`            | `leavesProvider`          |
| Screen / Page           | `Screen`              | `LeavesScreen`            |
| Model                   | (بدون لاحقة / none)   | `LeaveRequest`            |
| ملفات حسب المنصّة        | `_io` / `_web` / `_native` | `attachment_io.dart` |

## ربط الطبقات / Wiring

- **DI (data layer):** سجّل مستودع الميزة في [`injection.dart`](../injection.dart) عبر GetIt.
- **Bridge to Riverpod:** اعرض المستودع كـ provider في [`core/providers/core_providers.dart`](../core/providers/core_providers.dart).
- **Routing:** أضِف مسارات الميزة في [`router/app_router.dart`](../router/app_router.dart).

> مرجع كامل: راجع أي ميزة في `hrportal/lib/features/` (مثل `auth/`, `leave/`, `tasks/`)
> كقالب جاهز للنسخ والتكييف.
