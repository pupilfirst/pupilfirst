[@bs.config {jsx: 3}];

open StudentsPanel__Types;

module DropoutStudentQuery = [%graphql
  {|
   mutation($id: ID!) {
    dropoutStudent(id: $id){
      success
     }
   }
 |}
];

let dropoutStudent = (id, setSaving, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setSaving(_ => true);
  DropoutStudentQuery.make(~id, ())
  |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead())
  |> Js.Promise.then_(response => {
       response##dropoutStudent##success
         ? DomUtils.reload() : setSaving(_ => false);
       Js.Promise.resolve();
     })
  |> ignore;
};

let str = ReasonReact.string;

[@react.component]
let make = (~student) => {
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
      <button
        disabled=saving
        className="btn btn-danger btn-large"
        onClick={dropoutStudent(student |> Student.id, setSaving)}>
        <i className="fa fa-exclamation-triangle" />
        <span className="ml-2"> {"Dropout Student" |> str} </span>
      </button>
    </div>
  </div>;
};
