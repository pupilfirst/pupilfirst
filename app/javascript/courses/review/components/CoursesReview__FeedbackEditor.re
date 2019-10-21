[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

open CoursesReview__Types;

let str = React.string;

let generateRandomId = () => {
  (Js.Date.now() |> Js.Float.toString)
  ++ "-"
  ++ (Js.Math.random_int(100000, 999999) |> string_of_int);
};

let updateFeedback = (setTextareaId, updateFeedbackCB, feedback) => {
  updateFeedbackCB(feedback);
  setTextareaId(_ => generateRandomId());
};

[@react.component]
let make =
    (
      ~feedback,
      ~updateFeedbackCB,
      ~label,
      ~reviewChecklist,
      ~updateReviewChecklistCB,
      ~showChecklist,
    ) => {
  let (textareaId, setTextareaId) = React.useState(() => generateRandomId());
  let (showChecklist, setShowCHecklist) = React.useState(() => showChecklist);
  <div className="pt-4 md:pt-6 course-review__feedback-editor">
    <div>
      {showChecklist
         ? <CoursesReview__Checklist
             reviewChecklist
             updateFeedbackCB={updateFeedback(
               setTextareaId,
               updateFeedbackCB,
             )}
             feedback
             updateReviewChecklistCB
           />
         : <div>
             <button
               className="btn btn-primary"
               onClick={_ => setShowCHecklist(_ => true)}>
               {"Show Review Checklist" |> str}
             </button>
           </div>}
    </div>
    <MarkdownEditor
      key=textareaId
      updateMarkdownCB=updateFeedbackCB
      value=feedback
      label
      profile=Markdown.Permissive
      defaultView=MarkdownEditor.Edit
      maxLength=10000
    />
  </div>;
};
