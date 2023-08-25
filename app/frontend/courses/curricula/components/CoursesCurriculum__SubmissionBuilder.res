open CoursesCurriculum__Types

let str = React.string

let tr = I18n.t(~scope="components.CoursesCurriculum__SubmissionBuilder")

type formState =
  | Attaching
  | Saving
  | Ready

let buttonContents = (formState, checklist) => {
  let icon = switch formState {
  | Attaching
  | Saving =>
    <FaIcon classes="fas fa-spinner fa-pulse me-2" />
  | Ready => <FaIcon classes="fas fa-cloud-upload-alt me-2" />
  }

  let text = switch formState {
  | Attaching => tr("attaching") ++ "..."
  | Saving => tr("submitting") ++ "..."
  | Ready => checklist |> ArrayUtils.isEmpty ? tr("complete") : tr("submit")
  } |> str

  <span> icon text </span>
}

type state = {
  formState: formState,
  checklist: array<ChecklistItem.t>,
}

type action =
  | SetAttaching
  | SetSaving
  | SetReady
  | UpdateResponse(array<ChecklistItem.t>)

let initialState = checklist => {
  formState: Ready,
  checklist: ChecklistItem.fromTargetChecklistItem(checklist),
}

let reducer = (state, action) =>
  switch action {
  | SetAttaching => {...state, formState: Attaching}
  | SetSaving => {...state, formState: Saving}
  | SetReady => {...state, formState: Ready}
  | UpdateResponse(checklist) => {checklist: checklist, formState: Ready}
  }

let isBusy = formState =>
  switch formState {
  | Attaching
  | Saving => true
  | Ready => false
  }

module CreateSubmissionQuery = %graphql(`
  mutation CreateSubmissionMutation($targetId: ID!, $checklist: JSON!, $fileIds: [ID!]!) {
    createSubmission(targetId: $targetId, checklist: $checklist, fileIds: $fileIds) {
      submission {
        id
        createdAt
      }
    }
  }
  `)

let isButtonDisabled = state =>
  switch state.formState {
  | Attaching
  | Saving => true
  | Ready => false
  } ||
  !(state.checklist |> ChecklistItem.validChecklist)

let submit = (state, send, target, targetDetails, addSubmissionCB, event) => {
  event |> ReactEvent.Mouse.preventDefault

  send(SetSaving)

  let fileIds = state.checklist |> ChecklistItem.fileIds
  let checklist = state.checklist |> ChecklistItem.encodeArray
  let targetId = Target.id(target)

  CreateSubmissionQuery.make({targetId: targetId, fileIds: fileIds, checklist: checklist})
  |> Js.Promise.then_(response => {
    switch response["createSubmission"]["submission"] {
    | Some(submission) =>
      let files = state.checklist |> ChecklistItem.makeFiles
      let submissionChecklist =
        checklist |> Json.Decode.array(SubmissionChecklistItem.decode(files))
      let completionType = targetDetails |> TargetDetails.computeCompletionType
      let status = switch completionType {
      | Evaluated => Submission.Pending
      | TakeQuiz
      | LinkToComplete
      | MarkAsComplete
      | SubmitForm =>
        Submission.MarkedAsComplete
      }
      let newSubmission = Submission.make(
        ~id=submission["id"],
        ~createdAt=DateFns.decodeISO(submission["createdAt"]),
        ~status,
        ~checklist=submissionChecklist,
      )

      addSubmissionCB(newSubmission)
    | None =>
      /* Enable the form again in case of a validation failure. */
      send(SetReady)
    }
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    /* Enable the form again in case of server crash. */
    send(SetReady)
    Js.Promise.resolve()
  })
  |> ignore
}

let updateResult = (state, send, index, result) => {
  send(UpdateResponse(state.checklist |> ChecklistItem.updateResultAtIndex(index, result)))
}

let buttonClasses = checklist =>
  "flex mt-3 " ++ (checklist |> ArrayUtils.isEmpty ? "justify-center" : "justify-end")

let setAttaching = (send, bool) => send(bool ? SetAttaching : SetReady)

let statusText = formState =>
  switch formState {
  | Attaching => tr("attaching") ++ "..."
  | Saving => tr("submitting") ++ "..."
  | Ready => tr("submit")
  }

let tooltipText = preview =>
  if preview {
    <span> {tr("accessing_preview") |> str} <br /> {tr("for_course") |> str} </span>
  } else {
    <span> {tr("compete_all") |> str} <br /> {tr("steps_submit") |> str} </span>
  }

@react.component
let make = (~target, ~targetDetails, ~addSubmissionCB, ~preview, ~checklist) => {
  let (state, send) = React.useReducer(reducer, initialState(checklist))
  <div className="bg-gray-50 p-4 my-4 border rounded-lg" id="submission-builder">
    <DisablingCover disabled={isBusy(state.formState)} message={statusText(state.formState)}>
      {state.checklist |> ArrayUtils.isEmpty
        ? <div className="text-center"> {tr("no_actions") |> str} </div>
        : state.checklist
          |> Array.mapi((index, checklistItem) =>
            <CoursesCurriculum__SubmissionItem
              key={index |> string_of_int}
              index
              checklistItem
              updateResultCB={updateResult(state, send, index)}
              attachingCB={setAttaching(send)}
              preview
            />
          )
          |> React.array}
      <div className={buttonClasses(state.checklist)}>
        <Tooltip tip={tooltipText(preview)} position=#Start disabled={!isButtonDisabled(state)}>
          <button
            onClick={submit(state, send, target, targetDetails, addSubmissionCB)}
            disabled={isButtonDisabled(state) || preview}
            className="btn btn-primary flex justify-center grow md:grow-0">
            {buttonContents(state.formState, checklist)}
          </button>
        </Tooltip>
      </div>
    </DisablingCover>
  </div>
}
