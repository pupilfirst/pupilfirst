[%bs.raw {|require("./CoursesCurriculum__StudentReport.css")|}];
open CoursesCurriculum__Types;

let str = React.string;

type studentData =
  | Loading
  | Loaded(ReportData.t);

type state = {studentData};

let initialState = {studentData: Loading};

module StudentDetailsQuery = [%graphql
  {|
    query StudentDetailsQuery($studentId: ID!) {
      studentDetails(studentId: $studentId) {
        email, phone, socialLinks,
        evaluationCriteria {
          id, name, maxGrade, passGrade
        },
        team {
          id
          name
          levelId
          students {
            id
            name
            title
            avatarUrl
          }
          coachUserIds
        }
        socialLinks
        totalTargets
        targetsCompleted
        completedLevelIds
        quizScores
        averageGrades {
          evaluationCriterionId
          averageGrade
        }
      }
    }
  |}
];

let updateStudentData = (setState, studentId, details) => {
  setState(_state =>
    {studentData: Loaded(details |> ReportData.makeFromJs(studentId))}
  );
};

let getStudentData = (studentId, setState, ()) => {
  setState(_state => {studentData: Loading});
  StudentDetailsQuery.make(~studentId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##studentDetails |> updateStudentData(setState, studentId);
       Js.Promise.resolve();
     })
  |> ignore;

  None;
};
let doughnutChart = (color, percentage) => {
  <svg
    viewBox="0 0 36 36"
    className={"student-overlay__doughnut-chart " ++ color}>
    <path
      className="student-overlay__doughnut-chart-bg"
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <path
      className="student-overlay__doughnut-chart-stroke"
      strokeDasharray={percentage ++ ", 100"}
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <text
      x="50%"
      y="58%"
      className="student-overlay__doughnut-chart-text font-semibold">
      {percentage ++ "%" |> str}
    </text>
  </svg>;
};

let targetsCompletionStatus = (targetsCompleted, totalTargets) => {
  let targetCompletionPercent =
    targetsCompleted /. totalTargets *. 100.0 |> int_of_float |> string_of_int;
  <div ariaLabel="target-completion-status" className="w-full lg:w-1/2 px-2">
    <div className="student-overlay__doughnut-chart-container">
      {doughnutChart("purple", targetCompletionPercent)}
      <p className="text-sm font-semibold text-center mt-3">
        {"Total Targets Completed" |> str}
      </p>
      <p className="text-sm text-gray-700 font-semibold text-center mt-1">
        {(targetsCompleted |> int_of_float |> string_of_int)
         ++ "/"
         ++ (totalTargets |> int_of_float |> string_of_int)
         ++ " Targets"
         |> str}
      </p>
    </div>
  </div>;
};

let quizPerformanceChart = (averageQuizScore, quizzesAttempted) => {
  switch (averageQuizScore) {
  | Some(score) =>
    <div
      ariaLabel="quiz-performance-chart"
      className="w-full lg:w-1/2 px-2 mt-2 lg:mt-0">
      <div className="student-overlay__doughnut-chart-container">
        {doughnutChart("pink", score |> int_of_float |> string_of_int)}
        <p className="text-sm font-semibold text-center mt-3">
          {"Average Quiz Score" |> str}
        </p>
        <p
          className="text-sm text-gray-700 font-semibold text-center leading-tight mt-1">
          {quizzesAttempted ++ " Quizzes Attempted" |> str}
        </p>
      </div>
    </div>
  | None => React.null
  };
};

let studentLevelClasses = (levelNumber, levelCompleted, currentLevelNumber) => {
  let reached =
    levelNumber <= currentLevelNumber
      ? "student-overlay__student-level--reached" : "";

  let current =
    levelNumber == currentLevelNumber
      ? " student-overlay__student-level--current" : "";

  let completed =
    levelCompleted ? " student-overlay__student-level--completed" : "";

  reached ++ current ++ completed;
};

