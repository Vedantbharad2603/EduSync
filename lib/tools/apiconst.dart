class Apiconst {
  static String get baseurl =>
      "https://smart-classmate-server.onrender.com/api/";
  //live api baseurl "https://smart-classmate-server.onrender.com/"
  //Emulator baseurl "http://10.0.2.2:3000/"
  // static String get baseurl => "http://laptopip:3000/"

  static String logincheck = '${baseurl}login/check';
  static String addLogindata = '${baseurl}login';
  static String changeLoginstatus = '${baseurl}login/change';
  static String changeType = '${baseurl}login/changeType';
  static String giveuserlogin = '${baseurl}login/username';
  static String getTeacher = '${baseurl}login/getTeacher';
  static String findemail = '${baseurl}login/find';
  static String givestudProfile = '${baseurl}login/getStudProfile';

  static String addTeacher = '${baseurl}teacher';
  static String updateTeacher = '${baseurl}teacher/update';

  static String addStudent = '${baseurl}student';
  static String getStudent = '${baseurl}student/getstud';
  static String updateStudent = '${baseurl}student/update';

  static String getCourses = '${baseurl}courses';
  static String addCourses = '${baseurl}courses';
  static String listallCourses = '${baseurl}courses';
  static String getCourseinfo = '${baseurl}courses/find';
  static String updateCourse = '${baseurl}courses/update';

  static String addCourseLevels = '${baseurl}courselevels';
  static String getCourseLevels = '${baseurl}courselevels/getlevels';

  static String addTodayAttendance = '${baseurl}attendance';
  static String getTodayAttendance = '${baseurl}attendance/getToday';
  static String updateAttendance = '${baseurl}attendance/update';
  static String getStudAttendance = '${baseurl}attendance/student';

  static String addCourseConcepts = '${baseurl}courseconcepts';
  static String getConcepts = '${baseurl}courseconcepts/getconcepts';
  static String updateConcepts = '${baseurl}courseconcepts/update';

  static String addEnrollment = '${baseurl}courseenrollment';

  static String addholidays = '${baseurl}holidays';
  static String getholidays = '${baseurl}holidays';
  static String upcomingholiday = '${baseurl}holidays/upcoming';
  static String updateHoliday = '${baseurl}holidays/update';

  static String addHomeWork = '${baseurl}homework';
  static String getStudentAllWork = '${baseurl}homework/studentall';
  static String listworkTeacher = '${baseurl}homework/checkwork';
  static String updateWork = '${baseurl}homework/update';

  static String findShift = '${baseurl}shift/find';
  static String listallShift = '${baseurl}shift';

  static String listallEvents = '${baseurl}events/upcoming';
  static String addEvent = '${baseurl}events';
}
