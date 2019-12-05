[@bs.config {jsx: 3}];

open StudentsPanel__Types;

let str = ReasonReact.string;

[@react.component]
let make =
    (
      ~student,
      ~isSingleFounder,
      ~teams,
      ~studentTags,
      ~teamCoachIds,
      ~courseCoachIds,
      ~schoolCoaches,
      ~submitFormCB,
      ~authenticityToken,
    ) => {
  let (saving, setSaving) = React.useState(() => false);
  <div className="mx-auto bg-white">
    <div className="mt-5">
      <label
        className="tracking-wide text-xs font-semibold"
        htmlFor="access-ends-at-input">
        {"Dropout Student" |> str}
      </label>
      <HelpIcon
        className="ml-2"
        link="https://docs.pupilfirst.com/#/students?id=editing-student-details">
        {"If specified, students can't submit their work from the specified date"
         |> str}
      </HelpIcon>
      <div>
        <button className="btn btn-danger">
          {"Dropout Student" |> str}
        </button>
      </div>
    </div>
  </div>;
};
