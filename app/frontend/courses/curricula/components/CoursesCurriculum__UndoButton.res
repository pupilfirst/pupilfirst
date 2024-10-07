let str = React.string

let tr = I18n.t(~scope="components.CoursesCurriculum__UndoButton", ...)

module DeleteSubmissionQuery = %graphql(`
  mutation UndoSubmissionMutation($targetId: ID!) {
    undoSubmission(targetId: $targetId) {
      success
    }
  }
  `)

type status =
  | Pending
  | Undoing
  | Errored

let handleClick = (targetId, setStatus, undoSubmissionCB, event) => {
  ReactEvent.Mouse.preventDefault(event)

  if {
    open Webapi.Dom
    window->Window.confirm(tr("window_confirm"))
  } {
    setStatus(_ => Undoing)

    ignore(
      Js.Promise.catch(
        _ => {
          Notification.error(tr("notification_error_head"), tr("notification_error_body"))
          setStatus(_ => Errored)
          Js.Promise.resolve()
        },
        Js.Promise.then_((response: DeleteSubmissionQuery.t) => {
          if response.undoSubmission.success {
            undoSubmissionCB()
          } else {
            Notification.notice(tr("notification_notice_head"), tr("notification_notice_body"))
            setStatus(_ => Errored)
          }
          Js.Promise.resolve()
        }, DeleteSubmissionQuery.fetch({targetId: targetId})),
      ),
    )
  } else {
    ()
  }
}

let buttonContents = status =>
  switch status {
  | Undoing =>
    <span>
      <FaIcon classes="fas fa-spinner fa-spin me-2" />
      {str(tr("undoing"))}
    </span>
  | Pending =>
    <span>
      <FaIcon classes="fas fa-undo me-2" />
      <span className="hidden md:inline"> {str(tr("undo_submission"))} </span>
      <span className="md:hidden"> {str(tr("undo"))} </span>
    </span>
  | Errored =>
    <span>
      <FaIcon classes="fas fa-exclamation-triangle me-2" />
      {str("Error!")}
    </span>
  }

let isDisabled = status =>
  switch status {
  | Undoing
  | Errored => true
  | Pending => false
  }

let buttonClasses = status => {
  let classes = "btn btn-small btn-danger cursor-"

  classes ++
  switch status {
  | Undoing => "wait"
  | Errored => "not-allowed"
  | Pending => "pointer"
  }
}

@react.component
let make = (~undoSubmissionCB, ~targetId) => {
  let (status, setStatus) = React.useState(() => Pending)
  <button
    title={tr("undo_submission_title")}
    disabled={isDisabled(status)}
    className={buttonClasses(status)}
    onClick={handleClick(targetId, setStatus, undoSubmissionCB)}>
    {buttonContents(status)}
  </button>
}
