let str = React.string

let t = I18n.t(~scope="components.SchoolCustomize__ImageFileInput")

let imageLabel = (imageName, selectedImageName) =>
  switch selectedImageName {
  | Some(name) =>
    <span>
      {t("you_selected_pre") ++ " " |> str}
      <code className="me-1"> {name |> str} </code>
      {" " ++ t("you_selected_post") |> str}
    </span>
  | None =>
    switch imageName {
    | Some(existingName) => <span> {t("pick_replace_pre") ++ " " ++ existingName |> str} </span>
    | None => t("choose_customize") |> str
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
  ~errorMessage=t("image_error_message"),
) =>
  <div key=id className="mt-4">
    <label className="block tracking-wide text-gray-800 text-xs font-semibold" htmlFor=id>
      {labelText |> str}
    </label>
    <div
      className="rounded focus-within:outline-none focus-within:ring-2 focus-within:ring-focusColor-500">
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
        <i className="fas fa-upload text-primary-300 text-lg" />
        <span className="ms-2 truncate"> {imageLabel(imageName, selectedImageName)} </span>
      </label>
    </div>
    <School__InputGroupError message=errorMessage active=errorState />
  </div>
