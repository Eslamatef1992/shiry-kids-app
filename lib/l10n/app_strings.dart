import 'package:flutter/widgets.dart';

/// Lightweight dictionary-based localization.
///
/// Usage: wrap any user-facing English string with `.tr(context)`, e.g.
/// `Text('Home'.tr(context))`. When the active locale is Arabic and a
/// translation exists below, the Arabic text is returned. Otherwise the
/// original English string is returned unchanged, so it's always safe to
/// call even for strings that haven't been translated yet.
class AppStrings {
  AppStrings._();

  static const Map<String, String> ar = {
    // Bottom navigation
    'Home': 'الرئيسية',
    'Product': 'المنتجات',
    'Coupons': 'الكوبونات',
    'Cart': 'السلة',
    'My Profile': 'حسابي',

    // Home screen
    'Categories': 'الفئات',
    'Best Sellers': 'الأكثر مبيعاً',
    'New Arrivals': 'وصل حديثاً',
    'Weekly Offers': 'عروض أسبوعية',
    'See All': 'عرض الكل',
    'Add To Cart': 'أضف إلى السلة',
    'Details': 'التفاصيل',
    'added to cart!': 'أُضيف إلى السلة!',

    // Profile screen
    'Guest': 'زائر',
    'Log in to access your account': 'سجل الدخول للوصول إلى حسابك',
    'Activity': 'النشاط',
    'Orders': 'الطلبات',
    'Addresses': 'العناوين',
    'Settings': 'الإعدادات',
    'Change Password': 'تغيير كلمة المرور',
    'Change Language': 'تغيير اللغة',
    'App Information': 'معلومات التطبيق',
    'About Us': 'من نحن',
    'Privacy Policy': 'سياسة الخصوصية',
    'Terms & Conditions': 'الشروط والأحكام',
    'Company Contact Us': 'تواصل معنا',
    'Logout': 'تسجيل الخروج',
    'Log In': 'تسجيل الدخول',
    'Are You Sure You\nWant Logout?': 'هل أنت متأكد أنك تريد\nتسجيل الخروج؟',
    'No': 'لا',
    'Yes': 'نعم',
    'Arabic': 'العربية',
    'English': 'الإنجليزية',
    'Cancel': 'إلغاء',

    // Cart screen
    'You Have Not Any Item In Cart': 'لا توجد عناصر في سلتك',
    'Cart Item': 'عناصر السلة',
    'Checkout': 'إتمام الشراء',
    'Coupons:': 'الكوبونات:',
    'qty': 'الكمية',
    'Size:': 'المقاس:',
    'Color:': 'اللون:',
    'Number Of Item 12': 'عدد القطع 12',
    'Summary': 'الملخص',
    'Subtotal': 'المجموع الفرعي',
    'Discount': 'الخصم',
    'Shipping Fees': 'رسوم الشحن',
    'Delivery Fees': 'رسوم التوصيل',
    'Total': 'الإجمالي',
    'Do You Want Login Or Continue As A Guest?': 'هل تريد تسجيل الدخول أم المتابعة كزائر؟',
    'Continue As Guest': 'المتابعة كزائر',
    'Birthday': 'عيد ميلاد',
    "Mother's Day": 'عيد الأم',

    // Checkout screen
    'Shipping Details': 'تفاصيل الشحن',
    'Products': 'المنتجات',
    'Delivery Method': 'طريقة التوصيل',
    'Delivery To My Address': 'التوصيل إلى عنواني',
    'Pickup From Store': 'الاستلام من المتجر',
    'Payment Method': 'طريقة الدفع',
    'Knet': 'كي نت',
    'Cash On Delivery': 'الدفع عند الاستلام',
    'Pay Now': 'ادفع الآن',
    'Set Your Location': 'حدد موقعك',
    'Please set your delivery address': 'يرجى تحديد عنوان التوصيل',
    'Coupon applied successfully': 'تم تطبيق الكوبون بنجاح',
    'Invalid coupon code': 'رمز الكوبون غير صالح',
    'Invalid or expired coupon code': 'رمز الكوبون غير صالح أو منتهي الصلاحية',
    'Enter Coupon Discount': 'أدخل رمز الخصم',
    'Submit': 'إرسال',
    'Qty:': 'الكمية:',
    'This coupon requires a minimum order of': 'يتطلب هذا الكوبون حد أدنى للطلب قدره',
    'The QR Code Will Be Displayed Immediately After The Payment Is Completed.':
        'سيتم عرض رمز QR مباشرة بعد إتمام عملية الدفع.',

    // Coupons / Products screens
    'All Categories': 'جميع الفئات',
    'No products found': 'لا توجد منتجات',
    'No coupons found': 'لا توجد كوبونات',
    'Search': 'بحث',

    // Payment success screen
    'Successful Payment': 'تم الدفع بنجاح',
    'Order': 'الطلب',
    'has been placed': 'تم تقديمه',
    'Your Coupon QR Code': 'رمز QR للكوبون الخاص بك',
    'Your Coupon QR Codes': 'رموز QR للكوبونات الخاصة بك',
    'Back To Home': 'العودة للرئيسية',
    'View Order': 'عرض الطلب',

    // Login screen
    'LOGIN': 'تسجيل الدخول',
    'We Provide You With The Latest Products At The Best Price.':
        'نوفر لك أحدث المنتجات بأفضل الأسعار.',
    'Email': 'البريد الإلكتروني',
    'Enter Your Email': 'أدخل بريدك الإلكتروني',
    'Enter Password': 'أدخل كلمة المرور',
    'Remember Me': 'تذكرني',
    'Forget Password?': 'نسيت كلمة المرور؟',
    'Login as Super Admin': 'تسجيل الدخول كمسؤول رئيسي',

    // Register screen
    'SIGN UP': 'إنشاء حساب',
    'Enjoy The Best Shopping Experience Through The App.':
        'استمتع بأفضل تجربة تسوق عبر التطبيق.',
    'Full Name': 'الاسم الكامل',
    'Enter Full Name': 'أدخل الاسم الكامل',
    'Enter Email': 'أدخل البريد الإلكتروني',
    'Phone Number': 'رقم الهاتف',
    'Enter Phone Number': 'أدخل رقم الهاتف',
    'Password': 'كلمة المرور',
    'Confirm Password': 'تأكيد كلمة المرور',
    'Accept The Terms And Conditions.': 'الموافقة على الشروط والأحكام.',
    'Sign Up': 'إنشاء حساب',

    // My Address screens
    'My Address': 'عنواني',
    'Add New Address': 'إضافة عنوان جديد',
    "You haven't added an address yet.": 'لم تقم بإضافة عنوان بعد.',
    'Edit': 'تعديل',
    'Add A New Address': 'إضافة عنوان جديد',
    'The House': 'المنزل',
    'The Office': 'المكتب',
    'Other': 'أخرى',
    'Apartment Number': 'رقم الشقة',
    'Apartment Number And Floor / Villa Number': 'رقم الشقة والطابق / رقم الفيلا',
    'Name Of Building': 'اسم المبنى',
    'Name Of Building/Block': 'اسم المبنى / القطعة',
    'Street Name': 'اسم الشارع',
    'Street Name / Landmark': 'اسم الشارع / علامة مميزة',
    'Block Number': 'رقم القطعة',
    'Recipient Details': 'بيانات المستلم',
    'First Name': 'الاسم الأول',
    'Last Name': 'اسم العائلة',
    'A Verification Code Will Be Sent Via WhatsApp To This Mobile Number.':
        'سيتم إرسال رمز التحقق عبر واتساب إلى هذا الرقم.',
    'Save Address': 'حفظ العنوان',
    'Required': 'مطلوب',

    // Coupon detail screen
    'Coupons Details': 'تفاصيل الكوبون',
    'Description': 'الوصف',
    'Expire Date': 'تاريخ الانتهاء',
    'Coupons Left': 'الكوبونات المتبقية',
    'Number Of Cpouons You Want:': 'عدد الكوبونات التي تريدها:',
    'Confirm': 'تأكيد',
    'Quantity set to': 'تم تحديد الكمية إلى',
    'Added to cart!': 'أُضيف إلى السلة!',
    'Days': 'يوم',
    'Hours': 'ساعة',
    'Sec': 'ثانية',

    // My Orders screen
    'My Orders': 'طلباتي',
    'All': 'الكل',
    'Paid': 'مدفوع',
    'Not Paid': 'غير مدفوع',
    'Arrived': 'تم التوصيل',
    'Shipped': 'تم الشحن',
    'Cancelled': 'ملغى',
    'Processing': 'قيد المعالجة',
    'Order Id': 'رقم الطلب',
    'Order Date': 'تاريخ الطلب',
    'Order Status': 'حالة الطلب',
    'View': 'عرض',
    'You Have Not Any Order': 'ليس لديك أي طلبات',

    // Order invoice screen
    'Customer Information': 'بيانات العميل',
    'Invoice Id': 'رقم الفاتورة',
    'Payment Status': 'حالة الدفع',
    'Product\nName': 'اسم\nالمنتج',
    'Qty': 'الكمية',
    'Size': 'المقاس',
    'Color': 'اللون',
    'Price': 'السعر',

    // My Coupons screen
    'My Coupons': 'كوبوناتي',
    'No coupons yet': 'لا توجد كوبونات بعد',
    'Used': 'مستخدم',
    'Active': 'نشط',

    // Edit profile screen
    'Edit Name & Email': 'تعديل الاسم والبريد الإلكتروني',
    'Phone': 'الهاتف',
    'Email cannot be changed': 'لا يمكن تغيير البريد الإلكتروني',
    'Update': 'تحديث',
    'Profile updated': 'تم تحديث الملف الشخصي',
    'Failed to update': 'فشل التحديث',

    // Guest checkout screen
    'Continue As A Guest': 'المتابعة كزائر',
    'Enjoy The Best Shopping Experience\nThrough The App.':
        'استمتع بأفضل تجربة تسوق\nعبر التطبيق.',
    'Save': 'حفظ',

    // Change password screen
    'Old Password': 'كلمة المرور القديمة',
    'New Password': 'كلمة المرور الجديدة',
    'Confirm New Password': 'تأكيد كلمة المرور الجديدة',
    'Update Password': 'تحديث كلمة المرور',

    // Misc validation / network messages
    'Address not found': 'العنوان غير موجود',
    'Passwords do not match': 'كلمات المرور غير متطابقة',
    'Network error. Please try again.': 'خطأ في الشبكة. حاول مرة أخرى.',
    'New passwords do not match': 'كلمات المرور الجديدة غير متطابقة',
    'Password updated': 'تم تحديث كلمة المرور',
    'Confirm Location': 'تأكيد الموقع',
    'Please enter your name and phone number': 'يرجى إدخال اسمك ورقم هاتفك',
    'Please set your delivery location': 'يرجى تحديد موقع التوصيل',

    // Profile footer
    'Powered By Teknulugy.': 'مقدم من تكنولوجي.',

    // New password / forgot password / OTP screens
    'NEW PASSWORD': 'كلمة مرور جديدة',
    'OTP CODE': 'رمز التحقق',
    'Please Enter Your Email To Receive A Verification Code.':
        'يرجى إدخال بريدك الإلكتروني لتلقي رمز التحقق.',
    'Enter 4-Digit Code': 'أدخل الرمز المكون من 4 أرقام',
    'A 4-Digit Verification Code Has Been Sent To This Phone Number. ':
        'تم إرسال رمز تحقق مكون من 4 أرقام إلى رقم الهاتف هذا. ',
    'Invalid Verification Code.': 'رمز التحقق غير صحيح.',
    'Testing mode: enter 1234 to continue.': 'وضع الاختبار: أدخل 1234 للمتابعة.',
    'Remaining ': 'متبقي ',
    'Resend Code?': 'إعادة إرسال الرمز؟',
    'Continue': 'متابعة',

    // Search screen
    'SEARCH': 'بحث',
    'Search products...': 'ابحث عن المنتجات...',
    'No results found': 'لا توجد نتائج',

    // Product detail screen
    'Out of stock': 'غير متوفر',

    // Address method sheet
    'Pick On Map': 'تحديد على الخريطة',
    'Enter Manually': 'إدخال يدوي',

    // Skeleton loader
    'Retry': 'إعادة المحاولة',
    "Couldn't load data. Check your connection and try again.":
        'تعذر تحميل البيانات. تحقق من اتصالك وحاول مرة أخرى.',
  };
}

extension TrX on String {
  /// Returns the Arabic translation of this string when the app's current
  /// locale is Arabic and a translation is defined, otherwise returns the
  /// string unchanged.
  String tr(BuildContext context) {
    final code = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    if (code != 'ar') return this;
    return AppStrings.ar[this] ?? this;
  }
}
