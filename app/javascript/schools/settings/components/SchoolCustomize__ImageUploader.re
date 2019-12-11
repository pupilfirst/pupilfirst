[@bs.config {jsx: 3}];

let str = ReasonReact.string;

let optionalImageLabelText = (optionalImageName, optionalSelectedImageName) =>
  switch (optionalSelectedImageName) {
  | Some(name) =>
    <span>
      {"You have selected " |> str}
      <code className="mr-1"> {name |> str} </code>
      {" to replace the current image." |> str}
    </span>
  | None =>
    switch (optionalImageName) {
    | Some(existingName) =>
      <span> {"Please pick a file to replace " ++ existingName |> str} </span>
    | None => "Please choose an image file to customize" |> str
    }
  };

[@react.component]
let make =
    (
      ~id,
      ~disabled,
      ~name,
      ~onChange,
      ~labelText,
      ~optionalImageName,
      ~optionalSelectedImageName,
      ~errorState,
      ~errorMessage="must be a JPEG / PNG under 2 MB in size",
    ) => {
  <div key=id className="mt-4">
    <label
      className="block tracking-wide text-gray-800 text-xs font-semibold"
      htmlFor=id>
      {labelText |> str}
    </label>
    <input
      disabled
      className="hidden"
      name
      type_="file"
      accept=".jpg,.jpeg,.png,.gif,image/x-png,image/gif,image/jpeg"
      id
      required=false
      multiple=false
      onChange
    />
    <label className="file-input-label mt-2" htmlFor=id>
      <i className="fas fa-upload" />
      <span className="ml-2 truncate">
        {optionalImageLabelText(optionalImageName, optionalSelectedImageName)}
      </span>
    </label>
    <School__InputGroupError message=errorMessage active=errorState />
  </div>;
};