let levelProgressBar = (levelId, levels, levelsCompleted) => {
  let applicableLevels =
    levels
    |> Array.of_list
    |> Js.Array.filter(level => Level.number(level) != 0);

  let courseCompleted =
    applicableLevels
    |> Array.for_all(level => levelsCompleted |> Array.mem(level |> Level.id));

  let currentLevelNumber =
    applicableLevels
    |> ArrayUtils.unsafeFind(
         level => Level.id(level) == levelId,
         "Unable to find level with id" ++ levelId ++ "in StudentOverlay",
       )
    |> Level.number;

  <div className="mb-8">
    <div className="flex justify-between items-end">
      <h6 className="text-sm font-semibold"> {"Level Progress" |> str} </h6>
      {courseCompleted
         ? <p className="text-green-600 font-semibold">
             {{js|🎉|js} |> str}
             <span className="text-xs ml-px">
               {"Course Completed!" |> str}
             </span>
           </p>
         : React.null}
    </div>
    <div className="h-12 flex items-center">
      <ul
        className={
          "student-overlay__student-level-progress flex w-full "
          ++ (
            courseCompleted
              ? "student-overlay__student-level-progress--completed" : ""
          )
        }>
        {applicableLevels
         |> Array.to_list
         |> Level.sort
         |> Array.of_list
         |> Array.map(level => {
              let levelNumber = level |> Level.number;
              let levelCompleted =
                levelsCompleted |> Array.mem(level |> Level.id);

              <li
                key={level |> Level.id}
                className={
                  "flex-1 student-overlay__student-level "
                  ++ studentLevelClasses(
                       levelNumber,
                       levelCompleted,
                       currentLevelNumber,
                     )
                }>
                <span className="student-overlay__student-level-count">
                  {levelNumber |> string_of_int |> str}
                </span>
              </li>;
            })
         |> React.array}
      </ul>
    </div>
  </div>;
};

let test = (value, url) => {
  let tester = Js.Re.fromString(value);
  url |> Js.Re.test_(tester);
};

let averageGradeCharts =
    (
      evaluationCriteria: array(CoursesCurriculum__EvaluationCriterion.t),
      averageGrades: array(ReportData.averageGrade),
    ) => {
  averageGrades
  |> Array.map(grade => {
       let criterion =
         ReportData.evaluationCriterionForGrade(
           grade,
           evaluationCriteria,
           "CoursesStudents__StudentOverlay",
         );
       let passGrade =
         criterion
         |> CoursesCurriculum__EvaluationCriterion.passGrade
         |> float_of_int;
       let averageGrade = grade |> ReportData.gradeValue;
       <div
         ariaLabel={
           "average-grade-for-criterion-"
           ++ (criterion |> CoursesCurriculum__EvaluationCriterion.id)
         }
         key={criterion |> CoursesCurriculum__EvaluationCriterion.id}
         className="flex w-full lg:w-1/2 px-2 mt-2">
         <div className="student-overlay__pie-chart-container">
           <div className="flex px-5 pt-4 text-center items-center">
             <svg
               className={
                 "student-overlay__pie-chart "
                 ++ (
                   averageGrade < passGrade
                     ? "student-overlay__pie-chart--fail"
                     : "student-overlay__pie-chart--pass"
                 )
               }
               viewBox="0 0 32 32">
               <circle
                 className={
                   "student-overlay__pie-chart-circle "
                   ++ (
                     averageGrade < passGrade
                       ? "student-overlay__pie-chart-circle--fail"
                       : "student-overlay__pie-chart-circle--pass"
                   )
                 }
                 strokeDasharray={
                   ReportData.gradeAsPercentage(grade, criterion) ++ ", 100"
                 }
                 r="16"
                 cx="16"
                 cy="16"
               />
             </svg>
             <span className="ml-3 text-lg font-semibold">
               {(grade.grade |> Js.Float.toString)
                ++ "/"
                ++ (criterion.maxGrade |> string_of_int)
                |> str}
             </span>
           </div>
           <p className="text-sm font-semibold px-5 pt-3 pb-4">
             {criterion |> CoursesCurriculum__EvaluationCriterion.name |> str}
           </p>
         </div>
       </div>;
     })
  |> React.array;
};

