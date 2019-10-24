[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__ChecklistShowFeedback.css")|}];

open CoursesReview__Types;

let str = React.string;

let feedbackClasses = showMore => {
  showMore ? "relative h-auto" : "relative overflow-hidden h-12";
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
       : <div
           className="checklist-show-feedback__show-all-button absolute bottom-0 w-full">
           <button
             className="block w-full text-center rounded-lg text-primary-500 text-xs font-semibold focus:outline-none hover:text-primary-400"
             onClick={_ => setShowMore(_ => true)}>
             <span className="inline-block bg-gray-100 px-2">
               {"Show All" |> str}
             </span>
           </button>
         </div>}
  </div>;
};
