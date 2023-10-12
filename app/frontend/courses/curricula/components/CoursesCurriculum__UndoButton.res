let str = React.string

let tr = I18n.t(~scope="components.CoursesCurriculum__UndoButton")

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
  event |> ReactEvent.Mouse.preventDefault

  if {
    open Webapi.Dom
    window->Window.confirm(tr("window_confirm"))
  } {
    setStatus(_ => Undoing)

    DeleteSubmissionQuery.fetch({targetId: targetId})
    |> Js.Promise.then_((response: DeleteSubmissionQuery.t) => {
      if response.undoSubmission.success {
        undoSubmissionCB()
      } else {
        Notification.notice(tr("notification_notice_head"), tr("notification_notice_body"))
        setStatus(_ => Errored)
      }
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(_ => {
      Notification.error(tr("notification_error_head"), tr("notification_error_body"))
      setStatus(_ => Errored)
      Js.Promise.resolve()
    })
    |> ignore
  } else {
    ()
  }
}

let buttonContents = status =>
  switch status {
  | Undoing =>
    <span>
      <FaIcon classes="fas fa-spinner fa-spin me-2" />
      {tr("undoing") |> str}
    </span>
  | Pending =>
    <span>
      <FaIcon classes="fas fa-undo me-2" />
      <span className="hidden md:inline"> {tr("undo_submission") |> str} </span>
      <span className="md:hidden"> {tr("undo") |> str} </span>
    </span>
  | Errored =>
    <span>
      <FaIcon classes="fas fa-exclamation-triangle me-2" />
      {"Error!" |> str}
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
    disabled={status |> isDisabled}
    className={buttonClasses(status)}
    onClick={handleClick(targetId, setStatus, undoSubmissionCB)}>
    {buttonContents(status)}
  </button>
}
