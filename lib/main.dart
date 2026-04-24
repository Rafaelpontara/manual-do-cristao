import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation.dart';
import 'services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientação apenas retrato
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa notificações
  await NotificationService.init();

  // Reagenda notificações caso tenham sido canceladas pelo sistema
  // (reinício do celular, limpeza de memória, otimização de bateria)
  await NotificationService.checkAndReschedule();

  // Verifica se é primeiro uso
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('onboardingComplete') != true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: PalavraVivaApp(isFirstTime: isFirstTime),
    ),
  );
}

class PalavraVivaApp extends StatelessWidget {
  final bool isFirstTime;
  const PalavraVivaApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'Manual do Cristão',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: isFirstTime ? const OnboardingScreen() : const MainNavigation(),
        );
      },
    );
  }
}
