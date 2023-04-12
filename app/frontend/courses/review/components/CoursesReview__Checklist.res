let t = I18n.t(~scope="components.CoursesReview__Checklist")

type state =
  | Edit
  | Show

let str = React.string

let closeEditMode = (setState, ()) => setState(_ => Show)

let showEditor = (setState, ()) => setState(_ => Edit)

let updateReviewChecklist = (setState, updateReviewChecklistCB, reviewChecklist) => {
  updateReviewChecklistCB(reviewChecklist)
  setState(_ => Show)
}

let handleEmpty = setState =>
  <div className="p-4 md:p-6">
    <button
      className="bg-gray-50 border border-primary-500 border-dashed rounded-lg p-3 md:p-5 flex items-center w-full hover:bg-gray-50 hover:border-primary-600 hover:shadow-lg focus:outline-none"
      onClick={_ => setState(_ => Edit)}>
      <span
        className="inline-flex shrink-0 bg-white w-14 h-14 border border-dashed border-primary-500 rounded-full items-center justify-center shadow-md">
        <span
          className="inline-flex items-center justify-center shrink-0 w-10 h-10 rounded-full bg-primary-500 text-white">
          <i className="fa fa-plus" />
        </span>
      </span>
      <span className="block  ms-4">
        <span className="block text-base font-semibold text-primary-500">
          {t("create_review_checklist")->str}
        </span>
        <span className="text-sm block"> {t("create_review_checklist_description")->str} </span>
      </span>
    </button>
  </div>

@react.component
let make = (
  ~reviewChecklist,
  ~updateFeedbackCB,
  ~feedback,
  ~updateReviewChecklistCB,
  ~targetId,
  ~cancelCB,
  ~overlaySubmission,
  ~submissionDetails,
) => {
  let (state, setState) = React.useState(() => ArrayUtils.isEmpty(reviewChecklist) ? Edit : Show)
  <div>
    {switch state {
    | Edit =>
      <CoursesReview__ChecklistEditor
        reviewChecklist
        updateReviewChecklistCB={updateReviewChecklist(setState, updateReviewChecklistCB)}
        closeEditModeCB={closeEditMode(setState)}
        targetId
      />
    | Show =>
      <CoursesReview__ChecklistShow
        cancelCB
        reviewChecklist
        feedback
        updateFeedbackCB
        showEditorCB={showEditor(setState)}
        overlaySubmission
        submissionDetails
      />
    }}
  </div>
}
