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
  <span
    className={
      "flex h-full w-8 justify-center items-center p-2 " ++ iconClasses
    }>
    <i className=faClasses />
  </span>;
};

let showSubmissions = attachments =>
  switch (attachments) {
  | [||] => React.null
  | attachments =>
    <div className="mt-3">
      <h5 className="text-xs font-semibold"> {"Attachments" |> str} </h5>
      <div className="flex flex-wrap">
        {
          attachments
          |> Array.map(attachment => {
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
                     "border-primary-400 bg-primary-200 text-primary-500 hover:border-primary-600 hover:text-primary-700",
                     "bg-primary-200",
                     "bg-primary-100",
                     title,
                     attachment |> SubmissionDetails.url,
                   )
                 | None => (
                     attachment |> SubmissionDetails.url,
                     "border-blue-400 bg-blue-200 text-blue-700 hover:border-blue-600 hover:text-blue-800",
                     "bg-blue-200",
                     "bg-blue-100",
                     attachment |> SubmissionDetails.url,
                     attachment |> SubmissionDetails.url,
                   )
                 };

               <a
                 href=url
                 target="_blank"
                 className={
                   "mt-2 mr-3 flex items-center border overflow-hidden shadow rounded hover:shadow-md  "
                   ++ containerClasses
                 }>
                 {iconSpan(iconClasses, attachment)}
                 <span
                   className={
                     "course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-normal truncate w-32 md:w-42 h-full px-3 py-1 leading-loose "
                     ++ textClasses
                   }>
                   {text |> str}
                 </span>
               </a>;
             })
          |> React.array
        }
      </div>
    </div>
  };

let showFeedback = feedback =>
  feedback
  |> Array.map(f =>
       <div className="border-t p-4 md:p-6 flex">
         <div className="flex-shrink-0 w-10 h-10 bg-gray-300 rounded-full">
           <img src={f |> Feedback.coachAvatarUrl} />
         </div>
         <div className="flex-grow ml-3">
           <p className="text-xs leading-tight"> {"Feedback from:" |> str} </p>
           <div>
             <h4 className="font-semibold text-base inline-block">
               {f |> Feedback.coachName |> str}
             </h4>
             {
               switch (f |> Feedback.coachTitle) {
               | Some(title) =>
                 <span className="inline-block text-xs text-gray-700 ml-2">
                   {title |> str}
                 </span>
               | None => React.null
               }
             }
           </div>
           <div>
             <p
               className="text-xs leading-tight bg-gray-200 inline-block rounded p-1 mt-4">
               {f |> Feedback.createdAtPretty |> str}
             </p>
             <MarkdownBlock
               className="mt-1"
               profile=Markdown.Permissive
               markdown={f |> Feedback.value}
             />
           </div>
         </div>
       </div>
     )
  |> React.array;

[@react.component]
let make = (~authenticityToken, ~submission, ~gradeLabels) => {
  let (state, setState) = React.useState(() => {submission: submission});
  <div
    className="mt-6 rounded-b-lg bg-white border-t-3 border-orange-300 shadow overflow-hidden">
    <div
      className="p-4 md:px-6 md:py-5 border-b bg-white flex items-center justify-between">
      <h2 className="font-semibold text-sm lg:text-base">
        {"Submission" |> str}
      </h2>
      <div className="text-xs flex">
        {
          showFeedbackSent(
            submission |> SubmissionDetails.feedback |> ArrayUtils.isNotEmpty,
          )
        }
        {showSubmissionStatus(submission)}
      </div>
    </div>
    <div className="p-4 md:px-6 md:pt-2 bg-gray-100 border-b">
      <MarkdownBlock
        profile=Markdown.Permissive
        markdown={submission |> SubmissionDetails.description}
      />
      {showSubmissions(submission |> SubmissionDetails.attachments)}
    </div>
    <CoursesReview__GradeCard
      gradeLabels
      evaluvationCriteria={submission |> SubmissionDetails.evaluationCriteria}
      grades={submission |> SubmissionDetails.grades}
    />
    <div> {showFeedback(submission |> SubmissionDetails.feedback)} </div>
  </div>;
};