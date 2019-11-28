[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__StudentOverlay.css")|}];

open CoursesStudents__Types;

type state = {
  newNote: string,
  saving: bool,
};

let str = React.string;

module CreateCoachNotesMutation = [%graphql
  {|
   mutation($studentId: ID!, $note: String!) {
    createCoachNote(studentId: $studentId, note: $note ) {
       coachNote {
         note
         createdAt
         author {
          id
          avatarUrl
          name
          title
         }
       }
      }
    }
   |}
];

let saveNote = (authenticityToken, studentId, setState, state, addNoteCB) => {
  setState(state => {...state, saving: true});
  CreateCoachNotesMutation.make(
    ~studentId,
    ~note={
      state.newNote;
    },
    (),
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       switch (response##createCoachNote##coachNote) {
       | Some(note) =>
         let newNote = CoachNote.makeFromJs(note);
         addNoteCB(newNote);
         setState(_ => {newNote: "", saving: false});
       | None => setState(state => {...state, saving: false})
       };
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_error => {
       setState(state => {...state, saving: false});
       Js.Promise.resolve();
     })
  |> ignore;
};

let updateCoachNoteCB = (setState, newNote) => {
  setState(state => {...state, newNote});
};

let saveNoteButtonText = (title, iconClasses) =>
  <span> <FaIcon classes={iconClasses ++ " mr-2"} /> {title |> str} </span>;

[@react.component]
let make = (~studentId, ~coachNotes, ~addNoteCB) => {
  let (state, setState) = React.useState(() => {newNote: "", saving: false});
  <div>
    <p> {"Add New Note" |> str} </p>
    <MarkdownEditor
      updateMarkdownCB={updateCoachNoteCB(setState)}
      value={state.newNote}
      placeholder="Add a new note"
      profile=Markdown.Permissive
      maxLength=10000
      defaultView=MarkdownEditor.Edit
    />
    <button
      disabled={state.newNote |> String.length < 1 || state.saving}
      onClick={_ =>
        saveNote(
          AuthenticityToken.fromHead(),
          studentId,
          setState,
          state,
          addNoteCB,
        )
      }
      className="btn btn-primary mt-2">
      {state.saving
         ? saveNoteButtonText("Saving", "fas fa-spinner")
         : saveNoteButtonText("Save Note", "")}
    </button>
  </div>;
};
