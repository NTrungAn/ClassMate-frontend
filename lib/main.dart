import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ================= CORE =================
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/services/storage_service.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/class_service.dart';
import 'package:frontend/core/services/attendance_service.dart';
import 'package:frontend/core/services/location_service.dart';

// ================= PROVIDERS =================
import 'package:frontend/providers/auth_provider.dart';

// ================= SCREENS =================
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================== INIT HIVE ==================
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  // ================== INIT SERVICES (BẮT BUỘC) ==================
  await Get.putAsync<StorageService>(() async {
    return await StorageService().init();
  });

  Get.put<ApiService>(ApiService());
  Get.put<AuthService>(AuthService());
  Get.put<ClassService>(ClassService());
  Get.put<AttendanceService>(AttendanceService());
  Get.put<LocationService>(LocationService());

  // ================== INIT PROVIDER ==================
  Get.put<AuthProvider>(AuthProvider());

  runApp(const MyApp());
}

// =======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Classmate QR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primaryColor),
          titleTextStyle: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryColor),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textLight,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// =======================================================

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // ❗ CHỈ DÙNG find – KHÔNG put
    final authProvider = Get.find<AuthProvider>();

    return Obx(() {
      if (authProvider.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          ),
        );
      }

      return authProvider.isLoggedIn.value
          ? const MainScreen()
          : const LoginScreen();
    });
  }
}
