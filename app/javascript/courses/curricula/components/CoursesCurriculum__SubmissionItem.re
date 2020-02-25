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
  (index |> string_of_int) ++ ChecklistItem.kindAsString(checklistItem);
};

let placeholder = (id, checklistItem) => {
  let title = checklistItem |> ChecklistItem.title;
  let optional = checklistItem |> ChecklistItem.optional;
  <div className="flex items-center">
    <PfIcon
      className={kindIconClasses(checklistItem |> ChecklistItem.result)}
    />
    <label htmlFor=id className="font-semibold text-sm pl-2 tracking-wide">
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
      className="cursor-pointer truncate h-10 border border-gray-400 focus:outline-none focus:border-primary-400 focus:shadow-inner px-4 items-center font-semibold rounded text-sm mr-2 block w-full"
    />
    {showError(
       "This doesn't look like a valid URL.",
       UrlUtils.isInvalid(true, value),
     )}
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
      className="cursor-pointer truncate h-10 border border-gray-400 focus:outline-none focus:border-primary-400 focus:shadow-inner px-4 items-center font-semibold rounded text-sm mr-2 block w-full"
    />
    {showError(
       "Answer should be less than 250 characters",
       !ChecklistItem.validShortText(value) && notBlank(value),
     )}
  </div>;
};

let showLongText = (value, id, callback) => {
  <div>
    <textarea
      id
      maxLength=1000
      className="h-40 w-full rounded-lg p-4 border border-gray-400 focus:outline-none focus:border-primary-400 focus:shadow-inner rounded-lg"
      placeholder="Describe your work, or leave notes to the reviewer here. If you are submitting a URL, or need to attach a file, use the controls below to add them."
      value
      onChange={e =>
        callback(ChecklistItem.LongText(ReactEvent.Form.target(e)##value))
      }
    />
    {showError(
       "Answer should be less than 1000 characters",
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
            <Checkbox
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
              className="w-1/3 pr-2 pb-2">
              <div
                className="flex justify-between border overflow-hidden rounded border-pink-400 bg-white text-pink-700 hover:text-pink-700">
                <div className="flex">
                  <span
                    className="flex w-10 justify-center items-center p-2 bg-pink-700 text-white">
                    <i className="far fa-file" />
                  </span>
                  <span
                    className="course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-normal truncate w-32 md:w-38 pl-3 pr-2 py-2 leading-loose">
                    {file |> ChecklistItem.filename |> str}
                  </span>
                </div>
                <span
                  className="flex w-8 justify-center items-center p-2 cursor-pointer bg-gray-100 border-l text-gray-700 hover:bg-gray-200 hover:text-gray-900"
                  onClick={_ =>
                    removeFile(callback, files, file |> ChecklistItem.fileId)
                  }>
                  <PfIcon className="if i-times-light text-sm" />
                </span>
              </div>
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
    <div className="md:pl-7 pt-2 pr-0 pb-4">
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
