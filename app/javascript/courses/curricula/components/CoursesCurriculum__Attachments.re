[@bs.config {jsx: 3}];

[%bs.raw {|require("./CoursesCurriculum__Attachments.css")|}];

let str = React.string;

open CoursesCurriculum__Types;

let handleClick = (cb, attachment, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  cb(attachment);
};

let iconSpan = (removeAttachmentCB, iconClasses, attachment) =>
  switch (removeAttachmentCB) {
  | Some(cb) =>
    <span
      className={"flex p-2 cursor-pointer " ++ iconClasses}
      onClick={handleClick(cb, attachment)}>
      <i className="fas fa-times" />
    </span>
  | None =>
    let faClasses =
      switch (attachment) {
      | SubmissionAttachment.File(_, _, _) => "far fa-file"
      | Link(_) => "fas fa-link"
      };
    <span className={"flex p-2 " ++ iconClasses}>
      <i className=faClasses />
    </span>;
  };

[@react.component]
let make = (~attachments, ~removeAttachmentCB) =>
  switch (attachments) {
  | [] => React.null
  | attachments =>
    <div className="flex flex-wrap">
      {
        attachments
        |> List.map(attachment => {
             let (key, containerClasses, iconClasses, textClasses, text, url) =
               switch (attachment) {
               | SubmissionAttachment.Link(url) => (
                   url,
                   "border-blue-200 bg-blue-200",
                   "bg-blue-200",
                   "bg-blue-100",
                   url,
                   url,
                 )
               | File(id, title, url) => (
                   "file-" ++ id,
                   "border-primary-200 bg-primary-200",
                   "bg-primary-200",
                   "bg-primary-100",
                   title,
                   url,
                 )
               };

             <span
               key
               className={
                 "mt-2 mr-2 flex items-center border-2 rounded "
                 ++ containerClasses
               }>
               {iconSpan(removeAttachmentCB, iconClasses, attachment)}
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
  };
