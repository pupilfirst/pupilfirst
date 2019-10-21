[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

let str = React.string;

[@react.component]
let make = (~feedback, ~updateFeedbackCB, ~label) =>
  <div className="pt-4 md:pt-5 course-review__feedback-editor">
    <MarkdownEditor
      updateMarkdownCB=updateFeedbackCB
      value=feedback
      label
      profile=Markdown.Permissive
      defaultView=MarkdownEditor.Edit
      maxLength=10000
    />
  </div>;
