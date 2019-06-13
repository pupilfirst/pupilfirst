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

[@react.component]
let make =
    (~authenticityToken, ~attachFileCB, ~attachUrlCB, ~attachingCB, ~disabled) => {
  let (selection, setSelection) = React.useState(() => UploadFile);

  <DisablingCover disabled message="Uploading file...">
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
        | AddUrl => <CoursesShow__UrlForm attachUrlCB />
        }
      }
    </div>
  </DisablingCover>;
};
