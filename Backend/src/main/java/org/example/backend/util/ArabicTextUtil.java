package org.example.backend.util;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public final class ArabicTextUtil {

    private static final Pattern DIACRITICS = Pattern.compile(
            "[\\u064B-\\u065F\\u0670\\u06D6-\\u06ED\\u0640]"
    );

    private ArabicTextUtil() {
    }

    public static String normalize(String text) {
        if (text == null) {
            return "";
        }

        String normalized = Normalizer.normalize(text, Normalizer.Form.NFKC);
        normalized = DIACRITICS.matcher(normalized).replaceAll("");

        normalized = normalized
                .replace('\u0623', '\u0627') // أ -> ا
                .replace('\u0625', '\u0627') // إ -> ا
                .replace('\u0622', '\u0627') // آ -> ا
                .replace('\u0629', '\u0647') // ة -> ه
                .replace('\u0649', '\u064A'); // ى -> ي

        normalized = normalized.trim().replaceAll("\\s+", " ");
        return normalized.toLowerCase();
    }

    public static List<String> findMissingKeywords(String text, List<String> keywords) {
        List<String> missing = new ArrayList<>();
        if (keywords == null || keywords.isEmpty()) {
            return missing;
        }

        String normalizedText = normalize(text);
        for (String keyword : keywords) {
            if (keyword == null || keyword.isBlank()) {
                continue;
            }
            String normalizedKeyword = normalize(keyword);
            if (!normalizedText.contains(normalizedKeyword)) {
                missing.add(keyword);
            }
        }
        return missing;
    }
}