open CoursesStudents__Types

let str = React.string

let tr = I18n.t(~scope="components.CoursesStudents__CoachNoteShow", ...)

type state = {archiving: bool}

module ArchiveCoachNoteMutation = %graphql(`
   mutation ArchiveCoachNoteMutation($id: ID!) {
    archiveCoachNote(id: $id) {
       success
      }
    }
   `)

let removeCoachNote = (id, removeNoteCB, setArchiving, event) => {
  ReactEvent.Mouse.preventDefault(event)

  if {
    open Webapi.Dom
    window->Window.confirm(tr("sure_delete"))
  } {
    setArchiving(_ => true)

    ignore(Js.Promise.then_((response: ArchiveCoachNoteMutation.t) => {
        if response.archiveCoachNote.success {
          removeNoteCB(id)
        } else {
          setArchiving(_ => false)
        }
        Js.Promise.resolve()
      }, ArchiveCoachNoteMutation.fetch({id: id})))
  } else {
    ()
  }
}

let deleteIcon = (note, removeNoteCB, setArchiving, archiving) =>
  <button
    ariaLabel={tr("delete_note") ++ CoachNote.id(note)}
    className="w-10 text-sm text-gray-600 hover:text-gray-900 cursor-pointer flex items-center justify-center rounded hover:bg-gray-50 hover:text-red-500 focus:outline-none focus:bg-gray-50 focus:text-red-500 focus:ring-2 focus:ring-inset focus:ring-red-500 "
    disabled=archiving
    title={tr("delete_note") ++ CoachNote.id(note)}
    onClick={removeCoachNote(CoachNote.id(note), removeNoteCB, setArchiving)}>
    <FaIcon classes={archiving ? "fas fa-spinner fa-spin" : "fas fa-trash-alt"} />
  </button>

@react.component
let make = (~note, ~userId, ~removeNoteCB) => {
  let (archiving, setArchiving) = React.useState(() => false)
  <div className="mt-4" key={CoachNote.id(note)} ariaLabel={"Note " ++ CoachNote.id(note)}>
    <div className="flex justify-between">
      <div className="flex">
        {switch CoachNote.author(note) {
        | Some(user) =>
          switch User.avatarUrl(user) {
          | Some(avatarUrl) =>
            <img
              className="w-8 h-8 md:w-10 md:h-10 text-xs border border-gray-300 rounded-full overflow-hidden shrink-0 mt-1 md:mt-0 me-2 md:me-3 object-cover"
              src=avatarUrl
            />
          | None =>
            <Avatar
              name={User.name(user)}
              className="w-8 h-8 md:w-10 md:h-10 text-xs border border-gray-300 rounded-full overflow-hidden shrink-0 mt-1 md:mt-0 me-2 md:me-3 object-cover"
            />
          }

        | None =>
          <Avatar
            name="?"
            className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden shrink-0 mt-1 md:mt-0 me-2 md:e-3 object-cover"
          />
        }}
        <div>
          <p className="text-sm font-semibold inline-block leading-snug">
            {str(
              switch CoachNote.author(note) {
              | Some(user) => User.name(user)
              | None => tr("deleted_coach")
              },
            )}
          </p>
          <p className="text-gray-600 text-xs mt-px leading-snug">
            {str(
              switch CoachNote.author(note) {
              | Some(user) => User.fullTitle(user)
              | None => tr("unknown")
              },
            )}
          </p>
        </div>
      </div>
      {
        let showDeleteIcon = switch CoachNote.author(note) {
        | None => false
        | Some(user) => User.id(user) == userId
        }
        showDeleteIcon ? deleteIcon(note, removeNoteCB, setArchiving, archiving) : React.null
      }
    </div>
    <div className="ms-10md:ms-13 mt-2">
      <p
        className="inline-block text-xs font-semibold leading-tight bg-gray-300 text-gray-800 mt-px px-1 py-px rounded">
        {str(tr("coach_on") ++ " " ++ CoachNote.noteOn(note))}
      </p>
      <MarkdownBlock
        className="pt-1 text-sm" profile=Markdown.Permissive markdown={CoachNote.note(note)}
      />
    </div>
  </div>
}
