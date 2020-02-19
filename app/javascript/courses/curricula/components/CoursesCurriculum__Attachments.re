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
      {attachments
       |> List.map(attachment => {
            let (key, containerClasses, iconClasses, textClasses, text, url) =
              switch (attachment) {
              | SubmissionAttachment.Link(url) => (
                  url,
                  "border-blue-400 bg-blue-200 text-blue-700 hover:border-blue-600 hover:text-blue-800",
                  "bg-blue-200",
                  "bg-blue-100",
                  url,
                  url,
                )
              | File(id, title, url) => (
                  "file-" ++ id,
                  "border-primary-400 bg-primary-200 text-primary-500 hover:border-primary-600 hover:text-primary-700",
                  "bg-primary-200",
                  "bg-primary-100",
                  title,
                  url,
                )
              };

            <a
              href=url
              target="_blank"
              key
              className={
                "mt-2 mr-3 flex items-center border overflow-hidden shadow rounded hover:shadow-md "
                ++ containerClasses
              }>
              {iconSpan(removeAttachmentCB, iconClasses, attachment)}
              <span
                className={
                  "rounded text-xs font-semibold inline-block whitespace-normal truncate w-48 md:w-50 h-full px-3 py-1 leading-loose "
                  ++ textClasses
                }>
                {text |> str}
              </span>
            </a>;
          })
       |> Array.of_list
       |> React.array}
    </div>
  };
