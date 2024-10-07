%%raw(`import "./CoursesStudents__StudentOverlay.css"`)

open CoursesStudents__Types

type state = {
  newNote: string,
  saving: bool,
}

let str = React.string

let tr = I18n.t(~scope="components.CoursesStudents__CoachNotes", ...)

module CreateCoachNotesMutation = %graphql(`
   mutation CreateCoachNoteMutation($studentId: ID!, $note: String!) {
    createCoachNote(studentId: $studentId, note: $note ) {
       coachNote {
         id
         note
         createdAt
         author {
            id
            avatarUrl
            name
            fullTitle
         }
       }
      }
    }
  `)

let saveNote = (studentId, setState, state, addNoteCB) => {
  setState(state => {...state, saving: true})

  ignore(
    Js.Promise.catch(
      _error => {
        setState(state => {...state, saving: false})
        Js.Promise.resolve()
      },
      Js.Promise.then_(response => {
        switch response["createCoachNote"]["coachNote"] {
        | Some(note) =>
          let newNote = CoachNote.makeFromJs(note)
          addNoteCB(newNote)
          setState(_ => {newNote: "", saving: false})
        | None => setState(state => {...state, saving: false})
        }
        Js.Promise.resolve()
      }, CreateCoachNotesMutation.make({studentId, note: state.newNote})),
    ),
  )
}

let updateCoachNoteCB = (setState, newNote) => setState(state => {...state, newNote})

let saveNoteButtonText = (title, iconClasses) =>
  <span>
    <FaIcon classes={iconClasses ++ " me-2"} />
    {str(title)}
  </span>

@react.component
let make = (
  ~studentId,
  ~coachNotes,
  ~hasArchivedNotes,
  ~canModifyCoachNotes,
  ~addNoteCB,
  ~removeNoteCB,
  ~userId,
) => {
  let (state, setState) = React.useState(() => {newNote: "", saving: false})
  <div className="mt-3 text-sm">
    {canModifyCoachNotes
      ? <div>
          <span className="flex">
            <label
              htmlFor="course-students__coach-notes-new-note"
              className="font-semibold text-sm block mb-1">
              {tr("new_note")->str}
            </label>
            <HelpIcon className="ms-1"> {tr("help_text")->str} </HelpIcon>
          </span>
          <DisablingCover disabled=state.saving message="Saving...">
            <MarkdownEditor
              textareaId="course-students__coach-notes-new-note"
              onChange={updateCoachNoteCB(setState)}
              value=state.newNote
              profile=Markdown.Permissive
              maxLength=10000
            />
          </DisablingCover>
          <button
            disabled={String.length(state.newNote) < 1 || state.saving}
            onClick={_ => saveNote(studentId, setState, state, addNoteCB)}
            className="btn btn-primary mt-2">
            {state.saving
              ? saveNoteButtonText(tr("saving"), "fas fa-spinner")
              : saveNoteButtonText(tr("save_note"), "")}
          </button>
        </div>
      : React.null}
    <div>
      <h6 className="font-semibold mt-6"> {str(tr("all_notes"))} </h6>
      {ArrayUtils.isEmpty(coachNotes)
        ? <div
            className="bg-gray-100 rounded text-center p-4 md:p-6 items-center justify-center mt-2">
            <Icon className="if i-long-text-light text-gray-800 text-base" />
            <p className="text-xs font-semibold text-gray-600 mt-2">
              {str(hasArchivedNotes ? tr("has_archived_notes") : tr("no_notes"))}
            </p>
          </div>
        : React.null}
      {React.array(
        Array.map(
          note =>
            <CoursesStudents__CoachNoteShow key={CoachNote.id(note)} note userId removeNoteCB />,
          CoachNote.sort(coachNotes),
        ),
      )}
    </div>
  </div>
}
