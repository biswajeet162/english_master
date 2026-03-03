import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/dependency_injection.dart';
import 'core/config/api_config.dart';
import 'core/utils/logger.dart';
import 'presentation/screens/voice_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize dependencies
    await initializeDependencies();
    
    // Check API configuration
    if (!ApiConfig.isConfigured) {
      AppLogger.warning('API configuration incomplete. Please check your .env file.');
      final configStatus = ApiConfig.configurationStatus;
      AppLogger.info('Configuration status: $configStatus');
    }
    
    AppLogger.info('Application starting successfully');
  } catch (e) {
    AppLogger.error('Failed to initialize application: $e');
  }
  
  runApp(const ProviderScope(child: EnglishTutorApp()));
}

class EnglishTutorApp extends StatelessWidget {
  const EnglishTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI English Voice Tutor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16213e),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3282b8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3282b8),
          secondary: Color(0xFF0f4c75),
          surface: Color(0xFF16213e),
          background: Color(0xFF1a1a2e),
        ),
      ),
      home: const VoiceChatScreen(),
    );
  }
}
