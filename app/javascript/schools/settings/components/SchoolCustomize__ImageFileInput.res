let str = React.string

let imageLabel = (imageName, selectedImageName) =>
  switch selectedImageName {
  | Some(name) =>
    <span>
      {"You have selected " |> str}
      <code className="mr-1"> {name |> str} </code>
      {" to replace the current image." |> str}
    </span>
  | None =>
    switch imageName {
    | Some(existingName) => <span> {"Please pick a file to replace " ++ existingName |> str} </span>
    | None => "Please choose an image file to customize" |> str
    }
  }

@react.component
let make = (
  ~id,
  ~disabled,
  ~name,
  ~onChange,
  ~labelText,
  ~autoFocus=false,
  ~imageName,
  ~selectedImageName,
  ~errorState,
  ~errorMessage="must be a JPEG / PNG under 2 MB in size",
) =>
  <div key=id className="mt-4">
    <label className="block tracking-wide text-gray-800 text-xs font-semibold" htmlFor=id>
      {labelText |> str}
    </label>
    <div className="rounded focus-within:outline-none focus-within:ring-2 focus-within:ring-indigo-500">
      <input
        autoFocus
        disabled
        className="absolute w-0 h-0"
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
        <span className="ml-2 truncate"> {imageLabel(imageName, selectedImageName)} </span>
      </label>
    </div>
    <School__InputGroupError message=errorMessage active=errorState />
  </div>
