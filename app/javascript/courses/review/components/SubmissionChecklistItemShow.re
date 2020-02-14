[@bs.config {jsx: 3}];

module ChecklistItem = SubmissionChecklistItem;

let str = React.string;

let kindIconClasses = result => {
  switch ((result: ChecklistItem.result)) {
  | ShortText(_text) => "fas fa-font"
  | LongText(_markdown) => "fas fa-paragraph"
  | Link(_link) => "fas fa-link"
  | MultiChoice(_text) => "fas fa-tasks"
  | Files(_attachments) => "fas fa-file"
  | None => "fas fa-question"
  };
};

let showFiles = attachments => {
  <div className="flex flex-wrap">
    {attachments
     |> Array.map(attachment => {
          <a
            key={"file-" ++ (attachment |> ChecklistItem.attachmentUrl)}
            href={attachment |> ChecklistItem.attachmentUrl}
            target="_blank"
            className="mt-2 mr-3 flex items-center border overflow-hidden shadow rounded hover:shadow-md border-primary-400 bg-primary-200 text-primary-500 hover:border-primary-600 hover:text-primary-700">
            <span
              className="flex h-full w-8 justify-center items-center p-2 bg-primary-200">
              <i className="far fa-file" />
            </span>
            <span
              className="course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-normal truncate w-32 md:w-42 h-full px-3 py-1 leading-loose bg-primary-100">
              {attachment |> ChecklistItem.attachmentName |> str}
            </span>
          </a>
        })
     |> React.array}
  </div>;
};

let showlink = link =>
  <a
    href=link
    target="_blank"
    className="max-w-fc mt-2 mr-3 flex items-center border overflow-hidden shadow rounded hover:shadow-md border-blue-400 bg-blue-200 text-blue-700 hover:border-blue-600 hover:text-blue-800">
    <span
      className="flex h-full w-8 justify-center items-center p-2 bg-blue-200">
      <i className="fas fa-link" />
    </span>
    <span
      className="course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-normal truncate w-32 md:w-42 h-full px-3 py-1 leading-loose bg-blue-100">
      {link |> str}
    </span>
  </a>;

let statusIcon = status => {
  switch ((status: ChecklistItem.status)) {
  | Passed => <i className="fas fa-check" />
  | Failed => <i className="fas fa-check" />
  | Pending => React.null
  };
};

let showStatus = (status, updateChecklistCB) => {
  switch ((status: ChecklistItem.status)) {
  | Passed =>
    <div
      className="bg-white border border-green-500 rounded-lg px-1 py-px inline-block text-green-500 text-xs">
      {"Passed" |> str}
    </div>
  | Failed =>
    <div
      className="bg-white border border-red-500 rounded-lg px-1 py-px inline-block text-red-500 text-xs">
      {"Failed" |> str}
    </div>
  | Pending =>
    switch (updateChecklistCB) {
    | Some(callback) =>
      <div
        className="bg-white border border-gray-500 rounded-lg px-1 py-px inline-block text-gray-500 text-xs">
        {"Review now" |> str}
      </div>
    | None => React.null
    }
  };
};

let computeShowResult = (checklistItem, updateChecklistCB) => {
  switch (updateChecklistCB, checklistItem |> ChecklistItem.status) {
  | (None, Pending | Passed | Failed) => true
  | (Some(_), Pending | Failed) => true
  | (Some(_), Passed) => false
  };
};

[@react.component]
let make = (~checklistItem, ~updateChecklistCB) => {
  let (showResult, setShowResult) =
    React.useState(() => computeShowResult(checklistItem, updateChecklistCB));
  <div className="mt-2 ">
    <div className="text-sm font-semibold flex justify-between">
      <div>
        <span>
          <i
            className={kindIconClasses(checklistItem |> ChecklistItem.result)}
          />
        </span>
        <span className="ml-2 md:ml-3 tracking-wide">
          {checklistItem |> ChecklistItem.title |> str}
        </span>
      </div>
      <div className="inline-block">
        {showResult
           ? React.null
           : <button onClick={_ => setShowResult(_ => true)}>
               <i className="fas fa-chevron-circle-down" />
             </button>}
        {statusIcon(checklistItem |> ChecklistItem.status)}
      </div>
    </div>
    {showResult
       ? <div className="ml-6 md:ml-7 ">
           <div>
             {switch (checklistItem |> ChecklistItem.result) {
              | ShortText(text) => <div> {text |> str} </div>
              | LongText(markdown) =>
                <MarkdownBlock profile=Markdown.Permissive markdown />
              | Link(link) => showlink(link)
              | MultiChoice(text) => <div> {text |> str} </div>
              | Files(attachments) => showFiles(attachments)
              | None => <div> {"Handle Empty" |> str} </div>
              }}
           </div>
           {showStatus(
              checklistItem |> ChecklistItem.status,
              updateChecklistCB,
            )}
         </div>
       : React.null}
  </div>;
};
