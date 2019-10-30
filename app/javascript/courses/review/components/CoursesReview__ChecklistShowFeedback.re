[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__ChecklistShowFeedback.css")|}];

let str = React.string;

let feedbackClasses = showMore => {
  showMore ? "relative h-auto" : "relative overflow-hidden h-12";
};

let optionalStringLength = feedback => {
  switch (feedback) {
  | Some(f) => f |> String.length
  | None => 0
  };
};

[@react.component]
let make = (~feedback) => {
  let (showMore, setShowMore) =
    React.useState(() => feedback |> optionalStringLength < 150);

  switch (feedback) {
  | Some(feedback) =>
    <div className={feedbackClasses(showMore)}>
      <MarkdownBlock
        markdown=feedback
        className="text-sm"
        profile=Markdown.Permissive
      />
      {showMore || feedback |> String.length < 150
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
    </div>
  | None => React.null
  };
};
