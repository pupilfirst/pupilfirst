[@bs.config {jsx: 3}];

open CoursesCurriculum__Types;

let str = React.string;

let placeholder = (id, title, optional) => {
  <label htmlFor=id className="font-semibold pl-1">
    {title ++ (optional ? " (optional)" : "") |> str}
  </label>;
};

let notBlank = string => {
  string |> String.trim != "";
};

let showError = (message, active) =>
  if (active) {
    <div
      className="mt-1 px-1 py-px rounded text-xs font-semibold text-red-600 bg-red-100 inline-flex items-center">
      <span className="mr-2">
        <i className="fas fa-exclamation-triangle" />
      </span>
      <span> {message |> str} </span>
    </div>;
  } else {
    React.null;
  };

let showLink = (value, index, title, optional, callback) => {
  let id = "link-" ++ index;
  <div className="mt-2">
    {placeholder(id, title, optional)}
    <input
      id
      type_="text"
      value
      onChange={e =>
        callback(ChecklistItem.Link(ReactEvent.Form.target(e)##value))
      }
      placeholder="Type full URL starting with https://..."
      className="mt-2 cursor-pointer truncate h-10 border border-grey-400  px-4 items-center font-semibold rounded text-sm mr-2 block w-full"
    />
    {showError("Invalid url", UrlUtils.isInvalid(true, value))}
  </div>;
};

let showShortText = (value, index, title, optional, callback) => {
  let id = "short-text-" ++ index;
  <div className="mt-2">
    {placeholder(id, title, optional)}
    <input
      id
      type_="text"
      value
      maxLength=250
      onChange={e =>
        callback(ChecklistItem.ShortText(ReactEvent.Form.target(e)##value))
      }
      placeholder="Add a short text"
      className="mt-2 cursor-pointer truncate h-10 border border-grey-400  px-4 items-center font-semibold rounded text-sm mr-2 block w-full"
    />
    {showError(
       "Answe should be less than 250 characters",
       !ChecklistItem.validShortText(value) && notBlank(value),
     )}
  </div>;
};

let showLongText = (value, index, title, optional, callback) => {
  let id = "long-text-" ++ index;
  <div className="mt-2">
    {placeholder(id, title, optional)}
    <textarea
      id
      maxLength=1000
      className="h-40 w-full rounded-lg mt-4 p-4 border border-gray-400 focus:outline-none focus:border-gray-500 rounded-lg"
      placeholder="Describe your work, or leave notes to the reviewer here. If you are submitting a URL, or need to attach a file, use the controls below to add them."
      value
      onChange={e =>
        callback(ChecklistItem.LongText(ReactEvent.Form.target(e)##value))
      }
    />
    {showError(
       "Answe should be less than 1000 characters",
       !ChecklistItem.validLongText(value) && notBlank(value),
     )}
  </div>;
};

let checkboxOnChange = (choices, itemIndex, callback, event) => {
  ReactEvent.Form.target(event)##checked
    ? callback(ChecklistItem.MultiChoice(choices, Some(itemIndex)))
    : callback(ChecklistItem.MultiChoice(choices, None));
};

let showMultiChoice = (choices, choice, index, title, optional, callback) => {
  let id = "multi-choice-" ++ index;

  <div className="mt-2">
    {placeholder(id, title, optional)}
    <div>
      {choices
       |> Array.mapi((index, label) => {
            let checked =
              choice |> OptionUtils.mapWithDefault(i => i == index, false);
            <Radio
              key={index |> string_of_int}
              id={id ++ (index |> string_of_int)}
              label
              onChange={checkboxOnChange(choices, index, callback)}
              checked
            />;
          })
       |> React.array}
    </div>
  </div>;
};

let showFiles = (files, preview, index, titile, optional, callback) => {
  let id = "file-" ++ index;
  let attachFileCB = (id, filename) =>
    callback(
      ChecklistItem.Files(
        files |> Array.append([|ChecklistItem.makeFile(id, filename)|]),
      ),
    );
  <div className="mt-2">
    {placeholder(id, titile, optional)}
    <div className="flex flex-wrap" id>
      {files
       |> Array.map(file => {
            <div
              key={"file-" ++ (file |> ChecklistItem.fileId)}
              target="_blank"
              className="mt-2 mr-3 flex items-center border overflow-hidden shadow rounded hover:shadow-md border-primary-400 bg-primary-200 text-primary-500 hover:border-primary-600 hover:text-primary-700">
              <span
                className="flex h-full w-8 justify-center items-center p-2 bg-primary-200">
                <i className="far fa-file" />
              </span>
              <span
                className="course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-normal truncate w-32 md:w-42 h-full px-3 py-1 leading-loose bg-primary-100">
                {file |> ChecklistItem.filename |> str}
              </span>
            </div>
          })
       |> React.array}
    </div>
    {files |> Array.length < 3
       ? <CoursesCurriculum__FileForm
           attachingCB={() => ()}
           attachFileCB
           preview
         />
       : React.null}
  </div>;
};

let showStatement = (index, title) => {
  let id = "statement-" ++ index;
  <div id className="text-sm font-semibold mt-2 bg-white p-4 border border">
    {title |> str}
  </div>;
};

[@react.component]
let make = (~index, ~checklistItem, ~updateResultCB, ~preview) => {
  let title = checklistItem |> ChecklistItem.title;
  let optional = checklistItem |> ChecklistItem.optional;
  <div>
    {switch (checklistItem |> ChecklistItem.result) {
     | Files(files) =>
       showFiles(files, preview, index, title, optional, updateResultCB)
     | Link(link) => showLink(link, index, title, optional, updateResultCB)
     | ShortText(shortText) =>
       showShortText(shortText, index, title, optional, updateResultCB)
     | LongText(longText) =>
       showLongText(longText, index, title, optional, updateResultCB)
     | MultiChoice(choices, selected) =>
       showMultiChoice(
         choices,
         selected,
         index,
         title,
         optional,
         updateResultCB,
       )
     | Statement => showStatement(index, title)
     }}
  </div>;
};
