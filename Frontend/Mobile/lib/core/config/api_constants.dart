class ApiConstants {
  static const String baseUrl = 'http://15.224.101.253/api';

  // Auth
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String refresh = '$baseUrl/refresh';
  static const String isNewUser = '$baseUrl/isNewUser';

  // Kits
  static const String kits = '$baseUrl/kits';
  static const String kitsByType = '$baseUrl/kits/type';
  static const String kitsByMindset = '$baseUrl/kits/mindset';
  static const String kitsSearch = '$baseUrl/kits/search';
  static String kitsByChild(int childId) => '$baseUrl/kits/child/$childId';

  // Home / Sessions / Activities / Level Attempts
  static String sessionsByChild(int childId) =>
      '$baseUrl/sessions/child/$childId';

  static String activitiesByKit(int kitId) =>
      '$baseUrl/activities/kit/$kitId';

  static String levelAttemptsByActivitySession(int activitySessionId) =>
      '$baseUrl/level-attempts/activity-session/$activitySessionId';


  static const String posts = '$baseUrl/posts';
  static const String myPosts = '$baseUrl/posts/my';
  static const String postsByMindset = '$baseUrl/posts/mindset';
  static const String postsByKit = '$baseUrl/posts/kit';

  // Media
  static const String mediaUpload = '$baseUrl/media/upload';

  // Likes
  static const String likesToggle = '$baseUrl/likes/toggle';
  static const String likesPost = '$baseUrl/likes/post';

  // Comments
  static const String comments = '$baseUrl/comments';
  static const String commentsByPost = '$baseUrl/comments/post';

  // Profile / Children
  static const String currentUser = '$baseUrl/currentUser';
  static const String children = '$baseUrl/children';
  static const String addChild = '$baseUrl/children/';
  static const String selectedChild = '$baseUrl/children/selected';

  static String setSelectedChild(int childId) =>
      '$baseUrl/children/selected/$childId';
}