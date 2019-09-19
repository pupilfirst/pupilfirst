[@bs.config {jsx: 3}];

open CoursesReview__Types;

let str = React.string;

[@react.component]
let make = (~feedback, ~updateFeedbackCB, ~label) =>
  <div>
    <MarkdownEditor
      updateDescriptionCB=updateFeedbackCB
      value=feedback
      label
      profile=Markdown.Permissive
      defaultView=MarkdownEditor.Edit
      maxLength=10000
    />
  </div>;
