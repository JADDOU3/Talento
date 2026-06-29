enum Mindset {
  builder,
  scientist,
  explorer,
  inventor;

  String get apiValue => name.toUpperCase();
}

enum KitType {
  discovery,
  hobby,
  development;

  String get apiValue => name.toUpperCase();

  String get arabicLabel {
    switch (this) {
      case KitType.discovery:
        return 'الاستكشاف';
      case KitType.hobby:
        return 'الهواية';
      case KitType.development:
        return 'التطوير';
    }
  }
}

String kitTypeArabicLabel(String? type) {
  switch ((type ?? '').toUpperCase()) {
    case 'DISCOVERY':
      return 'الاستكشاف';
    case 'HOBBY':
      return 'الهواية';
    case 'DEVELOPMENT':
      return 'التطوير';
    default:
      return '';
  }
}
