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

module ArchiveCoachNoteMutation = [%graphql
  {|
   mutation($id: ID!) {
    archiveCoachNote(id: $id) {
       success
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

let removeCoachNote = (id, removeNoteCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  if (Webapi.Dom.(
        window |> Window.confirm("Are you sure you want to delete this note?")
      )) {
    ArchiveCoachNoteMutation.make(~id, ())
    |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead())
    |> Js.Promise.then_(response => {
         if (response##archiveCoachNote##success) {
           removeNoteCB(id);
         } else {
           ();
         };
         Js.Promise.resolve();
       })
    |> ignore;
  } else {
    ();
  };
};

let showCoachNote = (note, userId, removeNoteCB) => {
  <div className="mt-4" key={note |> CoachNote.id}>
    <div className="flex justify-between">
      <div className="flex">
        {switch (note |> CoachNote.author) {
         | Some(coach) =>
           switch (coach |> Coach.avatarUrl) {
           | Some(avatarUrl) =>
             <img
               className="w-8 h-8 md:w-10 md:h-10 text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
               src=avatarUrl
             />
           | None =>
             <Avatar
               name={coach |> Coach.name}
               className="w-8 h-8 md:w-10 md:h-10 text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
             />
           }

         | None =>
           <Avatar
             name="?"
             className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
           />
         }}
        <div>
          <p className="text-sm font-semibold inline-block leading-snug">
            {(
               switch (note |> CoachNote.author) {
               | Some(coach) => coach |> Coach.name
               | None => "Deleted Coach"
               }
             )
             |> str}
          </p>
          <p
            className="text-gray-600 font-semibold text-xs mt-px leading-snug">
            {(
               switch (note |> CoachNote.author) {
               | Some(coach) => coach |> Coach.title
               | None => "Unknown"
               }
             )
             |> str}
          </p>
        </div>
      </div>
      {let showDeleteIcon =
         switch (note |> CoachNote.author) {
         | None => false
         | Some(coach) => Coach.id(coach) == userId
         };
       showDeleteIcon
         ? <div
             className="w-10 text-sm text-gray-700 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-200"
             ariaLabel={"Delete " ++ (note |> CoachNote.id)}
             onClick={removeCoachNote(note |> CoachNote.id, removeNoteCB)}>
             <i className="fas fa-trash-alt" />
           </div>
         : React.null}
    </div>
    <div className="ml-10 md:ml-13 mt-2">
      <p
        className="inline-block text-xs font-semibold leading-tight bg-gray-300 text-gray-800 mt-px px-1 py-px rounded">
        {"on " ++ (note |> CoachNote.noteOn) |> str}
      </p>
      <MarkdownBlock
        className="pt-1 text-sm"
        profile=Markdown.Permissive
        markdown={note |> CoachNote.note}
      />
    </div>
  </div>;
};

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
       |> Array.map(note => showCoachNote(note, userId, removeNoteCB))
       |> React.array}
    </div>
  </div>;
};
