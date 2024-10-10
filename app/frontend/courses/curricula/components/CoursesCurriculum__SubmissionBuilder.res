open CoursesCurriculum__Types

let str = React.string

let tr = I18n.t(~scope="components.CoursesCurriculum__SubmissionBuilder", ...)

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

  let text = str(
    switch formState {
    | Attaching => tr("attaching") ++ "..."
    | Saving => tr("submitting") ++ "..."
    | Ready => ArrayUtils.isEmpty(checklist) ? tr("complete") : tr("submit")
    },
  )

  <span>
    icon
    text
  </span>
}

type state = {
  formState: formState,
  checklist: array<ChecklistItem.t>,
  anonymous: bool,
}

type action =
  | SetAttaching
  | SetSaving
  | SetReady
  | UpdateResponse(array<ChecklistItem.t>)
  | ToggleAnonymous

let initialState = checklist => {
  formState: Ready,
  checklist: ChecklistItem.fromTargetChecklistItem(checklist),
  anonymous: false,
}

let reducer = (state, action) =>
  switch action {
  | SetAttaching => {...state, formState: Attaching}
  | SetSaving => {...state, formState: Saving}
  | SetReady => {...state, formState: Ready}
  | UpdateResponse(checklist) => {...state, checklist, formState: Ready}
  | ToggleAnonymous => {...state, anonymous: !state.anonymous}
  }

let isBusy = formState =>
  switch formState {
  | Attaching
  | Saving => true
  | Ready => false
  }

module CreateSubmissionQuery = %graphql(`
  mutation CreateSubmissionMutation($targetId: ID!, $checklist: JSON!, $fileIds: [ID!]!, $anonymous: Boolean!) {
    createSubmission(targetId: $targetId, checklist: $checklist, fileIds: $fileIds, anonymous: $anonymous) {
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
  !ChecklistItem.validChecklist(state.checklist)

let submit = (state, send, target, targetDetails, addSubmissionCB, event) => {
  ReactEvent.Mouse.preventDefault(event)

  send(SetSaving)

  let fileIds = ChecklistItem.fileIds(state.checklist)
  let checklist = ChecklistItem.encodeArray(state.checklist)
  let anonymous = state.anonymous
  let targetId = Target.id(target)

  /* Enable the form again in case of a validation failure. */

  /* Enable the form again in case of server crash. */

  ignore(
    Js.Promise.catch(
      _error => {
        send(SetReady)
        Js.Promise.resolve()
      },
      Js.Promise.then_(response => {
        switch response["createSubmission"]["submission"] {
        | Some(submission) =>
          let files = ChecklistItem.makeFiles(state.checklist)
          let submissionChecklist = Json.Decode.array(
            SubmissionChecklistItem.decode(files),
            checklist,
          )
          let completionType = TargetDetails.computeCompletionType(targetDetails)
          let status = switch completionType {
          | Evaluated => Submission.Pending
          | TakeQuiz
          | NoAssignment
          | SubmitForm =>
            Submission.MarkedAsComplete
          }
          let newSubmission = Submission.make(
            ~id=submission["id"],
            ~createdAt=DateFns.decodeISO(submission["createdAt"]),
            ~status,
            ~checklist=submissionChecklist,
            ~hiddenAt=None,
          )

          addSubmissionCB(newSubmission)
        | None => send(SetReady)
        }
        Js.Promise.resolve()
      }, CreateSubmissionQuery.make({targetId, fileIds, checklist, anonymous})),
    ),
  )
}

let updateResult = (state, send, index, result) => {
  send(UpdateResponse(ChecklistItem.updateResultAtIndex(index, result, state.checklist)))
}

let buttonClasses = checklist =>
  "flex mt-3 " ++ (ArrayUtils.isEmpty(checklist) ? "justify-center" : "justify-end")

let setAttaching = (send, bool) => send(bool ? SetAttaching : SetReady)

let statusText = formState =>
  switch formState {
  | Attaching => tr("attaching") ++ "..."
  | Saving => tr("submitting") ++ "..."
  | Ready => tr("submit")
  }

let tooltipText = preview =>
  if preview {
    <span>
      {str(tr("accessing_preview"))}
      <br />
      {str(tr("for_course"))}
    </span>
  } else {
    <span>
      {str(tr("compete_all"))}
      <br />
      {str(tr("steps_submit"))}
    </span>
  }

@react.component
let make = (~target, ~targetDetails, ~addSubmissionCB, ~preview, ~checklist) => {
  let (state, send) = React.useReducer(reducer, initialState(checklist))
  <div className="bg-gray-50 p-4 my-4 border rounded-lg" id="submission-builder">
    <DisablingCover disabled={isBusy(state.formState)} message={statusText(state.formState)}>
      {ArrayUtils.isEmpty(state.checklist)
        ? <div className="text-center"> {str(tr("no_actions"))} </div>
        : React.array(
            Array.mapi(
              (index, checklistItem) =>
                <CoursesCurriculum__SubmissionItem
                  key={string_of_int(index)}
                  index
                  checklistItem
                  updateResultCB={updateResult(state, send, index)}
                  attachingCB={setAttaching(send)}
                  preview
                />,
              state.checklist,
            ),
          )}
      <div>
        {targetDetails->TargetDetails.discussion && targetDetails->TargetDetails.allowAnonymous
          ? <div>
              <div className="mt-4">
                <input
                  onChange={_event => send(ToggleAnonymous)}
                  checked=state.anonymous
                  className="checkbox-input h-4 w-4 rounded border border-gray-300 text-primary-500 focus:ring-focusColor-500"
                  id="anonymous"
                  type_="checkbox"
                />
                <label className="checkbox-label ps-2 cursor-pointer text-sm" htmlFor="anonymous">
                  {tr("submit_anonymous_label")->str}
                </label>
              </div>
              <p htmlFor="anonymous" className="text-xs ml-6 italic text-gray-700 mt-1">
                {tr("submit_anonymous_notice")->str}
              </p>
            </div>
          : React.null}
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
      </div>
    </DisablingCover>
  </div>
}
