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
  <div className="text-center">
    <div className="text-sm">
      {"Prepare for your review by creating a checklist" |> str}
    </div>
    <button
      className="btn btn-large btn-primary mt-4"
      onClick={_ => setState(_ => Edit)}>
      {"Create a review checklist" |> str}
    </button>
  </div>;
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
    <div className="bg-gray-100 rounded-sm mt-2 p-2 md:p-4">
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
