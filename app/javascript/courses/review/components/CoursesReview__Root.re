[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__Root.css")|}];

open CoursesReview__Types;
let str = React.string;

let openOverlay = submissionId =>
  ReasonReactRouter.push("/submissions/" ++ submissionId);

let dropDownButtonText = level =>
  "Level "
  ++ (level |> Level.number |> string_of_int)
  ++ " | "
  ++ (level |> Level.name);
let dropdownShowAllButton = (selectedLevel, setSelectedLevel) =>
  switch (selectedLevel) {
  | Some(_) => [|
      <button
        className="p-3 w-full text-left font-semibold focus:outline-none"
        onClick=(_ => setSelectedLevel(_ => None))>
        {"All Levels" |> str}
      </button>,
    |]
  | None => [||]
  };

let showDropdown = (levels, selectedLevel, setSelectedLevel) => {
  let contents =
    dropdownShowAllButton(selectedLevel, setSelectedLevel)
    ->Array.append(
        levels
        |> Level.sort
        |> Array.map(level =>
             <button
               className="p-3 w-full text-left font-semibold focus:outline-none"
               onClick={_ => setSelectedLevel(_ => Some(level))}>
               {dropDownButtonText(level) |> str}
             </button>
           ),
      );

  let selected =
    <button
      className="bg-white px-4 py-2 border border-gray-400 font-semibold rounded-lg focus:outline-none w-full md:w-auto flex justify-between">
      {
        (
          switch (selectedLevel) {
          | None => "All Levels"
          | Some(level) => dropDownButtonText(level)
          }
        )
        |> str
      }
      <span className="pl-2 ml-2 border-l">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>;

  <Dropdown selected contents right=true />;
};

let buttonClasses = selected =>
  "w-1/2 md:w-auto py-2 px-3 md:px-6 font-semibold text-sm focus:outline-none "
  ++ (
    selected ?
      "bg-primary-100 shadow-inner text-primary-500" :
      "bg-white shadow-md hover:shadow hover:text-primary-500 hover:bg-gray-100"
  );

let removePendingSubmission = (setSubmissions, submissionId) =>
  setSubmissions(submissions =>
    submissions |> Js.Array.filter(s => s |> SubmissionInfo.id != submissionId)
  );

let submissionListClasses = bool => bool ? "" : "hidden";

[@react.component]
let make =
    (
      ~authenticityToken,
      ~levels,
      ~submissions,
      ~gradeLabels,
      ~courseId,
      ~passGrade,
      ~currentCoach,
    ) => {
  let (submissions, setSubmissions) = React.useState(() => submissions);
  let (showPending, setShowPending) = React.useState(() => true);
  let (selectedLevel, setSelectedLevel) = React.useState(() => None);

  let url = ReasonReactRouter.useUrl();

  switch (url.path) {
  | ["submissions", submissionId, ..._] =>
    <CoursesReview__SubmissionOverlay
      authenticityToken
      courseId
      submissionId
      gradeLabels
      passGrade
      currentCoach
      removePendingSubmissionCB={removePendingSubmission(setSubmissions)}
    />
  | _ =>
    <div className="bg-gray-100 pt-12 pb-8 px-3 -mt-7">
      <div className="w-full bg-gray-100 relative md:sticky md:top-0">
        <div
          className="max-w-3xl mx-auto flex flex-col md:flex-row items-end lg:items-center justify-between pt-4 pb-4">
          <div
            className="course-review__status-tab w-full md:w-auto flex rounded-lg border border-gray-400">
            <button
              className={buttonClasses(showPending == true)}
              onClick=(_ => setShowPending(_ => true))>
              {"Pending" |> str}
              <span
                className="ml-2 text-white text-xs bg-red-500 w-5 h-5 inline-flex items-center justify-center rounded-full">
                {submissions |> Array.length |> string_of_int |> str}
              </span>
            </button>
            <button
              className={buttonClasses(showPending == false)}
              onClick=(_ => setShowPending(_ => false))>
              {"Reviewed" |> str}
            </button>
          </div>
          <div className="flex-shrink-0 pt-4 md:pt-0 w-full md:w-auto">
            {showDropdown(levels, selectedLevel, setSelectedLevel)}
          </div>
        </div>
      </div>
      <div className="max-w-3xl mx-auto">
        <div className={submissionListClasses(showPending == true)}>
          <CoursesReview__ShowPendingSubmissions
            authenticityToken
            submissions
            levels
            selectedLevel
            openOverlayCB=openOverlay
          />
        </div>
        <div className={submissionListClasses(showPending == false)}>
          <CoursesReview__ShowReviewedSubmissions
            authenticityToken
            courseId
            selectedLevel
            levels
            openOverlayCB=openOverlay
          />
        </div>
      </div>
    </div>
  };
};