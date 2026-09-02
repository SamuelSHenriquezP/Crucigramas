import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_state_provider.dart';
import 'services/dictionary_repository.dart';
import 'theme/editorial_theme.dart';
import 'views/home/home_screen.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure GoogleFonts for robust font fetching and offline caching
  GoogleFonts.config.allowRuntimeFetching = true;

  // Preload 1,000-words dictionary database
  final dictionary = DictionaryRepository();
  await dictionary.loadDictionary();

  runApp(const CrucigramasApp());
}

class CrucigramasApp extends StatelessWidget {
  const CrucigramasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateProvider()),
      ],
      child: MaterialApp(
        title: 'El Crucigramista — Edición Periódico',
        debugShowCheckedModeBanner: false,
        theme: EditorialTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}
