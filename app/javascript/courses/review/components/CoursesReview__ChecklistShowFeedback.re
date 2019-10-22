[@bs.config {jsx: 3}];

open CoursesReview__Types;

let str = React.string;

let feedbackClasses = showMore => {
  showMore ? "h-auto" : "h-1";
};

[@react.component]
let make = (~feedback) => {
  let (showMore, setShowMore) = React.useState(() => false);
  <div className={feedbackClasses(showMore)}>
    {switch (feedback) {
     | Some(feedback) =>
       <MarkdownBlock
         markdown=feedback
         className="text-sm"
         profile=Markdown.Permissive
       />
     | None => React.null
     }}
    {showMore
       ? React.null
       : <button onClick={_ => setShowMore(_ => true)}>
           {"Show More" |> str}
         </button>}
  </div>;
};
