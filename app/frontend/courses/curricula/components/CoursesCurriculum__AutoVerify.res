let str = React.string

let tr = I18n.t(~scope="components.CoursesCurriculum__AutoVerify")
let ts = I18n.t(~scope="shared")

open CoursesCurriculum__Types
module TargetStatus = CoursesCurriculum__TargetStatus

module AutoVerifySubmissionQuery = %graphql(`
   mutation AutoVerifySubmissionMutation($targetId: ID!) {
    autoVerifySubmission(targetId: $targetId){
      submission{
        id
        createdAt
      }
     }
   }
 `)

let redirect = link => {
  let window = Webapi.Dom.window

  Webapi.Dom.Window.open_(window, ~url=link, ~name="_blank", ~features="", ())->ignore
}

let handleSuccess = (submission, linkToComplete, addSubmissionCB) => {
  addSubmissionCB(
    Submission.make(
      ~id=submission["id"],
      ~createdAt=submission["createdAt"]->DateFns.decodeISO,
      ~status=Submission.MarkedAsComplete,
      ~checklist=[],
    ),
  )

  switch linkToComplete {
  | Some(link) => redirect(link)
  | None => ()
  }
}

let createAutoVerifySubmission = (target, linkToComplete, setSaving, addSubmissionCB, event) => {
  event |> ReactEvent.Mouse.preventDefault
  setSaving(_ => true)

  AutoVerifySubmissionQuery.make({targetId: Target.id(target)})
  |> Js.Promise.then_(response => {
    switch response["autoVerifySubmission"]["submission"] {
    | Some(details) => handleSuccess(details, linkToComplete, addSubmissionCB)
    | None => setSaving(_ => false)
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let completeButtonText = (title, iconClasses) =>
  <span>
    <FaIcon classes={iconClasses ++ " me-2"} />
    {title |> str}
  </span>

let previewLinkToComplete = link =>
  <a
    href=link
    target="_blank"
    className="block text-primary-500 w-full text-center bg-gray-50 hover:bg-gray-300 hover:text-primary-600 p-4 rounded text-lg font-bold">
    <span>
      <FaIcon classes="fas fa-external-link-alt me-2 rtl:-rotate-90" />
      {tr("visit_link") |> str}
    </span>
  </a>

let autoVerify = (target, linkToComplete, saving, setSaving, addSubmissionCB, preview) => {
  /* Handle special case for preview mode with link to complete */
  switch (preview, linkToComplete) {
  | (true, Some(link)) => previewLinkToComplete(link)
  | _ =>
    <button
      disabled={saving || preview}
      className="flex rounded btn-success text-lg justify-center w-full font-bold p-4 curriculum-overlay__learn-auto-verify-btn "
      onClick={createAutoVerifySubmission(target, linkToComplete, setSaving, addSubmissionCB)}>
      {switch (saving, linkToComplete) {
      | (true, _) => completeButtonText(tr("saving"), "fas fa-spinner fa-spin")
      | (false, Some(_)) => completeButtonText(tr("visit_complete"), "fas fa-external-link-alt")
      | (false, None) => completeButtonText(tr("mark_complete"), "fas fa-check-square")
      }}
    </button>
  }
}

let statusBar = (string, linkToComplete) => {
  let defaultClasses = "font-bold p-4 flex w-full items-center text-green-500 bg-green-100 justify-center"
  let message =
    <div className="flex items-center">
      <span className="fa-stack text-lg me-1 text-green-500">
        <i className="fas fa-certificate fa-stack-2x" />
        <i className="fas fa-check fa-stack-1x fa-inverse" />
      </span>
      <span> {string |> str} </span>
    </div>
  let visitLink = link =>
    <a className="ltr:text-right rtl:text-left w-full" href=link target="_blank">
      <i className="fas fa-external-link-alt me-2 rtl:-rotate-90" />
      {tr("visit_link") |> str}
    </a>

  <div className=defaultClasses>
    message
    {switch linkToComplete {
    | Some(link) => visitLink(link)
    | None => React.null
    }}
  </div>
}

let completionInstructionText = linkToComplete =>
  switch linkToComplete {
  | Some(_) => tr("before_visiting")
  | None => tr("before_marking")
  }

@react.component
let make = (~target, ~targetDetails, ~targetStatus, ~addSubmissionCB, ~preview) => {
  let (saving, setSaving) = React.useState(() => false)
  let linkToComplete = targetDetails |> TargetDetails.linkToComplete
  [
    <CoursesCurriculum__CompletionInstructions
      key="completion-instructions" targetDetails title={completionInstructionText(linkToComplete)}
    />,
    <div className="mt-5" id="auto-verify-target" key="completion-button">
      {switch targetStatus |> TargetStatus.status {
      | Pending => autoVerify(target, linkToComplete, saving, setSaving, addSubmissionCB, preview)
      | Locked(_) => React.null
      | _ => statusBar(ts("completed"), linkToComplete)
      }}
    </div>,
  ] |> React.array
}
