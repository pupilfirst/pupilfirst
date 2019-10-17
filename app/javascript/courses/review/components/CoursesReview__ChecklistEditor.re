[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

open CoursesReview__Types;

let str = React.string;

[@react.component]
let make = () =>
  <div className="">
    <div>
      <div className="text-xl"> {"Review Prep Checklist" |> str} </div>
      <div className="text-sm">
        {"Prepare for your review by creating a checklist" |> str}
      </div>
    </div>
    <div className="bg-gray-300 rounded-lg px-4 pt-2">
      <div>
        <div className="text-lg"> {"Review Prep Checklist" |> str} </div>
      </div>
    </div>
  </div>;
