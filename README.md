## 🚀 Talcove — Flutter Chat Application  
مشروع Talcove هو تطبيق محادثة مبني باستخدام Flutter، مع دعم كامل للغات (EN/AR/FR)، وثيم داكن/فاتح، ومعمارية منظمة قابلة للتوسّع، باستخدام Riverpod وLocal Storage.

هذا الدليل مخصص لأعضاء الفريق ليفهموا طريقة العمل داخل المشروع وكيفية إضافة ميزات جديدة بشكل صحيح.

---

# 📁 **هيكلية المشروع (Architecture Overview)**

```
lib/
│   main.dart
│
├── authentication/
│   ├── entry_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   └── widgets/
│       ├── confirm_password_field.dart
│       ├── login_form.dart
│       ├── password_field.dart
│       └── signup_form.dart
│
├── core/
│   ├── constants/
│   ├── themes/
│   └── utils/
│
├── features/
│   ├── home/
│   ├── providers/
│   └── widgets/
│
├── generated/
│
├── l10n/
│
├── models/
│
└── shared/
    ├── services/
    └── widgets/
```

---

# 🧱 **قواعد إضافة صفحات جديدة**

## ✔️ أين نضع الصفحة؟
يعتمد على نوعها:

| نوع الصفحة | مكانها |
|-----------|--------|
| تسجيل دخول / تسجيل | authentication/ |
| صفحة رئيسية أو ميزة كاملة | features/<feature_name>/ |
| Widgets عامة | shared/widgets/ |
| Widgets خاصة بميزة | features/<feature>/widgets/ |

## ✔️ مثال: إضافة صفحة Profile

```
features/profile/
    profile_screen.dart
    widgets/
        profile_header.dart
        profile_info_tile.dart
```

---

# 🧩 **قواعد إضافة Widgets**

## ✔️ Widgets عامة (Reusable)
توضع في:
```
shared/widgets/
```

## ✔️ Widgets خاصة بميزة معينة
توضع في:
```
features/<feature>/widgets/
```

---

# 🎛️ **قواعد إضافة Providers**

كل Provider يجب أن يكون داخل:

```
features/providers/
```

ويُكتب باستخدام Riverpod Codegen:

- ملف مستقل لكل Provider  
- اسم واضح  
- بدون خلط بين الـ UI والـ Logic  

مثال:

```
auth_provider.dart
theme_provider.dart
language_provider.dart
```

---

# 🧬 **قواعد إضافة Models**

توضع داخل:

```
models/
```

ويُفضّل استخدام Freezed إذا كان الموديل معقّد.

---

# 🌍 **قواعد إضافة ترجمات جديدة (Flutter Intl)**

المشروع يستخدم إضافة **Flutter Intl** لإدارة الترجمات.

## ✔️ لإضافة لغة جديدة:
1. اضغط:
   ```
   Ctrl + Shift + P
   ```
2. اكتب:
   ```
   Flutter Intl: Add Locale
   ```
3. اختر اللغة المطلوبة (مثال: ar أو fr أو en)

الإضافة ستقوم تلقائيًا بإنشاء ملف `.arb` جديد داخل مجلد `l10n/` وتحديث ملفات `generated/`.

## ✔️ لإضافة نص جديد:
1. افتح ملف اللغة الأساسي:
   ```
   l10n/intl_en.arb
   ```
2. أضف المفتاح الجديد:
   ```json
   "welcome": "Welcome"
   ```
3. افتح باقي اللغات:
   ```
   intl_ar.arb
   intl_fr.arb
   ```
4. أضف نفس المفتاح مع الترجمة المناسبة.

⚠️ **ملاحظة:**  
لا تحتاج لتشغيل `flutter gen-l10n` لأن Flutter Intl يقوم بكل شيء تلقائيًا.

---

# 🎨 **قواعد الثيم والستايل**

- الثيم موجود داخل `core/themes/theme.dart`
- أي لون أو حجم أو ثابت → داخل `core/constants/`
- يمنع كتابة ألوان داخل Widgets مباشرة

---

# 🧪 **قواعد اختبار الصفحات**

يجب اختبار كل صفحة على:

- شاشة صغيرة  
- شاشة كبيرة  
- Tablet  
- Web  
- Dark/Light  
- لغتين (EN + AR)

ويجب التأكد من:

- عدم وجود Overflow  
- عدم وجود مشاكل أبعاد  
- أن الـ Scroll يعمل  
- أن الـ Validators لا تسبب مشاكل  

---

# 🧭 **قواعد Git للفريق**

## ✔️ 1) كل عضو يعمل على فرع خاص:
```
feature/<feature-name>
```

## ✔️ 2) يمنع الرفع على main مباشرة

## ✔️ 3) كل Merge يتم عبر Pull Request

## ✔️ 4) رسائل الـ Commit يجب أن تكون واضحة:

```
feat: add profile screen
fix: signup validator overflow
refactor: clean login form
```

---

---

# 🏁 **الخلاصة**

هذا الدليل هو المرجع الرسمي لفريق Talcove.  
الهدف منه:

- توحيد أسلوب كتابة الكود  
- تسهيل التعاون  
- منع الفوضى  
- ضمان قابلية التوسع  

أي عضو جديد يدخل على المشروع لازم يقرأ هذا الملف قبل ما يبدأ شغل.

---
