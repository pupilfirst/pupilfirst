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
        title, name,email, phone, socialLinks,
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
      ariaLabel="submissions-overlay-header"
      className="bg-gray-100 border-b border-gray-300 px-3 pt-12 xl:pt-10 flex justify-center">
      <div
        className="relative bg-white border lg:border-transparent p-4 lg:px-6 lg:py-5 flex items-center justify-between rounded-lg shadow container max-w-3xl -mb-12">
        <div
          onClick={_ => closeOverlay(courseId)}
          className="review-submission-overlay__close flex flex-col items-center justify-center absolute rounded-t-lg lg:rounded-lg leading-tight px-4 py-1 h-8 lg:h-full cursor-pointer border border-b-0 border-gray-400 lg:border-0 lg:shadow lg:border-gray-300 bg-white text-gray-700 hover:text-gray-900 hover:bg-gray-100">
          <Icon
            className="if i-times-light text-xl lg:text-2xl mt-1 lg:mt-0"
          />
          <span className="text-xs hidden lg:inline-block mt-px">
            {"close" |> str}
          </span>
        </div>
      </div>
    </div>
  </div>;
};
