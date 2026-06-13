class ApiConstants {
  static const String baseUrl = 'https://talentokids.com/api';

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

  // Roadmap
  static String roadmapByKitAndChild(int kitId, int childId) =>
      '$baseUrl/roadmap/kit/$kitId/child/$childId';

  // Posts
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

  // Child Mode
  static const String isChildMode = '$baseUrl/isChildMode';
  static const String childModeHasPin = '$baseUrl/childMode/hasPin';
  static const String childModeEnable = '$baseUrl/childMode/enable';
  static const String childModeDisable = '$baseUrl/childMode/disable';
  static const String childModeSetPin = '$baseUrl/childMode/setPin';




  // Sessions
  static const String sessions = '$baseUrl/sessions/';
  static String endSession(int sessionId) =>
      '$baseUrl/sessions/$sessionId/end';

  // Activity Sessions
  static const String activitySessions = '$baseUrl/activity-sessions/';
  static String updateActivitySession(int activitySessionId) =>
      '$baseUrl/activity-sessions/$activitySessionId';

  // Levels
  static String levelsByActivity(int activityId) =>
      '$baseUrl/levels/activity/$activityId';

  // Level Attempts
  static const String levelAttempts = '$baseUrl/level-attempts';
  static String updateLevelAttempt(int attemptId) =>
      '$baseUrl/level-attempts/$attemptId';

  // Events
  static const String eventsActivity = '$baseUrl/events/activity';
  static const String eventsLevel = '$baseUrl/events/level';
}