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

let showCoachNote = note => {
  <div key={note |> CoachNote.id}>
    {switch (note |> CoachNote.author) {
     | Some(coach) =>
       switch (coach |> Coach.avatarUrl) {
       | Some(avatarUrl) =>
         <img
           className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
           src=avatarUrl
         />
       | None =>
         <Avatar
           name={coach |> Coach.name}
           className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
         />
       }

     | None =>
       <Avatar
         name="X Y"
         className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
       />
     }}
    <div>
      <p className="font-semibold inline-block leading-snug">
        {(
           switch (note |> CoachNote.author) {
           | Some(coach) => coach |> Coach.name
           | None => "Deleted Coach"
           }
         )
         |> str}
      </p>
      {switch (note |> CoachNote.author) {
       | Some(coach) =>
         <p className="text-gray-600 font-semibold text-xs mt-px leading-snug">
           {coach |> Coach.title |> str}
         </p>
       | None => React.null
       }}
      <p className="text-gray-600 font-semibold text-xs mt-px leading-snug">
        {"on " ++ (note |> CoachNote.noteOn) |> str}
      </p>
    </div>
    <MarkdownBlock
      className="pt-1 text-sm"
      profile=Markdown.Permissive
      markdown={note |> CoachNote.note}
    />
  </div>;
};

[@react.component]
let make = (~studentId, ~coachNotes, ~addNoteCB) => {
  let (state, setState) = React.useState(() => {newNote: "", saving: false});
  <div>
    <MarkdownEditor
      updateMarkdownCB={updateCoachNoteCB(setState)}
      value={state.newNote}
      label="Add new note"
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
    <h6> {"All Notes" |> str} </h6>
    {coachNotes
     |> CoachNote.sort
     |> Array.map(note => showCoachNote(note))
     |> React.array}
  </div>;
};
