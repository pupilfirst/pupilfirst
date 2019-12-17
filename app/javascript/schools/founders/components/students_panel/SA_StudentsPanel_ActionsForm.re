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

let submitButtonIcons = saving => {
  saving ? "fas fa-spinner fa-spin" : "fa fa-exclamation-triangle";
};

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
      link="https://docs.pupilfirst.com/#/students?id=student-actions">
      {"Marking a student as dropped out will remove all of their access to the course."
       |> str}
    </HelpIcon>
    <div className="mt-2">
      <button
        disabled=saving
        className="btn btn-danger btn-large"
        onClick={dropoutStudent(student |> Student.id, setSaving)}>
        <FaIcon classes={submitButtonIcons(saving)} />
        <span className="ml-2"> {"Dropout Student" |> str} </span>
      </button>
    </div>
  </div>;
};
