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
   mutation($studentId: ID!, $note: String!, $authorId: ID!) {
    createCoachNote(studentId: $studentId, authorId: $authorId, note: $note ) {
       success
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
