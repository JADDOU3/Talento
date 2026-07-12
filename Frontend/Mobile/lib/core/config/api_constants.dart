class ApiConstants {
  static const String baseUrl = 'https://talentokids.com/api';

  // Auth
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String refresh = '$baseUrl/refresh';
  static const String isNewUser = '$baseUrl/isNewUser';

  // Kits
  static const String kits = '$baseUrl/kits';
  static const String mindsets = '$baseUrl/mindsets';
  static const String kitsByType = '$baseUrl/kits/type';
  static const String kitsByMindset = '$baseUrl/kits/mindset';
  static const String kitsSearch = '$baseUrl/kits/search';
  static const String addKitToChild = '$baseUrl/kits/child/';

  static String kitsByChild(int childId) => '$baseUrl/kits/child/$childId';

  // Home / Sessions / Activities / Level Attempts
  static String sessionsByChild(int childId) =>
      '$baseUrl/sessions/child/$childId';

  static String activitiesByKit(int kitId) =>
      '$baseUrl/activities/kit/$kitId';

  static String levelAttemptsByActivitySession(int activitySessionId) =>
      '$baseUrl/level-attempts/activity-session/$activitySessionId';

  // Home real-data endpoints
  static const String roadmapLastReached =
      '$baseUrl/roadmap/progress/last-reached';

  static const String roadmapCompletedCount =
      '$baseUrl/roadmap/progress/completed-count';

  static const String dailyChallenge =
      '$baseUrl/daily-challenge';

  static const String dailyChallengeAnswer =
      '$baseUrl/daily-challenge/answer';

  // Mirror Mind / Activity Runtime / Color Lab — shared endpoints
  static const String sessions = '$baseUrl/sessions/';
  static const String activitySessions = '$baseUrl/activity-sessions/';
  static const String levelAttempts = '$baseUrl/level-attempts';
  static const String activityEvents = '$baseUrl/events/activity';
  static const String levelEvents = '$baseUrl/events/level';
  static const String voiceTranscribeWithKeywords =
      '$baseUrl/voice/transcribe-with-keywords';

  // Story submissions
  static String storySubmissionCountByActivityAndChild(
      int activityId,
      int childId,
      ) =>
      '$baseUrl/story-submissions/count/by-activity/$activityId/child/$childId';

  static String storySubmissionsByActivityAndChild(
      int activityId,
      int childId,
      ) =>
      '$baseUrl/story-submissions/by-activity/$activityId/child/$childId';

  static String endSession(int sessionId) =>
      '$baseUrl/sessions/$sessionId/end';

  static String activitySessionById(int activitySessionId) =>
      '$baseUrl/activity-sessions/$activitySessionId';

  static String levelsByActivity(int activityId) =>
      '$baseUrl/levels/activity/$activityId';

  static String levelAttemptById(int attemptId) =>
      '$baseUrl/level-attempts/$attemptId';

  // ---- Color Lab aliases (same endpoints, names used by color_lab_service) ----
  static const String eventsActivity = '$baseUrl/events/activity';
  static const String eventsLevel = '$baseUrl/events/level';

  static String updateActivitySession(int activitySessionId) =>
      activitySessionById(activitySessionId);

  static String updateLevelAttempt(int attemptId) =>
      levelAttemptById(attemptId);

  // Roadmap
  static String roadmapByKitAndChild(int kitId, int childId) =>
      '$baseUrl/roadmap/kit/$kitId/child/$childId';

  static String roadmapProgress(int activityId) =>
      '$baseUrl/roadmap/progress/$activityId';

  static String roadmapCardById(int cardId) =>
      '$baseUrl/roadmap-cards/$cardId';

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

  static String likeCount(int postId) =>
      '$baseUrl/likes/post/$postId/count';

  static String isPostLiked(int postId, int parentId) =>
      '$baseUrl/likes/post/$postId/liked?parentId=$parentId';

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

// Coins
  static const String coins = '$baseUrl/coins';

  // POST /api/coins/maze-collect?count={count}

  static String coinsMazeCollect(int count) =>
      Uri.parse('$baseUrl/coins/maze-collect')
          .replace(queryParameters: {'count': '$count'})
          .toString();

  // Child Mode
  static const String isChildMode = '$baseUrl/isChildMode';
  static const String childModeHasPin = '$baseUrl/childMode/hasPin';
  static const String childModeEnable = '$baseUrl/childMode/enable';
  static const String childModeDisable = '$baseUrl/childMode/disable';
  static const String childModeSetPin = '$baseUrl/childMode/setPin';

  // Journal / AI Reports
  static String aiReportLatest(int childId) =>
      '$baseUrl/ai-reports/child/$childId/latest';

  static String aiReportByVersion(int childId, String version) =>
      '$baseUrl/ai-reports/child/$childId/version/${Uri.encodeComponent(version)}';

  static const String aiReportsWeeklySessions =
      '$baseUrl/ai-reports/weekly-sessions';

  static String performanceByChild(int childId) =>
      '$baseUrl/performance/child/$childId';
}