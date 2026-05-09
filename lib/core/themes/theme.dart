// import 'package:flutter/material.dart';

// // ==================== LIGHT MODE ====================
// // مناسب للشات apps، نظيف ومريح للعين
// ThemeData lightMode = ThemeData(
//   brightness: Brightness.light,
//   useMaterial3: true, // Material Design 3 للشكل الحديث
//   // لون أساسي للـ AppBar، أزرار الشات، active tabs
//   colorScheme: ColorScheme.light(
//     primary: Colors.blue.shade500, // AppBar, primary buttons
//     onPrimary: Colors.white, // نص على الأزرار الرئيسية
//     // للـ chat bubbles، secondary buttons، accents
//     secondary: Colors.teal.shade400, // رسائل المستخدم، tabs
//     onSecondary: Colors.white, // نص على الـ secondary
//     // للـ background الرئيسي للصفحات
//     background: Colors.grey.shade50, // خلفية الصفحات الرئيسية
//     // للـ cards، chat list items، sheets
//     surface: Colors.white, // بطاقات المنتجات، رسائل الآخرين
//     onSurface: Colors.black87, // نص عادي، أيقونات
//     // للـ errors (validation، delete)
//     error: Colors.red.shade400,
//     onError: Colors.white,

//     // للـ disabled states
//     onSurfaceVariant: Colors.grey.shade500,
//   ),

//   // للـ Text styles تلقائي
//   textTheme: const TextTheme(
//     titleLarge: TextStyle(fontWeight: FontWeight.bold),
//   ),
// );

// // ==================== DARK MODE ====================
// // نفس الهيكل بس ألوان داكنة للراحة الليلية
// ThemeData darkMode = ThemeData(
//   brightness: Brightness.dark,
//   useMaterial3: true,

//   colorScheme: ColorScheme.dark(
//     // نفس الألوان بس أغمق للـ contrast
//     primary: Colors.blue.shade400, // AppBar في الـ dark
//     onPrimary: Colors.white,

//     secondary: Colors.teal.shade300, // chat bubbles في الـ dark
//     onSecondary: Colors.white,

//     // خلفية داكنة مريحة
//     background: Colors.grey.shade900, // الخلفية الرئيسية
//     // cards داكنة
//     surface: Colors.grey.shade800, // الرسائل والقوائم
//     onSurface: Colors.white, // نص فاتح

//     error: Colors.red.shade400,
//     onError: Colors.white,

//     onSurfaceVariant: Colors.grey.shade400,
//   ),
// );
import 'package:flutter/material.dart';

// ======================================================
// ==================== LIGHT MODE =====================
// ======================================================
// تصميم حديث ونظيف بألوان هادئة ومتناسقة
// مناسب للتطبيقات العصرية (شات، تسوق، منصات)

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true, // Material Design 3 للشكل الحديث والزوايا الدائرية

  colorScheme: const ColorScheme.light(
    // ========== الألوان الرئيسية ==========
    // 🎯 primary: للـ AppBar، الأزرار الرئيسية، الأيقونات المهمة، الـ TabBar
    primary: Color(0xFF6366F1), // Indigo 500 - أزرق بنفسجي أنيق
    // 🖱️ onPrimary: النص والأيقونات اللي فوق الـ primary
    onPrimary: Colors.white, // نص أبيض للتباين
    // ========== الألوان الثانوية ==========
    // 💚 secondary: للـ FloatingActionButton، الأزرار الثانوية، الـ Chat Bubbles للمستخدم
    secondary: Color(0xFF10B981), // Emerald 500 - أخضر زمردي جميل
    // 📝 onSecondary: النص فوق الـ secondary
    onSecondary: Colors.white, // Slate 50 - رمادي فاتح جداً
    // 🎴 surface: خلفية الـ Cards، الـ Dialogs، الـ BottomSheets، حاويات المحتوى
    surface: Colors.white, // أبيض نقي لصندوق المحتوى
    // 📄 onSurface: النص الرئيسي على الـ surface (عناوين، فقرات)
    onSurface: Color(0xFF1E293B), // Slate 800 - رمادي غامق للقراءة المريحة
    // ========== ألوان إضافية ==========
    // 🔘 onSurfaceVariant: النص الثانوي (تواريخ، إحصائيات، تلميحات)
    onSurfaceVariant: Color(0xFF64748B), // Slate 500 - رمادي متوسط
    // ❌ error: أخطاء الإدخال، رسائل الحذف، التنبيهات المهمة
    error: Color(0xFFEF4444), // Red 500 - أحمر ناصع
    // ⚠️ onError: النص فوق لون الخطأ
    onError: Colors.white,

    // 🚫 inverseSurface: للـ Snackbar، الـ Tooltip (عكس السطح الرئيسي)
    inverseSurface: Color(0xFF1E293B), // Slate 800
    // ✨ onInverseSurface: النص على الـ inverseSurface
    onInverseSurface: Colors.white,

    // 🎨 tertiary: لمسات إضافية (الأزرار غير المهمة، الأيقونات الثانوية)
    tertiary: Color(0xFF8B5CF6), // Violet 500 - بنفسجي فاتح
    // 📦 onTertiary: النص على الـ tertiary
    onTertiary: Colors.white,

    // 🌈 surfaceTint: تأثير الطبقة العائمة (للـ AppBar الشفاف، الـ NavigationBar)
    surfaceTint: Colors.transparent,
  ),

  // ========== إعدادات إضافية ==========
  // 🎨 شكل الـ AppBar
  appBarTheme: const AppBarTheme(
    elevation: 0, // بدون ظل للشكل المسطح
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // 📝 شكل الـ TextField
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF6366F1),
        width: 2,
      ), // primary
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
    ),
    hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
    labelStyle: const TextStyle(color: Color(0xFF475569)), // Slate 600
  ),

  // 🃏 شكل الـ Card
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
  ),

  // 🔘 شكل الأزرار الرئيسية
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6366F1), // primary
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),

  // ⌨️ شكل الأزرار الثانوية
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF6366F1), // primary
    ),
  ),
);

