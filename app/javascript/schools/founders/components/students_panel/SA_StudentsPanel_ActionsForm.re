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

  <div className="mt-5">
    <label
      className="tracking-wide text-xs font-semibold"
      htmlFor="access-ends-at-input">
      {"Has this student dropped out?" |> str}
    </label>
    <HelpIcon
      className="ml-2"
      link="https://docs.pupilfirst.com/#/students?id=editing-student-details">
      {"If specified, students can't submit their work from the specified date"
       |> str}
    </HelpIcon>
    <div className="mt-2">
      <button className="btn btn-danger btn-large">
        <i className="fa fa-exclamation-triangle" />
        <span className="ml-2"> {"Dropout Student" |> str} </span>
      </button>
    </div>
  </div>;
};
