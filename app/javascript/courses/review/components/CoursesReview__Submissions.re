[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

type state = {submission: SubmissionDetails.t};

let showSubmissionStatus = submission => {
  let (text, classes) =
    switch (
      submission |> SubmissionDetails.passedAt,
      submission |> SubmissionDetails.evaluatorId,
    ) {
    | (None, None) => (
        "Pending",
        "bg-orange-100 border border-orange-500 text-orange-800 ",
      )
    | (None, Some(_)) => (
        "Failed",
        "bg-red-100 border border-red-500 text-red-700",
      )
    | (Some(_), None)
    | (Some(_), Some(_)) => (
        "Passed",
        "bg-green-100 border border-green-500 text-green-800",
      )
    };
  <div className={"font-semibold px-3 py-px rounded " ++ classes}>
    {text |> str}
  </div>;
};

let showFeedbackSent = feedbackSent =>
  feedbackSent ?
    <div
      className="bg-primary-100 text-primary-600 border border-transparent font-semibold px-3 py-px rounded mr-3">
      {"Feedback Sent" |> str}
    </div> :
    React.null;

let iconSpan = (iconClasses, attachment) => {
  let faClasses =
    switch (attachment |> SubmissionDetails.title) {
    | Some(_) => "far fa-file"
    | None => "fas fa-link"
    };
  <span className={"flex p-2 " ++ iconClasses}>
    <i className=faClasses />
  </span>;
};

let showSubmissions = attachments =>
  switch (attachments) {
  | [] => React.null
  | attachments =>
    <div className="mt-4">
      <div className="text-xs font-semibold"> {"Attachments" |> str} </div>
      <div className="flex flex-wrap">
        {
          attachments
          |> List.map(attachment => {
               let (
                 key,
                 containerClasses,
                 iconClasses,
                 textClasses,
                 text,
                 url,
               ) =
                 switch (attachment |> SubmissionDetails.title) {
                 | Some(title) => (
                     "file-" ++ (attachment |> SubmissionDetails.url),
                     "border-primary-200 bg-primary-200",
                     "bg-primary-200",
                     "bg-primary-100",
                     title,
                     attachment |> SubmissionDetails.url,
                   )
                 | None => (
                     attachment |> SubmissionDetails.url,
                     "border-blue-200 bg-blue-200",
                     "bg-blue-200",
                     "bg-blue-100",
                     attachment |> SubmissionDetails.url,
                     attachment |> SubmissionDetails.url,
                   )
                 };

               <span
                 key
                 className={
                   "mt-2 mr-2 flex items-center border-2 rounded "
                   ++ containerClasses
                 }>
                 {iconSpan(iconClasses, attachment)}
                 <span
                   className={
                     "rounded px-2 py-1 truncate rounded " ++ textClasses
                   }>
                   <a
                     href=url
                     target="_blank"
                     className="course-show-attachments__attachment-title text-xs font-semibold text-primary-600 inline-block truncate align-text-bottom">
                     {text |> str}
                   </a>
                 </span>
               </span>;
             })
          |> Array.of_list
          |> React.array
        }
      </div>
    </div>
  };

let showFeedback = feedback =>
  feedback
  |> List.map(f =>
       <div className="p-4 border border-l-0 border-r-0">
         <MarkdownBlock
           profile=Markdown.Permissive
           markdown={f |> SubmissionDetails.value}
         />
       </div>
     )
  |> Array.of_list
  |> React.array;

[@react.component]
let make = (~authenticityToken, ~submission) => {
  let (state, setState) = React.useState(() => {submission: submission});
  <div className="mt-2 rounded-lg bg-white shadow shadow overflow-hidden">
    <div className="p-4 md:p-6 flex justify-between">
      <div> {"submission" |> str} </div>
      <div className="text-xs flex">
        {
          showFeedbackSent(
            submission |> SubmissionDetails.feedback |> ListUtils.isNotEmpty,
          )
        }
        {showSubmissionStatus(submission)}
      </div>
    </div>
    <div className="p-4 md:p-6 bg-gray-200">
      <MarkdownBlock
        profile=Markdown.Permissive
        markdown={submission |> SubmissionDetails.description}
      />
      {showSubmissions(submission |> SubmissionDetails.attachments)}
    </div>
    <div> {showFeedback(submission |> SubmissionDetails.feedback)} </div>
  </div>;
};
