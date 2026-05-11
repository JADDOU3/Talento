class ApiConstants {
  static const String baseUrl = 'http://15.224.101.253/api';


  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String refresh = '$baseUrl/refresh';

  static const String kits = '$baseUrl/kits';
  static const String kitsByType = '$baseUrl/kits/type';
  static const String kitsByMindset = '$baseUrl/kits/mindset';
  static const String kitsSearch = '$baseUrl/kits/search';


  static const String currentUser = '$baseUrl/currentUser';
  static const String children = '$baseUrl/children';
  static const String selectedChild = '$baseUrl/children/selected';
  static String kitsByChild(int childId) => '$baseUrl/kits/child/$childId';
}