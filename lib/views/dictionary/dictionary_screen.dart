import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/word_entry.dart';
import '../../services/game_state_provider.dart';
import '../../services/dictionary_repository.dart';
import '../../theme/editorial_theme.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  bool _showOnlySolved = true;

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final repo = DictionaryRepository();
    final allWords = repo.allWords;
    final solvedIds = gameState.solvedWordIds;
    final categories = repo.getCategories();

    // Filter list based on search and selected category
    List<WordEntry> filteredWords = repo.searchWords(_searchQuery, categoryFilter: _selectedCategory);

    if (_showOnlySolved) {
      filteredWords = filteredWords.where((w) => solvedIds.contains(w.id)).toList();
    }

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      appBar: AppBar(
        title: Text(
          "DICCIONARIO EDITORIAL",
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlySolved ? Icons.lock_clock : Icons.public,
              color: EditorialTheme.primary,
            ),
            tooltip: _showOnlySolved ? "Mostrando solo descubiertas" : "Mostrando todo el catálogo",
            onPressed: () {
              setState(() => _showOnlySolved = !_showOnlySolved);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner statistics
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: EditorialTheme.newspaperCardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: EditorialTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_stories, color: EditorialTheme.surface, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LÉXICO DESCUBIERTO",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: EditorialTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${solvedIds.length} de ${allWords.length} Términos",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: EditorialTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: allWords.isEmpty ? 0 : solvedIds.length / allWords.length,
                            backgroundColor: EditorialTheme.borderLine,
                            color: EditorialTheme.primary,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Buscar palabra o significado...",
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: EditorialTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: EditorialTheme.primary),
                  filled: true,
                  fillColor: EditorialTheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: EditorialTheme.borderLine),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: EditorialTheme.borderLine),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: EditorialTheme.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Horizontal Categories Filter Chips
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: EditorialTheme.primary,
                      checkmarkColor: EditorialTheme.surface,
                      backgroundColor: EditorialTheme.surface,
                      labelStyle: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? EditorialTheme.surface : EditorialTheme.textPrimary,
                      ),
                      onSelected: (val) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Words List
            Expanded(
              child: filteredWords.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.book_outlined, size: 48, color: EditorialTheme.borderLine),
                            const SizedBox(height: 12),
                            Text(
                              _showOnlySolved
                                  ? "Aún no has descubierto palabras en esta categoría.\n¡Juega un crucigrama para desbloquearlas!"
                                  : "No se encontraron términos coincidentes.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: EditorialTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: filteredWords.length,
                      separatorBuilder: (ctx, i) => const Divider(color: EditorialTheme.borderLine, height: 1),
                      itemBuilder: (ctx, i) {
                        final word = filteredWords[i];
                        final isSolved = solvedIds.contains(word.id);

                        return ListTile(
                          onTap: () => _showWordDetailBottomSheet(context, word, isSolved),
                          leading: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSolved ? EditorialTheme.primary : EditorialTheme.borderLine,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isSolved ? Icons.check_circle_outline : Icons.lock_outline,
                              color: isSolved ? EditorialTheme.surface : EditorialTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            isSolved ? word.word : "• • • • • • •",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSolved ? EditorialTheme.textPrimary : EditorialTheme.textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            isSolved ? word.clue : "Resuelve un crucigrama para revelar el significado.",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: EditorialTheme.textSecondary,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: EditorialTheme.background,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: EditorialTheme.borderLine),
                            ),
                            child: Text(
                              word.category,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: EditorialTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWordDetailBottomSheet(BuildContext context, WordEntry word, bool isSolved) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EditorialTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: EditorialTheme.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      word.category.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: EditorialTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: EditorialTheme.primary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                isSolved ? word.word : "PALABRA BLOQUEADA",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.textPrimary,
                ),
              ),

              if (isSolved && word.etymology.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  word.etymology,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: EditorialTheme.primary,
                  ),
                ),
              ],

              const Divider(color: EditorialTheme.borderLine, height: 24),

              Text(
                "Definición Editorial:",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: EditorialTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isSolved ? word.clue : "Esta palabra se desbloqueará una vez que la resuelvas en cualquiera de los crucigramas del juego.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: EditorialTheme.textPrimary,
                  height: 1.3,
                ),
              ),

              if (isSolved && word.example.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EditorialTheme.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: EditorialTheme.borderLine),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote, color: EditorialTheme.accent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          word.example,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: EditorialTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
