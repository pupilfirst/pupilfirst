[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__StudentOverlay.css")|}];

open CoursesStudents__Types;
let str = React.string;

type selectedTab =
  | Notes
  | Submissions;

type studentData =
  | Loading
  | Loaded(StudentDetails.t);

type state = {
  selectedTab,
  studentData,
};

let closeOverlay = courseId =>
  ReasonReactRouter.push("/courses/" ++ courseId ++ "/students");

module StudentDetailsQuery = [%graphql
  {|
    query($studentId: ID!) {
      studentDetails(studentId: $studentId) {
        title, name,email, phone, socialLinks, avatarUrl, courseCompleted
        evaluationCriteria{
          id, name, maxGrade, passGrade
        },
          coachNotes {
            id
            note
            createdAt
            author {
              id
              name
              title
              avatarUrl
            }
          }
          levelId
          socialLinks
          totalTargets
          targetsCompleted
          quizScores
          averageGrades {
            id
            averageGrade
          }
      }
    }
  |}
];

let updateStudentDetails = (setState, details) => {
  setState(state =>
    {...state, studentData: Loaded(details |> StudentDetails.makeFromJS)}
  );
};
let getStudentDetails = (authenticityToken, studentId, setState, ()) => {
  setState(state => {...state, studentData: Loading});
  StudentDetailsQuery.make(~studentId, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##studentDetails |> updateStudentDetails(setState);
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
  <div className="w-full lg:w-1/2 px-2">
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
    <div className="w-full lg:w-1/2 px-2 mt-2 lg:mt-0">
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

let averageGradeCharts =
    (
      evaluationCriteria: array(EvaluationCriterion.t),
      averageGrades: array(StudentDetails.averageGrade),
    ) => {
  averageGrades
  |> Array.map(grade => {
       let criterion =
         StudentDetails.evaluationCriterionForGrade(
           grade,
           evaluationCriteria,
           "CoursesStudents__StudentOverlay",
         );
       let passGrade =
         criterion |> EvaluationCriterion.passGrade |> float_of_int;
       let averageGrade = grade |> StudentDetails.gradeValue;
       <div
         key={criterion |> EvaluationCriterion.id}
         className="flex w-full lg:w-1/2 px-2 mt-2">
         <div className="student-overlay__pie-chart-container">
           <div className="flex px-5 pt-4 text-center items-center">
             <svg
               className={
                 "student-overlay__pie-chart "
                 ++ (
                   averageGrade > passGrade
                     ? "student-overlay__pie-chart--pass"
                     : "student-overlay__pie-chart--fail"
                 )
               }
               viewBox="0 0 32 32">
               <circle
                 className={
                   "student-overlay__pie-chart-circle "
                   ++ (
                     averageGrade > passGrade
                       ? "student-overlay__pie-chart-circle--pass"
                       : "student-overlay__pie-chart-circle--fail"
                   )
                 }
                 strokeDasharray={
                   StudentDetails.gradeAsPercentage(grade, criterion)
                   ++ ", 100"
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
             {criterion |> EvaluationCriterion.name |> str}
           </p>
         </div>
       </div>;
     })
  |> React.array;
};

let test = (value, url) => {
  let tester = Js.Re.fromString(value);
  url |> Js.Re.test_(tester);
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
          {studentDetails |> StudentDetails.email |> str}
        </p>
      </div>
      {switch (studentDetails |> StudentDetails.phone) {
       | Some(phone) =>
         <div className="flex items-center px-2">
           <i className="fas fa-phone" />
           <p className="ml-2 tracking-wide"> {phone |> str} </p>
         </div>
       | None => React.null
       }}
    </div>
    {
      let socialLinks = studentDetails |> StudentDetails.socialLinks;
      socialLinks |> ArrayUtils.isNotEmpty
        ? showSocialLinks(socialLinks) : React.null;
    }
  </div>;
};

let setSelectedTab = (selectedTab, setState) => {
  setState(state => {...state, selectedTab});
};

let levelProgressBar = (levelId, levels, courseCompleted) => {
  let currentLevelNumber =
    levels
    |> ArrayUtils.unsafeFind(
         level => Level.id(level) == levelId,
         "Unable to find level with id" ++ levelId ++ "in StudentOverlay",
       )
    |> Level.number;
  <div>
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
            courseCompleted ? "student-overlay__student-course-completed" : ""
          )
        }>
        {levels
         |> Level.sort
         |> Array.map(level => {
              let levelNumber = level |> Level.number;
              levelNumber < currentLevelNumber
                ? <li
                    key={level |> Level.id}
                    className="flex-1 student-overlay__student-level student-overlay__student-level--completed">
                    <span className="student-overlay__student-level-count">
                      {levelNumber |> string_of_int |> str}
                    </span>
                  </li>
                : (
                  if (levelNumber == currentLevelNumber) {
                    <li
                      key={level |> Level.id}
                      className={
                        "flex-1 student-overlay__student-level "
                        ++ (
                          courseCompleted
                            ? "student-overlay__student-level--completed"
                            : "student-overlay__student-current-level"
                        )
                      }>
                      <span className="student-overlay__student-level-count">
                        {levelNumber |> string_of_int |> str}
                      </span>
                    </li>;
                  } else {
                    <li
                      key={level |> Level.id}
                      className="flex-1 student-overlay__student-level">
                      <span className="student-overlay__student-level-count">
                        {levelNumber |> string_of_int |> str}
                      </span>
                    </li>;
                  }
                );
            })
         |> React.array}
      </ul>
    </div>
  </div>;
};
let addNoteCB = (setState, studentDetails, note) => {
  setState(state =>
    {
      ...state,
      studentData: Loaded(StudentDetails.addNewNote(note, studentDetails)),
    }
  );
};

[@react.component]
let make = (~courseId, ~studentId, ~levels) => {
  let (state, setState) =
    React.useState(() => {studentData: Loading, selectedTab: Notes});
  React.useEffect(() => {
    ScrollLock.activate();
    Some(() => ScrollLock.deactivate());
  });
  React.useEffect1(
    getStudentDetails(AuthenticityToken.fromHead(), studentId, setState),
    [|studentId|],
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
               <Icon className="if i-times-light text-xl lg:text-2xl" />
             </div>
             <div
               className="student-overlay__student-avatar mx-auto w-18 h-18 md:w-24 md:h-24 text-xs border border-yellow-500 rounded-full overflow-hidden flex-shrink-0">
               {switch (studentDetails |> StudentDetails.avatarUrl) {
                | Some(avatarUrl) =>
                  <img className="w-full object-cover" src=avatarUrl />
                | None =>
                  <Avatar
                    name={studentDetails |> StudentDetails.name}
                    className="object-cover"
                  />
                }}
             </div>
             <h2 className="text-lg text-center mt-3">
               {studentDetails |> StudentDetails.name |> str}
             </h2>
             <p className="text-sm font-semibold text-center mt-1">
               {studentDetails |> StudentDetails.title |> str}
             </p>
             {personalInfo(studentDetails)}
           </div>
           {levelProgressBar(
              studentDetails |> StudentDetails.levelId,
              levels,
              studentDetails |> StudentDetails.courseCompleted,
            )}
           <div className="mt-8">
             <h6 className="font-semibold"> {"Targets Overview" |> str} </h6>
             <div className="flex -mx-2 flex-wrap mt-2">
               {targetsCompletionStatus(
                  studentDetails |> StudentDetails.targetsCompleted,
                  studentDetails |> StudentDetails.totalTargets,
                )}
               {quizPerformanceChart(
                  studentDetails |> StudentDetails.averageQuizScore,
                  studentDetails |> StudentDetails.quizzesAttempted,
                )}
             </div>
           </div>
           <div className="mt-8">
             <h6 className="font-semibold"> {"Average Grades" |> str} </h6>
             <div className="flex -mx-2 flex-wrap">
               {averageGradeCharts(
                  studentDetails |> StudentDetails.evaluationCriteria,
                  studentDetails |> StudentDetails.averageGrades,
                )}
             </div>
           </div>
         </div>
         <div
           className="w-full relative md:w-3/5 bg-gray-100 md:border-l pb-6 2xl:pb-12 md:overflow-y-auto">
           <div
             className="sticky top-0 bg-gray-100 pt-2 md:pt-4 px-4 md:px-8 2xl:px-16 2xl:pt-10 z-30">
             {<ul className="flex font-semibold border-b text-sm">
                <li
                  onClick={_event => setSelectedTab(Notes, setState)}
                  className={
                    "px-3 py-3 md:py-2 cursor-pointer text-gray-800 rounded-t-lg "
                    ++ (
                      switch (state.selectedTab) {
                      | Notes => "border-b-3 border-primary-500 text-primary-500 -mb-px"
                      | Submissions => "hover:bg-gray-200 hover:text-gray-900"
                      }
                    )
                  }>
                  {"Notes" |> str}
                </li>
                <li
                  onClick={_event => setSelectedTab(Submissions, setState)}
                  className={
                    "px-3 py-3 md:py-2 cursor-pointer text-gray-800 "
                    ++ (
                      switch (state.selectedTab) {
                      | Submissions => "border-b-3 border-primary-500 text-primary-500 -mb-px"
                      | Notes => "hover:bg-gray-200 hover:text-gray-900"
                      }
                    )
                  }>
                  {"Submissions" |> str}
                </li>
              </ul>}
           </div>
           <div className="pt-2 px-4 md:px-8 2xl:px-16">
             {switch (state.selectedTab) {
              | Notes =>
                <CoursesStudents__CoachNotes
                  studentId
                  coachNotes={studentDetails |> StudentDetails.coachNotes}
                  addNoteCB={addNoteCB(setState, studentDetails)}
                />
              | Submissions =>
                <CoursesStudents__SubmissionsList studentId levels />
              }}
           </div>
         </div>
       </div>
     | Loading =>
       <div className="flex flex-col md:flex-row md:h-screen">
         <div
           className="w-full md:w-2/5 bg-white p-4 md:p-8 2xl:p-16">
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
