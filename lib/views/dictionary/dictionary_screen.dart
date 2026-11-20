import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/word_entry.dart';
import '../../services/game_state_provider.dart';
import '../../services/dictionary_repository.dart';
import '../../theme/editorial_theme.dart';

class DictionaryScreen extends StatefulWidget {
  final bool embedded;

  const DictionaryScreen({super.key, this.embedded = false});

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

    final bodyContent = Column(
      children: [
        // Open typographic léxico summary strip (no heavy icon box)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${solvedIds.length} / ${allWords.length} Términos",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: EditorialTheme.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _showOnlySolved = !_showOnlySolved),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _showOnlySolved ? EditorialTheme.inkDark : EditorialTheme.surface,
                        border: Border.all(
                          color: _showOnlySolved ? EditorialTheme.inkDark : EditorialTheme.borderLine,
                          width: 0.9,
                        ),
                      ),
                      child: Text(
                        _showOnlySolved ? "MI LÉXICO" : "VER TODO",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.9,
                          color: _showOnlySolved ? EditorialTheme.surface : EditorialTheme.inkDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: allWords.isEmpty ? 0 : solvedIds.length / allWords.length,
                    backgroundColor: EditorialTheme.borderLine.withValues(alpha: 0.6),
                    color: EditorialTheme.primary,
                    minHeight: 3,
                  ),
                ],
              ),
            ),

            // Search Bar (open bottom-ruled editorial input)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Buscar palabra o significado...",
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: EditorialTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search_sharp, color: EditorialTheme.textSecondary, size: 19),
                  filled: true,
                  fillColor: EditorialTheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: EditorialTheme.borderLine, width: 0.9),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: EditorialTheme.borderLine, width: 0.9),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: EditorialTheme.inkDark, width: 1.1),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Open Editorial Underline Tabs for Categories
            Container(
              height: 32,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: EditorialTheme.borderLine, width: 0.8),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? EditorialTheme.inkDark : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Text(
                          cat.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            letterSpacing: 0.9,
                            color: isSelected ? EditorialTheme.inkDark : EditorialTheme.textSecondary,
                          ),
                        ),
                      ),
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          onTap: () => _showWordDetailBottomSheet(context, word, isSolved),
                          leading: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSolved ? EditorialTheme.inkDark : EditorialTheme.background,
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: isSolved ? EditorialTheme.inkDark : EditorialTheme.borderLine,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              isSolved ? Icons.check_sharp : Icons.lock_outline,
                              color: isSolved ? EditorialTheme.surface : EditorialTheme.textSecondary,
                              size: 18,
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
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: EditorialTheme.surface,
                              borderRadius: BorderRadius.zero,
                              border: Border.all(color: EditorialTheme.borderLine, width: 1),
                            ),
                            child: Text(
                              word.category.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: EditorialTheme.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );

    if (widget.embedded) return bodyContent;

    return Scaffold(
      backgroundColor: EditorialTheme.background,
      appBar: AppBar(
        backgroundColor: EditorialTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, size: 20, color: EditorialTheme.inkDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Diccionario",
          style: GoogleFonts.libreBaskerville(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EditorialTheme.inkDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: EditorialTheme.borderLine),
        ),
      ),
      body: SafeArea(child: bodyContent),
    );
  }

  void _showWordDetailBottomSheet(BuildContext context, WordEntry word, bool isSolved) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EditorialTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: EditorialTheme.inkDark, width: 2.5)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: EditorialTheme.inkDark,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Text(
                      word.category.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: EditorialTheme.surface,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: EditorialTheme.inkDark, width: 1.0),
                      ),
                      child: const Icon(Icons.close, color: EditorialTheme.inkDark, size: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                isSolved ? word.word : "PALABRA BLOQUEADA",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
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

              const SizedBox(height: 12),
              EditorialTheme.doubleRule(color: EditorialTheme.inkDark),
              const SizedBox(height: 12),

              Text(
                "DEFINICIÓN EDITORIAL",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: EditorialTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isSolved ? word.clue : "Esta palabra se desbloqueará una vez que la resuelvas en cualquiera de los crucigramas del juego.",
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  color: EditorialTheme.textPrimary,
                  height: 1.38,
                ),
              ),

              if (isSolved && word.example.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: const BoxDecoration(
                    color: EditorialTheme.background,
                    borderRadius: BorderRadius.zero,
                    border: Border(
                      left: BorderSide(color: EditorialTheme.accent, width: 3.0),
                      top: BorderSide(color: EditorialTheme.borderLine, width: 0.8),
                      right: BorderSide(color: EditorialTheme.borderLine, width: 0.8),
                      bottom: BorderSide(color: EditorialTheme.borderLine, width: 0.8),
                    ),
                  ),
                  child: Text(
                    "\"${word.example}\"",
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: EditorialTheme.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
