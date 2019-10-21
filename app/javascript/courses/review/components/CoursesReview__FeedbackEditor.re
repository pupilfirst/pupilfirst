[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

let str = React.string;

[@react.component]
let make =
    (
      ~feedback,
      ~updateFeedbackCB,
      ~label,
      ~reviewChecklist,
      ~updateReviewChecklistCB,
      ~showChecklist,
      ~targetId,
    ) => {
  let (showChecklist, setShowCHecklist) = React.useState(() => showChecklist);
  <div className="pt-4 md:pt-6 course-review__feedback-editor">
    <div>
      {showChecklist
         ? <CoursesReview__Checklist
             reviewChecklist
             updateFeedbackCB
             feedback
             updateReviewChecklistCB
             targetId
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
      updateMarkdownCB=updateFeedbackCB
      value=feedback
      label
      profile=Markdown.Permissive
      defaultView=MarkdownEditor.Edit
      maxLength=10000
    />
  </div>;
};
