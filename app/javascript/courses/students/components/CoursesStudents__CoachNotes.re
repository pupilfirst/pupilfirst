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
         id
         note
         createdAt
         author {
          avatarUrl
          name
          title
          id
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
let make = (~studentId, ~coachNotes, ~addNoteCB, ~removeNoteCB, ~userId) => {
  let (state, setState) = React.useState(() => {newNote: "", saving: false});
  <div>
    <DisablingCover disabled={state.saving} message="Saving...">
      <MarkdownEditor
        updateMarkdownCB={updateCoachNoteCB(setState)}
        value={state.newNote}
        label="Add new note"
        profile=Markdown.Permissive
        maxLength=10000
        defaultView=MarkdownEditor.Edit
      />
    </DisablingCover>
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
    <div>
      <h6 className="font-semibold mt-6"> {"All Notes" |> str} </h6>
      {coachNotes |> ArrayUtils.isEmpty
         ? <div
             className="bg-gray-200 rounded text-center p-4 md:p-6 items-center justify-center mt-2">
             <i className="fas fa-sticky-note text-gray-400 text-4xl" />
             <p className="text-xs font-semibold text-gray-700 mt-2">
               {"No notes here!" |> str}
             </p>
           </div>
         : React.null}
      {coachNotes
       |> CoachNote.sort
       |> Array.map(note =>
            <CoursesStudents__CoachNoteShow
              key={note |> CoachNote.id}
              note
              userId
              removeNoteCB
            />
          )
       |> React.array}
    </div>
  </div>;
};
