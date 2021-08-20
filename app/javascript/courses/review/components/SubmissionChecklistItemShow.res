module ChecklistItem = SubmissionChecklistItem

let str = React.string

let kindIconClasses = result =>
  switch (result: ChecklistItem.result) {
  | ShortText(_text) => "if i-short-text-light text-base md:text-lg text-gray-800 mt-px"
  | LongText(_markdown) => "if i-long-text-light text-base md:text-lg text-gray-800 mt-px"
  | Link(_link) => "if i-link-light text-base md:text-lg text-gray-800 mt-px"
  | MultiChoice(_text) => "if i-check-circle-alt-light text-base md:text-lg text-gray-800 mt-px"
  | Files(_files) => "if i-file-light text-base md:text-lg text-gray-800 mt-px"
  | AudioRecord(_files) => "if i-file-light text-base md:text-lg text-gray-800 mt-px"
  }

let showFiles = files =>
  <div className="flex flex-wrap">
    {files
    ->Js.Array2.map(file =>
      <a
        key={"file-" ++ ChecklistItem.fileUrl(file)}
        href={ChecklistItem.fileUrl(file)}
        target="_blank"
        className="mt-1 mr-3 flex border overflow-hidden rounded hover:shadow-md border-pink-400 bg-white text-pink-700 hover:border-pink-600 hover:text-pink-700 focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
        <span
          className="course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-nowrap truncate w-32 md:w-42 h-full px-3 py-2 leading-loose">
          {ChecklistItem.fileName(file)->str}
        </span>
        <span className="flex w-10 justify-center items-center p-2 bg-pink-700 text-white">
          <PfIcon className="if i-download-regular" />
        </span>
      </a>
    )
    ->React.array}
  </div>

let showlink = link =>
  <a
    href=link
    target="_blank"
    className="max-w-fc mt-1 mr-3 flex border overflow-hidden rounded hover:shadow-md border-indigo-400 bg-white text-indigo-700 hover:border-blue-600 hover:text-indigo-800 focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
    <span
      className="course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-nowrap truncate w-32 md:w-42 h-full px-3 py-2 leading-loose">
      {link->str}
    </span>
    <span className="flex w-10 justify-center items-center p-2 bg-indigo-700 text-white">
      <PfIcon className="if i-external-link-regular" />
    </span>
  </a>

let statusIcon = (updateChecklistCB, status) =>
  switch (updateChecklistCB, (status: ChecklistItem.status)) {
  | (None, Passed) =>
    <div className="flex items-center space-x-2 text-xs bg-green-100 px-1 py-px mt-1">
      <PfIcon className="if i-check-square-solid text-green-500 text-base bg-white" />
      <p> {"Correct"->str} </p>
    </div>
  | (None, Failed) =>
    <div className="flex items-center space-x-2 text-xs bg-red-100 px-1 py-px mt-px">
      <PfIcon className="if i-times-square-solid text-red-500 text-base bg-white" />
      <p> {"Incorrect"->str} </p>
    </div>
  | (_, _) => React.null
  }

let showStatus = status =>
  switch (status: ChecklistItem.status) {
  | Passed =>
    <div className="bg-green-200 rounded px-1 py-px text-green-800 text-tiny">
      {"Correct"->str}
    </div>
  | Failed =>
    <div className="bg-red-200 rounded px-1 py-px text-red-800 text-tiny"> {"Incorrect"->str} </div>
  | NoAnswer => React.null
  }

let statusButtonSelectedClasses = (status, currentStatus) =>
  "inline-flex items-center cursor-pointer leading-tight font-semibold inline-block text-xs relative hover:bg-gray-100 hover:text-gray-700 " ++
  switch ((currentStatus: ChecklistItem.status), (status: ChecklistItem.status)) {
  | (
      Passed,
      Passed,
    ) => "bg-green-100 hover:bg-green-100 text-green-800 hover:text-green-800 border-green-500 z-10"
  | (
      Failed,
      Failed,
    ) => "bg-red-100 hover:bg-red-100 text-red-700 hover:text-red-700 border-red-500 z-10"
  | (_, _) => "bg-white"
  }

let statusButtonIcon = bool =>
  bool
    ? "if i-times-square-solid text-base if-fw"
    : "if i-square-regular text-base if-fw text-gray-500"

let statusButtonOnClick = (bool, callback, checklist, index, _event) =>
  bool
    ? callback(ChecklistItem.makeNoAnswer(index, checklist))
    : callback(ChecklistItem.makeFailed(index, checklist))

let statusButton = (index, status, callback, checklist) =>
  <div className="mt-2">
    <button
      onClick={statusButtonOnClick(status == ChecklistItem.Failed, callback, checklist, index)}
      className={"border border-gray-500 rounded focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 " ++
      statusButtonSelectedClasses(ChecklistItem.Failed, status)}>
      <span className="w-8 p-2 border-r border-gray-500 flex items-center justify-center">
        <PfIcon className={statusButtonIcon(status == ChecklistItem.Failed)} />
      </span>
      <span className="p-2">
        {(status == ChecklistItem.Failed ? "Mark as correct" : "Mark as incorrect")->str}
      </span>
    </button>
  </div>

let cardHeaderClasses = pending =>
  "text-sm font-semibold flex items-center justify-between " ++ (pending ? "" : "bg-white rounded")

let cardBodyClasses = pending => "pl-7 md:pl-8 " ++ (pending ? "" : "rounded-b")

@react.component
let make = (~index, ~checklistItem, ~updateChecklistCB, ~checklist, ~pending) => {
  let status = ChecklistItem.status(checklistItem)

  <div ariaLabel={ChecklistItem.title(checklistItem)}>
    <div className={cardHeaderClasses(pending)}>
      <div className="flex flex-1 items-start justify-between">
        <div className="flex items-start">
          <PfIcon className={kindIconClasses(ChecklistItem.result(checklistItem))} />
          <p className="ml-3 pr-2 tracking-wide"> {ChecklistItem.title(checklistItem)->str} </p>
        </div>
        {statusIcon(updateChecklistCB, status)}
      </div>
    </div>
    <div className="pl-7 mt-2 text-sm">
      <div>
        {switch ChecklistItem.result(checklistItem) {
        | ShortText(text) => <div> {text->str} </div>
        | LongText(markdown) => <MarkdownBlock profile=Markdown.Permissive markdown />
        | Link(link) => showlink(link)
        | MultiChoice(text) => <div> {text->str} </div>
        | Files(files) => showFiles(files)
        | AudioRecord(file) => <audio src={file.url} controls=true />
        }}
      </div>
      {switch updateChecklistCB {
      | Some(callback) => statusButton(index, status, callback, checklist)
      | None => React.null
      }}
    </div>
  </div>
}
