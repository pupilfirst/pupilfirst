[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

type state = {editMode: bool};

let str = React.string;

let closeEditMode = (setState, ()) => {
  setState(_ => {editMode: false});
};

let showEditor = (setState, ()) => {
  setState(_ => {editMode: true});
};

[@react.component]
let make = (~reviewChecklist, ~updateFeedbackCB) => {
  let (state, setState) = React.useState(() => {editMode: true});
  <div className="">
    <div>
      <div className="text-xl"> {"Review Prep Checklist" |> str} </div>
      <div className="text-sm">
        {"Prepare for your review by creating a checklist" |> str}
      </div>
    </div>
    <div className="bg-gray-300 rounded-lg mt-2">
      <div className="px-4">
        {state.editMode
           ? <CoursesReview__ChecklistEditor
               reviewChecklist
               updateReviewChecklistCB=()
               closeEditModeCB={closeEditMode(setState)}
             />
           : <CoursesReview__ChecklistShow
               reviewChecklist
               updateFeedbackCB
               showEditorCB={showEditor(setState)}
             />}
      </div>
    </div>
  </div>;
};
