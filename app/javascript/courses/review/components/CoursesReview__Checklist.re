[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

type state =
  | Empty
  | Edit
  | Show;

let str = React.string;

let computeState = reviewChecklist => {
  reviewChecklist |> ArrayUtils.isEmpty ? Empty : Show;
};

let closeEditMode = (reviewChecklist, setState, ()) => {
  setState(_ => computeState(reviewChecklist));
};

let showEditor = (setState, ()) => {
  setState(_ => Edit);
};

let updateReviewChecklist =
    (setState, updateReviewChecklistCB, reviewChecklist) => {
  setState(_ => computeState(reviewChecklist));
  updateReviewChecklistCB(reviewChecklist);
};

let handleEmpty = setState => {
  <button
    className="bg-gray-100 border border-primary-500 border-dashed rounded-lg p-3 md:p-5 flex items-center w-full hover:bg-gray-200 hover:border-primary-600 hover:shadow-lg focus:outline-none"
    onClick={_ => setState(_ => Edit)}>
    <span
      className="inline-flex bg-white w-14 h-14 border border-dashed border-primary-500 rounded-full items-center justify-center shadow-md">
      <span
        className="inline-flex items-center justify-center flex-shrink-0 w-10 h-10 rounded-full bg-primary-500 text-white">
        <i className="fa fa-plus" />
      </span>
    </span>
    <span className="block text-left ml-4">
      <span className="block text-base font-semibold text-primary-500">
        {"Create a review checklist" |> str}
      </span>
      <span className="text-sm block">
        {"Prepare for your review by creating a checklist" |> str}
      </span>
    </span>
  </button>;
};

[@react.component]
let make =
    (
      ~reviewChecklist,
      ~updateFeedbackCB,
      ~feedback,
      ~updateReviewChecklistCB,
      ~targetId,
    ) => {
  let (state, setState) =
    React.useState(() => computeState(reviewChecklist));
  <div className="px-4 pt-4 md:px-6 md:pt-6">
    <h5 className="font-semibold text-sm"> {"Review Checklist" |> str} </h5>
    <div className="mt-2">
      {switch (state) {
       | Empty => handleEmpty(setState)
       | Edit =>
         <CoursesReview__ChecklistEditor
           reviewChecklist
           updateReviewChecklistCB={updateReviewChecklist(
             setState,
             updateReviewChecklistCB,
           )}
           closeEditModeCB={closeEditMode(reviewChecklist, setState)}
           targetId
         />
       | Show =>
         <CoursesReview__ChecklistShow
           reviewChecklist
           feedback
           updateFeedbackCB
           showEditorCB={showEditor(setState)}
         />
       }}
    </div>
  </div>;
};
