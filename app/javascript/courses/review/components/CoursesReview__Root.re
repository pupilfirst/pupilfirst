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
  | Some(_) => [
      <button
        className="p-3 w-full text-left font-semibold focus:outline-none"
        onClick=(_ => setSelectedLevel(_ => None))>
        {"All Levels" |> str}
      </button>,
    ]
  | None => []
  };

let showDropdown = (levels, selectedLevel, setSelectedLevel) => {
  let contents =
    dropdownShowAllButton(selectedLevel, setSelectedLevel)
    ->List.append(
        levels
        |> Level.sort
        |> List.map(level =>
             <button
               className="p-3 w-full text-left font-semibold focus:outline-none"
               onClick={_ => setSelectedLevel(_ => Some(level))}>
               {dropDownButtonText(level) |> str}
             </button>
           ),
      )
    |> Array.of_list;

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
      <span className="pl-3 border-l">
        <i className="ml-2 fas fa-chevron-down text-sm" />
      </span>
    </button>;

  <Dropdown selected contents right=true />;
};

let buttonClasses = selected =>
  "py-2 px-6 font-semibold text-sm focus:outline-none "
  ++ (selected ? "bg-primary-100 text-primary-500" : "bg-white");

[@react.component]
let make =
    (~authenticityToken, ~levels, ~submissions, ~gradeLabels, ~courseId) => {
  let (showPending, setShowPending) = React.useState(() => true);
  let (selectedLevel, setSelectedLevel) = React.useState(() => None);
  let (selectedSubmission, setSelectedSubmission) =
    React.useState(() => None);

  <div className="bg-gray-100 pt-14 pb-8 -mt-7">
    <div className="max-w-3xl mx-auto">
      <div className="flex justify-between">
        <div
          className="course-review__status-tab flex rounded-lg border border-gray-400 overflow-hidden">
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
        <div> {showDropdown(levels, selectedLevel, setSelectedLevel)} </div>
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
