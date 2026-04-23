enum KitType {
  discovery,
  hobby,
  development;

  String get apiValue => name.toUpperCase();
}

enum Mindset {
  builder,
  scientist,
  explorer,
  inventor;

  String get apiValue => name.toUpperCase();
}