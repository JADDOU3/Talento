/// Arabic localization for Emotion Chain content.
///
/// The backend currently stores prompts/questions in English. Until the Arabic
/// content is added on the backend, this maps the text to Arabic on the client
/// so the activity reads in Arabic (matching the design doc).
///
/// - Questions are formulaic (by chainStep / character) so they are translated
///   reliably.
/// - Prompts are matched by an exact dictionary first, then by keywords; if a
///   scenario isn't recognised we keep the original text.
class EmotionChainAr {
  static String _norm(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  // ---------------------------------------------------------------------------
  // Questions
  // ---------------------------------------------------------------------------

  static String question({
    required String original,
    required String chainStep,
    int? character,
  }) {
    if (_isArabic(original)) return original;

    switch (chainStep.toLowerCase()) {
      case 'feeling':
        if (character == 1) return 'كيف يشعر الطفل الأول؟';
        if (character == 2) return 'كيف يشعر الطفل الثاني؟';
        return 'كيف يشعر؟';
      case 'action':
        return 'ماذا ستفعل؟';
      case 'outcome':
        return 'ماذا ستكون النتيجة؟';
    }

    // Known exact questions.
    final norm = _norm(original);
    const map = {
      'what will you do?': 'ماذا ستفعل؟',
      'how do they feel?': 'كيف يشعر؟',
      'why do they feel this?': 'لماذا يشعر هكذا؟',
      'what will they do?': 'ماذا سيفعل؟',
    };
    return map[norm] ?? original;
  }

  // ---------------------------------------------------------------------------
  // Prompts
  // ---------------------------------------------------------------------------

  static String prompt({required String original}) {
    if (original.trim().isEmpty || _isArabic(original)) return original;

    final norm = _norm(original);

    // Exact matches (from the design doc).
    const exact = {
      'a child trips and falls in front of other children who are watching. the fallen child looks hurt and embarrassed.':
          'طفل يتعثّر ويقع أمام أطفال آخرين ينظرون إليه، ويبدو الطفل الواقع متألّماً ومُحرَجاً.',
      'both children are still standing there, each holding one side of the toy.':
          'ما زال الطفلان واقفين، وكلّ واحد يمسك طرفاً من اللعبة.',
    };
    if (exact.containsKey(norm)) return exact[norm]!;

    // Keyword heuristics for common scenarios in the doc.
    if (_has(norm, ['trip', 'fall', 'fell'])) {
      return 'طفل وقع على الأرض أثناء اللعب، والأطفال ينظرون إليه.';
    }
    if (_has(norm, [
      'same toy',
      'same ball',
      'both want',
      'same game',
      'one side of the toy',
      'holding the toy',
      'each holding',
    ])) {
      return 'طفلان يريدان نفس اللعبة، وكلّ واحد يمسك طرفاً منها.';
    }
    if (_has(norm, ['tower', 'blocks', 'build'])) {
      return 'طفلة تبني برجاً من المكعبات، وبعد جهد كبير يسقط البرج فجأة.';
    }
    if (_has(norm, ['ice cream', 'icecream'])) {
      return 'طفل يحمل آيس كريم، وفجأة يسقط الآيس كريم على الأرض.';
    }
    if (_has(norm, ['alone', 'bench', 'by himself', 'new school', 'new kid'])) {
      return 'طفل يجلس وحده بينما يلعب باقي الأطفال.';
    }

    // Unknown scenario -> keep original (so we never show wrong Arabic).
    return original;
  }

  static bool _has(String text, List<String> keys) =>
      keys.any((k) => text.contains(k));

  /// Treat as Arabic if it already contains Arabic letters.
  static bool _isArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);
}
