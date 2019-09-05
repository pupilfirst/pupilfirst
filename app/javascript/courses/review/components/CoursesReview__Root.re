[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

/* let contents = [|
  <button className="bg-gray-500 py-2 px-6"> {"Pending" |> str} </button>,
  <button className="bg-white py-2 px-6"> {"Reviewed" |> str} </button>,
|];

let selected =
  <button className="bg-white p-2">
    {"Filter" |> str}
    <i className="fas fa-chevron-down text-sm" />
  </button>; */

let showDropDown = (levels) => {
  let contents = { levels |> List.map(level => <button className="p-3 w-full text-left focus:outline-none">{level |> Level.name |> str} </button>) |> Array.of_list};
  let selected =
  <button className="bg-white p-3 focus:outline-none">
    {"All Levels" |> str}
    <i className="ml-2 fas fa-chevron-down text-sm" />
  </button>;

  <Dropdown selected contents right=true/>
};

[@react.component]
let make = (~authenticityToken, ~levels, ~pendingSubmissions, ~users) => {
  let (showPending, setShowPending) = React.useState(() => true);
  <div className="bg-gray-100 py-8">
    <div className="max-w-3xl mx-auto">
      <div className="flex justify-between">
        <div className="rounded-lg border overflow-hidden">
          <button
            className="bg-gray-500 py-3 px-6"
            onClick={_ => setShowPending(_ => true)}>
            {"Pending" |> str}
          </button>
          <button
            className="bg-white py-3 px-6"
            onClick={_ => setShowPending(_ => false)}>
            {"Reviewed" |> str}
          </button>
        </div>
        <div> {showDropDown(levels)} </div>
      </div>
      {
        showPending ?
          <CoursesReview__ShowPendingSubmissions
            authenticityToken
            users
            pendingSubmissions
          /> :
          <div> {"Load Reviewed" |> str} </div>
      }
    </div>
  </div>;
};
