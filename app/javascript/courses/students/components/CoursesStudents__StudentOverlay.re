[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__StudentOverlay.css")|}];

open CoursesStudents__Types;
let str = React.string;

type state =
  | Loading
  | Loaded(StudentDetails.t);

let closeOverlay = courseId =>
  ReasonReactRouter.push("/courses/" ++ courseId ++ "/students");

module StudentDetailsQuery = [%graphql
  {|
    query($studentId: ID!) {
      studentDetails(studentId: $studentId) {
        title, name,email, phone, socialLinks, avatarUrl
        evaluationCriteria{
          id, name, maxGrade, passGrade
        },
          coachNotes {
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
  setState(_ => Loaded(details |> StudentDetails.makeFromJS));
};
let getStudentDetails = (authenticityToken, studentId, setState, ()) => {
  setState(_ => Loading);
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
  <div className="w-1/2 student-overlay__doughnut-chart-container">
    {doughnutChart("purple", targetCompletionPercent)}
    <p className="text-sm font-semibold text-center mt-2">
      {"Total Targets Completed" |> str}
    </p>
    <p className="text-sm text-gray-700 font-semibold text-center mt-1">
      {(targetsCompleted |> int_of_float |> string_of_int)
       ++ "/"
       ++ (totalTargets |> int_of_float |> string_of_int)
       ++ " Targets"
       |> str}
    </p>
  </div>;
};

let quizPerformanceChart = (averageQuizScore, quizzesAttempted) => {
  switch (averageQuizScore) {
  | Some(score) =>
    <div className="w-1/2 student-overlay__doughnut-chart-container">
      {doughnutChart("pink", score |> int_of_float |> string_of_int)}
      <p className="text-sm font-semibold text-center mt-2">
        {"Average Quiz Score" |> str}
      </p>
      <p className="text-sm text-gray-700 font-semibold text-center mt-1">
        {quizzesAttempted ++ " Quizzes Attempted" |> str}
      </p>
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
       <div
         key={criterion |> EvaluationCriterion.id}
         className="w-1/2 student-overlay__pie-chart-container">
         <svg
           className="student-overlay__pie-chart mx-auto" viewBox="0 0 32 32">
           <circle
             className="student-overlay__pie-chart-circle"
             strokeDasharray={
               StudentDetails.gradeAsPercentage(grade, criterion) ++ ", 100"
             }
             r="16"
             cx="16"
             cy="16"
           />
           <text
             x="50%"
             y="58%"
             className="student-overlay__doughnut-chart-text font-semibold">
             {(grade.grade |> Js.Float.toString)
              ++ "/"
              ++ (criterion.maxGrade |> string_of_int)
              |> str}
           </text>
         </svg>
         <p className="text-sm font-semibold text-center mt-2">
           {criterion |> EvaluationCriterion.name |> str}
         </p>
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

let socialLinks = socialLinks => {
  socialLinks
  |> Array.map(link =>
       <a href=link> <i className={socialLinkIconClass(link)} /> </a>
     )
  |> React.array;
};

let personalInfo = studentDetails => {
  <div className="flex">
    <div className="flex student-name-and-email content-between">
      <div className="flex">
        <i className="fas fa-envelope" />
        <p> {studentDetails |> StudentDetails.email |> str} </p>
      </div>
      {switch (studentDetails |> StudentDetails.phone) {
       | Some(phone) =>
         <div className="flex">
           <i className="fas fa-phone" />
           <p> {phone |> str} </p>
         </div>
       | None => React.null
       }}
    </div>
    <div className="flex student-social-links">
      {socialLinks(studentDetails |> StudentDetails.socialLinks)}
    </div>
  </div>;
};

[@react.component]
let make = (~courseId, ~studentId) => {
  let (state, setState) = React.useState(() => Loading);
  React.useEffect(() => {
    ScrollLock.activate();
    Some(() => ScrollLock.deactivate());
  });
  React.useEffect1(
    getStudentDetails(AuthenticityToken.fromHead(), studentId, setState),
    [|studentId|],
  );
  <div
    className="fixed z-30 top-0 left-0 w-full h-full overflow-y-scroll bg-white">
    <div
      onClick={_ => closeOverlay(courseId)}
      className="absolute z-50 left-0 cursor-pointer top-0">
      <Icon className="if i-times-light text-xl lg:text-2xl mt-1 lg:mt-0" />
      <span className="text-xs hidden lg:inline-block mt-px">
        {"close" |> str}
      </span>
    </div>
    {switch (state) {
     | Loaded(studentDetails) =>
       <div className="flex flex-col md:flex-row min-h-screen">
         <div className="w-full md:w-2/5 bg-white">
           <div className="student-overlay__student-details relative py-8">
             <div
               className="student-overlay__student-avatar mx-auto w-18 h-18 md:w-25 md:h-25 text-xs border border-yellow-500 rounded-full overflow-hidden flex-shrink-0">
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
             <p className="text-sm font-semibold text-center mt-2">
               {studentDetails |> StudentDetails.title |> str}
             </p>
           </div>
           {personalInfo(studentDetails)}
           <p className="text-lg font-semibold"> {"Targets Overview" |> str} </p>
           <div className="flex">
             {targetsCompletionStatus(
                studentDetails |> StudentDetails.targetsCompleted,
                studentDetails |> StudentDetails.totalTargets,
              )}
             {quizPerformanceChart(
                studentDetails |> StudentDetails.averageQuizScore,
                studentDetails |> StudentDetails.quizzesAttempted,
              )}
           </div>
           <p className="text-lg font-semibold"> {"Average Grades" |> str} </p>
           <div className="flex py-8">
             {averageGradeCharts(
                studentDetails |> StudentDetails.evaluationCriteria,
                studentDetails |> StudentDetails.averageGrades,
              )}
           </div>
         </div>
         <div className="w-full md:w-3/5 bg-gray-100 border-l p-12">
           {"Comments" |> str}
         </div>
       </div>
     | Loading =>
       <div>
         <div className="bg-gray-100 py-4">
           <div className="max-w-3xl mx-auto"> {SkeletonLoading.card()} </div>
         </div>
         <div className="max-w-3xl mx-auto">
           {SkeletonLoading.heading()}
           {SkeletonLoading.paragraph()}
           {SkeletonLoading.profileCard()}
           {SkeletonLoading.paragraph()}
         </div>
       </div>
     }}
  </div>;
};
