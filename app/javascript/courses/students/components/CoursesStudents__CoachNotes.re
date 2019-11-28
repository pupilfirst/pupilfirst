[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__StudentOverlay.css")|}];

open CoursesStudents__Types;

type state = {
  newNote: option(string),
  notes: array(CoachNote.t),
};

let str = React.string;

module CreateCoachNotesMutation = [%graphql
  {|
   mutation($studentId: ID!, $note: String!) {
    createCoachNote(studentId: $studentId, note: $note ) {
       coachNote {
         note
       }
      }
    }
   |}
];

[@react.component]
let make = (~studentId, ~coachNotes) => {
  let (state, setState) =
    React.useState(() => {newNote: None, notes: coachNotes});
  <div />;
};
