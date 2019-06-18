[@bs.config {jsx: 3}];

let str = React.string;

open CourseShow__Types;

[@react.component]
let make = (~targetDetails) =>
  <div>
    <div className="flex justify-between border-b pb-2">
      <h4> {"Your Submissions" |> str} </h4>
      <button className="btn btn-primary btn-small">
        <span className="hidden md:inline">
          {"Add another submission" |> str}
        </span>
        <span className="md:hidden"> {"Add another" |> str} </span>
      </button>
    </div>
    {
      targetDetails
      |> TargetDetails.submissions
      |> List.map(submission => {
           let attachments =
             targetDetails
             |> TargetDetails.submissionAttachments
             |> List.filter(a =>
                  a
                  |> SubmissionAttachment.submissionId
                  == (submission |> Submission.id)
                );
           <div key={submission |> Submission.id} className="mt-4">
             <div className="text-xs font-bold">
               {
                 "Submitted on "
                 ++ (submission |> Submission.createdAtPretty)
                 |> str
               }
             </div>
             <div
               className="mt-2 border-2 rounded-lg bg-gray-200 border-gray-200 p-4 whitespace-pre-wrap">
               {submission |> Submission.description |> str}
               {
                 attachments |> ListUtils.isEmpty ?
                   React.null :
                   <div className="mt-2">
                     <div className="text-xs font-bold">
                       {"Attachments" |> str}
                     </div>
                     <CoursesShow__Attachments
                       removeAttachmentCB=None
                       attachments={
                         SubmissionAttachment.onlyAttachments(attachments)
                       }
                     />
                   </div>
               }
             </div>
           </div>;
         })
      |> Array.of_list
      |> React.array
    }
  </div>;
