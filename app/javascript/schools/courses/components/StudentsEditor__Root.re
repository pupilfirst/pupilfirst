[@bs.config {jsx: 3}];

open StudentsEditor__Types;

let str = React.string;

[@react.component]
let make = (~courseId, ~courseCoachIds, ~schoolCoaches, ~levels, ~studentTags) => {
  <div> {"School course studentsindex" |> str} </div>;
};