let socialLinkIconClass = url => {
  switch (url) {
  | url when url |> test("twitter") => "fab fa-twitter"
  | url when url |> test("facebook") => "fab fa-facebook-f"
  | url when url |> test("instagram") => "fab fa-instagram"
  | url when url |> test("youtube") => "fab fa-youtube"
  | url when url |> test("linkedin") => "fab fa-linkedin"
  | url when url |> test("reddit") => "fab fa-reddit"
  | url when url |> test("flickr") => "fab fa-flickr"
  | url when url |> test("github") => "fab fa-github"
  | _unknownUrl => "fas fa-users"
  };
};

let showSocialLinks = socialLinks => {
  <div
    className="inline-flex flex-wrap justify-center text-lg text-gray-800 mt-3 bg-gray-100 px-2 rounded-lg">
    {socialLinks
     |> Array.mapi((index, link) =>
          <a
            className="px-2 py-1 inline-block hover:text-primary-500"
            key={index |> string_of_int}
            target="_blank"
            href=link>
            <i className={socialLinkIconClass(link)} />
          </a>
        )
     |> React.array}
  </div>;
};

let personalInfo = studentDetails => {
  <div className="mt-2 text-center">
    <div
      className="flex flex-wrap justify-center text-xs font-semibold text-gray-800">
      <div className="flex items-center px-2">
        <i className="fas fa-envelope" />
        <p className="ml-2 tracking-wide">
          {studentDetails |> ReportData.email |> str}
        </p>
      </div>
      {switch (studentDetails |> ReportData.phone) {
       | Some(phone) =>
         <div className="flex items-center px-2">
           <i className="fas fa-phone" />
           <p className="ml-2 tracking-wide"> {phone |> str} </p>
         </div>
       | None => React.null
       }}
    </div>
    {let socialLinks = studentDetails |> ReportData.socialLinks;
     socialLinks |> ArrayUtils.isNotEmpty
       ? showSocialLinks(socialLinks) : React.null}
  </div>;
};

let userInfo = (~key, ~avatarUrl, ~name, ~title=?) =>
  <div key className="shadow rounded-lg p-4 flex items-center mt-2">
    {CoursesStudents__TeamCoaches.avatar(avatarUrl, name)}
    <div className="ml-2 md:ml-3">
      <div className="text-sm font-semibold"> {name |> str} </div>
      {switch (title) {
       | Some(title) => <div className="text-xs"> {title |> str} </div>
       | None => React.null
       }}
    </div>
  </div>;

let coachInfo = (users, studentDetails) => {
  let coachUserIds =
    studentDetails |> ReportData.team |> TeamInfo.coachUserIds;

  let coachUsers =
    users |> List.filter(user => Array.mem(User.id(user), coachUserIds));

  let title =
    studentDetails |> ReportData.teamHasManyStudents
      ? "Team Coaches" : "Personal Coaches";

  coachUsers |> ListUtils.isNotEmpty
    ? <div className="mb-8">
        <h6 className="font-semibold"> {title |> str} </h6>
        {coachUsers
         |> List.map(user =>
              userInfo(
                ~key=user |> User.id,
                ~avatarUrl=user |> User.avatarUrl,
                ~name=user |> User.name,
                ~title=?{
                  user |> User.title;
                },
              )
            )
         |> Array.of_list
         |> React.array}
      </div>
    : React.null;
};

let otherTeamMembers = (setState, studentId, studentDetails) =>
  if (studentDetails |> ReportData.teamHasManyStudents) {
    <div className="block mb-8">
      <h6 className="font-semibold"> {"Other Team Members" |> str} </h6>
      {studentDetails
       |> ReportData.team
       |> TeamInfo.otherStudents(studentId)
       |> Array.map(student => {
            let path =
              "/students/" ++ (student |> TeamInfo.studentId) ++ "/report";

            <div className="block" key={student |> TeamInfo.studentId}>
              {userInfo(
                 ~key={
                   student |> TeamInfo.studentId;
                 },
                 ~avatarUrl=student |> TeamInfo.studentAvatarUrl,
                 ~name=student |> TeamInfo.studentName,
                 ~title=student |> TeamInfo.studentTitle,
               )}
            </div>;
          })
       |> React.array}
    </div>;
  } else {
    React.null;
  };

let closeOverlay = courseId =>
  ReasonReactRouter.push("/courses/" ++ courseId ++ "/curriculum");

