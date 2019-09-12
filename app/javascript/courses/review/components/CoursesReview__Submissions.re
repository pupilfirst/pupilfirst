[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

type state = {submission: SubmissionDetails.t};

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
         {f |> SubmissionDetails.value |> str}
       </div>
     )
  |> Array.of_list
  |> React.array;

[@react.component]
let make = (~authenticityToken, ~submission) => {
  let (state, setState) = React.useState(() => {submission: submission});
  <div className="mt-2 rounded-lg bg-white shadow shadow overflow-hidden">
    <div className="p-4 flex justify-between">
      <div> {"submission" |> str} </div>
      <div> {"pending" |> str} </div>
    </div>
    <div className="px-4 py-6 bg-gray-200">
      <div> {submission |> SubmissionDetails.description |> str} </div>
      {showSubmissions(submission |> SubmissionDetails.attachments)}
    </div>
    <div> {showFeedback(submission |> SubmissionDetails.feedback)} </div>
  </div>;
};