// ======================================================
// ==================== DARK MODE ======================
// ======================================================
// نسخة داكنة مريحة للعين، بنفس تناسق الألوان
// مناسبة للاستخدام الليلي

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,

  colorScheme: const ColorScheme.dark(
    // ========== الألوان الرئيسية ==========
    // 🎯 primary: للـ AppBar، الأزرار الرئيسية (نفس اللون ولكن أفتح قليلاً للوضوح)
    primary: Color(0xFF818CF8), // Indigo 400 - أفتح من الـ light mode
    // 🖱️ onPrimary: النص فوق الـ primary
    onPrimary: Colors.white,

    // ========== الألوان الثانوية ==========
    // 💚 secondary: للأزرار الثانوية، chat bubbles
    secondary: Color(0xFF34D399), // Emerald 400 - أخضر فاتح
    // 📝 onSecondary: النص فوق الـ secondary
    onSecondary: Colors.white,
    // background: Color(0xFF0F172A), // Slate 900 - داكن جداً لكن مو أسود
    // 🎴 surface: خلفية الـ Cards، الـ Dialogs، حاويات المحتوى
    surface: Color(
      0xFF1E293B,
    ), // Slate 800 - أفتح شوي من الخلفية عشان يبان الـ Card
    // 📄 onSurface: النص الرئيسي على الـ surface (أبيض للقراءة)
    onSurface: Color(0xFFF1F5F9), // Slate 200 - أبيض مائل للرمادي
    // ========== ألوان إضافية ==========
    // 🔘 onSurfaceVariant: النص الثانوي، التواريخ، التلميحات
    onSurfaceVariant: Color(0xFF94A3B8), // Slate 400 - رمادي متوسط
    // ❌ error: أخطاء الإدخال (نفس اللون للحفاظ على المعنى)
    error: Color(0xFFF87171), // Red 400 - أحمر أفتح قليلاً للوضوح بالداكن
    // ⚠️ onError: النص فوق لون الخطأ
    onError: Colors.white,

    // 🚫 inverseSurface: للـ Snackbar (عكس السطح - أبيض)
    inverseSurface: Color(0xFFF1F5F9), // Slate 200 - فاتح للتباين
    // ✨ onInverseSurface: النص على الـ inverseSurface (داكن)
    onInverseSurface: Color(0xFF0F172A), // Slate 900
    // 🎨 tertiary: لمسات إضافية (نفس اللون ولكن أفتح)
    tertiary: Color(0xFFA78BFA), // Violet 400
    // 📦 onTertiary: النص على الـ tertiary
    onTertiary: Colors.white,

    // 🌈 surfaceTint: تأثير الطبقة العائمة
    surfaceTint: Colors.transparent,
  ),

  // ========== إعدادات إضافية ==========
  // 🎨 شكل الـ AppBar في الوضع الداكن
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Color(0xFF0F172A), // نفس الخلفية
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // 📝 شكل الـ TextField في الوضع الداكن
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color.fromARGB(255, 49, 59, 67), // سطح أغمق
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF334155)), // Slate 700
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF818CF8),
        width: 2,
      ), // primary
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
    ),
    // hintStyle: TextStyle(color: Color.fromARGB(255, 110, 128, 153)),
    hintStyle: const TextStyle(
      color: Color.fromARGB(255, 160, 172, 188),
    ), // Slate 500
    labelStyle: const TextStyle(color: Color.fromARGB(255, 160, 172, 188)),
    // labelStyle: const TextStyle(color: Color(0xF
    //F94A3B8)), // Slate 400
  ),

  // 🃏 شكل الـ Card في الوضع الداكن
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: const Color(0xFF1E293B), // سطح
  ),

  // 🔘 شكل الأزرار الرئيسية في الوضع الداكن
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF818CF8), // primary
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),

  // ⌨️ شكل الأزرار الثانوية
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF818CF8), // primary
    ),
  ),
);

// ======================================================
// ==================== ملخص الاستخدام ==================
// ======================================================

/*
📌 كيف تستخدم الألوان في تطبيقك:

1️⃣ خلفية الـ Scaffold (الصفحة كلها):
   backgroundColor: Theme.of(context).colorScheme.background

2️⃣ خلفية الـ Card، Container، Dialog:
   color: Theme.of(context).colorScheme.surface

3️⃣ النص الرئيسي (عناوين، محتوى مهم):
   color: Theme.of(context).colorScheme.onSurface

4️⃣ النص الثانوي (تواريخ، تفاصيل أقل أهمية):
   color: Theme.of(context).colorScheme.onSurfaceVariant

5️⃣ أزرار رئيسية (تسجيل دخول، إرسال):
   backgroundColor: Theme.of(context).colorScheme.primary
   أو استخدم ElevatedButton مباشرة (يأخذ اللون تلقائياً)

6️⃣ أزرار ثانوية (إلغاء، رجوع):
   backgroundColor: Theme.of(context).colorScheme.secondary

7️⃣ رسائل خطأ:
   color: Theme.of(context).colorScheme.error

8️⃣ الـ TextField:
   لا تحتاج لتلوين يدوي، الـ Theme يضبطه تلقائياً

9️⃣ الـ AppBar:
   يأخذ لون primary تلقائياً

🔟 الـ FloatingActionButton:
   يأخذ لون secondary تلقائياً
*/