[@react.component]
let make = (~courseId, ~currentStudentId, ~users, ~levels) => {
  let (state, setState) = React.useState(() => initialState);

  React.useEffect0(() => {
    ScrollLock.activate();
    Some(() => ScrollLock.deactivate());
  });

  React.useEffect1(
    getStudentData(currentStudentId, setState),
    [|currentStudentId|],
  );

  <div
    className="fixed z-30 top-0 left-0 w-full h-full overflow-y-scroll md:overflow-hidden bg-white">
    {switch (state.studentData) {
     | Loaded(studentDetails) =>
       <div className="flex flex-col md:flex-row md:h-screen">
         <div
           className="w-full md:w-2/5 bg-white p-4 md:p-8 md:py-6 2xl:px-16 2xl:py-12 md:overflow-y-auto">
           <div className="student-overlay__student-details relative pb-8">
             <div
               onClick={_ => closeOverlay(courseId)}
               className="absolute z-50 left-0 cursor-pointer top-0 inline-flex p-1 rounded-full bg-gray-200 h-10 w-10 justify-center items-center text-gray-700 hover:text-gray-900 hover:bg-gray-300">
               <Icon className="if i-times-regular text-xl lg:text-2xl" />
             </div>
             <div
               className="student-overlay__student-avatar mx-auto w-18 h-18 md:w-24 md:h-24 text-xs border border-yellow-500 rounded-full overflow-hidden flex-shrink-0">
               {switch (studentDetails |> ReportData.avatarUrl) {
                | Some(avatarUrl) =>
                  <img className="w-full object-cover" src=avatarUrl />
                | None =>
                  <Avatar
                    name={studentDetails |> ReportData.name}
                    className="object-cover"
                  />
                }}
             </div>
             <h2 className="text-lg text-center mt-3">
               {studentDetails |> ReportData.name |> str}
             </h2>
             <p className="text-sm font-semibold text-center mt-1">
               {studentDetails |> ReportData.title |> str}
             </p>
             {personalInfo(studentDetails)}
           </div>
           {levelProgressBar(
              studentDetails |> ReportData.levelId,
              levels,
              studentDetails |> ReportData.completedLevelIds,
            )}
           <div className="mb-8">
             <h6 className="font-semibold"> {"Targets Overview" |> str} </h6>
             <div className="flex -mx-2 flex-wrap mt-2">
               {targetsCompletionStatus(
                  studentDetails |> ReportData.targetsCompleted,
                  studentDetails |> ReportData.totalTargets,
                )}
               {quizPerformanceChart(
                  studentDetails |> ReportData.averageQuizScore,
                  studentDetails |> ReportData.quizzesAttempted,
                )}
             </div>
           </div>
           {studentDetails |> ReportData.averageGrades |> ArrayUtils.isNotEmpty
              ? <div className="mb-8">
                  <h6 className="font-semibold">
                    {"Average Grades" |> str}
                  </h6>
                  <div className="flex -mx-2 flex-wrap">
                    {averageGradeCharts(
                       studentDetails |> ReportData.evaluationCriteria,
                       studentDetails |> ReportData.averageGrades,
                     )}
                  </div>
                </div>
              : React.null}
           {coachInfo(users, studentDetails)}
           {otherTeamMembers(setState, currentStudentId, studentDetails)}
         </div>
         <div
           className="w-full relative md:w-3/5 bg-gray-100 md:border-l pb-6 2xl:pb-12 md:overflow-y-auto">
           <div
             className="sticky top-0 bg-gray-100 pt-2 md:pt-4 px-4 md:px-8 2xl:px-16 2xl:pt-10 z-30"
           />
         </div>
       </div>
     | Loading =>
       <div className="flex flex-col md:flex-row md:h-screen">
         <div className="w-full md:w-2/5 bg-white p-4 md:p-8 2xl:p-16">
           {SkeletonLoading.image()}
           {SkeletonLoading.multiple(
              ~count=2,
              ~element=SkeletonLoading.profileCard(),
            )}
         </div>
         <div
           className="w-full relative md:w-3/5 bg-gray-100 md:border-l p-4 md:p-8 2xl:p-16">
           {SkeletonLoading.contents()}
           {SkeletonLoading.profileCard()}
         </div>
       </div>
     }}
  </div>;
};
