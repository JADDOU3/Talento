class ApiConstants {
  static const String baseUrl = 'http://15.224.101.253/api';

  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String refresh = '$baseUrl/refresh';

  static const String kits = '$baseUrl/kits';
  static const String kitsByType = '$baseUrl/kits/type';
  static const String kitsByMindset = '$baseUrl/kits/mindset';
  static const String kitsSearch = '$baseUrl/kits/search';


  static const String posts = '$baseUrl/posts';
  static const String myPosts = '$baseUrl/posts/my';
  static const String postsByMindset = '$baseUrl/posts/mindset';
  static const String postsByKit = '$baseUrl/posts/kit';


  static const String likesToggle = '$baseUrl/likes/toggle';
  static const String likesPost = '$baseUrl/likes/post';


  static const String comments = '$baseUrl/comments';
  static const String commentsByPost = '$baseUrl/comments/post';
}