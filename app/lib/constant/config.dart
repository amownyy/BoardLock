class ApiConfig {
  static String baseUrl = 'http://localhost:3000/api/v1';

  static String getSchoolsUrl = '$baseUrl/school/';

  static String getUpdateUrl = '$baseUrl/update';

  static String getBoardsUrl(String schoolId) => '$baseUrl/board/$schoolId/';

  static String setBoardActiveUrl(String schoolId, String boardId) =>
      '$baseUrl/board/$schoolId/$boardId/activate/';

  static String shutDownBoardUrl(String schoolId, String boardId) =>
      '$baseUrl/board/$schoolId/$boardId/shutdown/';

  static String restartBoardUrl(String schoolId, String boardId) =>
      '$baseUrl/board/$schoolId/$boardId/restart/';
}
