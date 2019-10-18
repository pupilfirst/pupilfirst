[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

open CoursesReview__Types;

let str = React.string;

[@react.component]
let make = (~feedback, ~updateFeedbackCB, ~label, ~reviewChecklist) => {
  Js.log("feedback");
  Js.log(feedback);

  <div className="pt-4 md:pt-5 course-review__feedback-editor">
    <CoursesReview__Checklist reviewChecklist updateFeedbackCB />
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
