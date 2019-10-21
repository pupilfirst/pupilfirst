[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

open CoursesReview__Types;

type state = {editMode: bool};

let str = React.string;

let closeEditMode = (setState, ()) => {
  setState(_ => {editMode: false});
};

let showEditor = (setState, ()) => {
  setState(_ => {editMode: true});
};

let updateReviewChecklist =
    (setState, updateReviewChecklistCB, reviewChecklist) => {
  setState(_ => {editMode: false});
  updateReviewChecklistCB(reviewChecklist);
};

let handleEmpty = (setState, updateReviewChecklistCB) => {
  <div className="text-center">
    <div className="text-sm">
      {"Prepare for your review by creating a checklist" |> str}
    </div>
    <button
      className="btn btn-large btn-primary mt-4"
      onClick={_ =>
        updateReviewChecklist(
          setState,
          updateReviewChecklistCB,
          ReviewChecklistItem.emptyTemplate(),
        )
      }>
      {"Create a review checklist" |> str}
    </button>
  </div>;
};

[@react.component]
let make =
    (~reviewChecklist, ~updateFeedbackCB, ~feedback, ~updateReviewChecklistCB) => {
  let (state, setState) = React.useState(() => {editMode: false});
  <div className="pb-4 md:pb-6">
    <h5 className="font-semibold text-sm"> {"Review Checklist" |> str} </h5>
    <div className="bg-gray-100 rounded-sm mt-2 p-2 md:p-4">
      {switch (reviewChecklist |> ArrayUtils.isEmpty, state.editMode) {
       | (true, _) => handleEmpty(setState, updateReviewChecklistCB)
       | (false, true) =>
         <CoursesReview__ChecklistEditor
           reviewChecklist
           updateReviewChecklistCB={updateReviewChecklist(
             setState,
             updateReviewChecklistCB,
           )}
           closeEditModeCB={closeEditMode(setState)}
         />
       | (false, false) =>
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
