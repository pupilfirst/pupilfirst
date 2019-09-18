[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__Root.css")|}];

open CoursesReview__Types;
let str = React.string;

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
      className="bg-white px-4 py-2 border border-gray-400 font-semibold rounded-lg focus:outline-none">
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
  "w-1/2 md:w-auto py-2 px-3 md:px-6 font-semibold text-sm hover:text-primary-500 hover:bg-gray-100 focus:outline-none "
  ++ (selected ? "bg-primary-100 shadow-inner text-primary-500" : "bg-white");

[@react.component]
let make =
    (~authenticityToken, ~levels, ~submissions, ~gradeLabels, ~courseId) => {
  let (showPending, setShowPending) = React.useState(() => true);
  let (selectedLevel, setSelectedLevel) = React.useState(() => None);
  let (selectedSubmission, setSelectedSubmission) =
    React.useState(() => Some(0 |> Array.unsafe_get(submissions)));

  <div className="bg-gray-100 pt-14 pb-8 px-3 -mt-7">
    <div className="max-w-3xl mx-auto">
      <div className="flex flex-col md:flex-row items-center justify-between">
        <div
          className="course-review__status-tab w-full md:w-auto flex rounded-lg border border-gray-400 overflow-hidden">
          <button
            className={buttonClasses(showPending == true)}
            onClick={_ => setShowPending(_ => true)}>
            {"Pending" |> str}
          </button>
          <button
            className={buttonClasses(showPending == false)}
            onClick={_ => setShowPending(_ => false)}>
            {"Reviewed" |> str}
          </button>
        </div>
        <div className="flex-shrink-0 mt-4">
          {showDropdown(levels, selectedLevel, setSelectedLevel)}
        </div>
      </div>
      {
        showPending ?
          <CoursesReview__ShowPendingSubmissions
            authenticityToken
            submissions
            levels
            selectedLevel
            setSelectedSubmission
          /> :
          <CoursesReview__ShowReviewedSubmissions
            authenticityToken
            courseId
            selectedLevel
            levels
            setSelectedSubmission
          />
      }
      {
        switch (selectedSubmission) {
        | None => React.null
        | Some(submission) =>
          <CoursesReview__SubmissionOverlay
            authenticityToken
            levels
            submission
            setSelectedSubmission
            gradeLabels
          />
        }
      }
    </div>
  </div>;
};
