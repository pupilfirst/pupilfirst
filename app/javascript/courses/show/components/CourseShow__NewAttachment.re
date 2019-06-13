[@bs.config {jsx: 3}];

let str = React.string;

type selection =
  | UploadFile
  | AddUrl;

let tabClasses = (currentSelection, inspectedSelection) => {
  let classes = "mr-1 cursor-pointer border-transparent border-l border-t border-r -mb-px rounded-t";

  if (currentSelection == inspectedSelection) {
    classes ++ " border-gray-400 bg-white";
  } else {
    classes;
  };
};

let urlForm =
  <div className="flex items-center flex-wrap">
    <input
      type_="text"
      placeholder="Type full URL starting with https://..."
      className="mt-2 cursor-pointer truncate h-10 border border-grey-400 border-dashed flex px-4 items-center font-semibold rounded text-sm flex-grow mr-2"
    />
    <button
      className="mt-2 bg-indigo-600 hover:bg-gray-500 text-white text-sm font-semibold py-2 px-6 focus:outline-none">
      {"Attach link" |> str}
    </button>
  </div>;

[@react.component]
let make = (~authenticityToken, ~attachFileCB, ~attachingCB, ~disabled) => {
  let (selection, setSelection) = React.useState(() => UploadFile);

  <DisablingCover disabled>
    <h6 className="pl-1 mt-4"> {"Attach files & links" |> str} </h6>
    <ul className="flex border-b mt-2 border-gray-400">
      <li className={tabClasses(selection, UploadFile)}>
        <a
          onClick={_e => setSelection(_ => UploadFile)}
          className="inline-block text-gray-800 hover:text-indigo-800 p-4 text-xs font-semibold">
          {"Upload File" |> str}
        </a>
      </li>
      <li className={tabClasses(selection, AddUrl)}>
        <a
          onClick={_e => setSelection(_ => AddUrl)}
          className="inline-block text-gray-800 p-4 hover:text-indigo-800 text-xs font-semibold">
          {"Add URL" |> str}
        </a>
      </li>
    </ul>
    <div
      className="bg-white p-4 pt-2 border-l border-r border-b rounded-b border-gray-400">
      {
        switch (selection) {
        | UploadFile =>
          <CourseShow__FileForm authenticityToken attachFileCB attachingCB />
        | AddUrl => urlForm
        }
      }
    </div>
  </DisablingCover>;
};
