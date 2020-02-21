[@bs.config {jsx: 3}];

open CoursesCurriculum__Types;

let str = React.string;

let kindIconClasses = result =>
  switch ((result: ChecklistItem.result)) {
  | ShortText(_text) => "if i-short-text-regular md:text-base text-gray-800 if-fw"
  | LongText(_markdown) => "if i-long-text-regular md:text-base text-gray-800 if-fw"
  | Link(_link) => "if i-link-regular md:text-base text-gray-800 if-fw"
  | MultiChoice(_choices, _selected) => "if i-check-circle-alt-regular md:text-base text-gray-800 if-fw"
  | Files(_attachments) => "if i-file-regular md:text-base text-gray-800 if-fw"
  };

let computeId = (index, checklistItem) => {
  (index |> string_of_int) ++ ChecklistItem.kinsAsString(checklistItem);
};

let placeholder = (id, checklistItem) => {
  let title = checklistItem |> ChecklistItem.title;
  let optional = checklistItem |> ChecklistItem.optional;
  <div>
    <PfIcon
      className={kindIconClasses(checklistItem |> ChecklistItem.result)}
    />
    <label htmlFor=id className="font-semibold pl-2">
      {title ++ (optional ? " (optional)" : "") |> str}
    </label>
  </div>;
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

let showLink = (value, id, callback) => {
  <div>
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

let showShortText = (value, id, callback) => {
  <div>
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

let showLongText = (value, id, callback) => {
  <div>
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

let showMultiChoice = (choices, choice, id, callback) => {
  <div>
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

let attachFile = (callback, attachingCB, files, id, filename) => {
  attachingCB(false);
  callback(
    ChecklistItem.Files(
      files |> Array.append([|ChecklistItem.makeFile(id, filename)|]),
    ),
  );
};

let removeFile = (callback, files, id) => {
  callback(
    ChecklistItem.Files(
      files |> Js.Array.filter(a => a |> ChecklistItem.fileId != id),
    ),
  );
};

let showFiles = (files, preview, id, attachingCB, callback) => {
  <div>
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
              <span
                onClick={_ =>
                  removeFile(callback, files, file |> ChecklistItem.fileId)
                }>
                <i className="fas fa-times px-2 text-gray-900" />
              </span>
            </div>
          })
       |> React.array}
    </div>
    {files |> Array.length < 3
       ? <CoursesCurriculum__FileForm
           attachingCB
           attachFileCB={attachFile(callback, attachingCB, files)}
           preview
         />
       : React.null}
  </div>;
};

[@react.component]
let make = (~index, ~checklistItem, ~updateResultCB, ~attachingCB, ~preview) => {
  let id = computeId(index, checklistItem);
  <div className="mt-4">
    {placeholder(id, checklistItem)}
    <div className="pl-7">
      {switch (checklistItem |> ChecklistItem.result) {
       | Files(files) =>
         showFiles(files, preview, id, attachingCB, updateResultCB)
       | Link(link) => showLink(link, id, updateResultCB)
       | ShortText(shortText) => showShortText(shortText, id, updateResultCB)
       | LongText(longText) => showLongText(longText, id, updateResultCB)
       | MultiChoice(choices, selected) =>
         showMultiChoice(choices, selected, id, updateResultCB)
       }}
    </div>
  </div>;
};
