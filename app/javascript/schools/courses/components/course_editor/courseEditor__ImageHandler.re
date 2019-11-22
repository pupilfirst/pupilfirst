open CourseEditor__Types;

let str = ReasonReact.string;

type action =
  | SelectImage(string, bool)
  | BeginUpdate
  | ErrorOccured
  | DoneUpdating;

type state = {
  filename: option(string),
  invalidImage: bool,
  updating: bool,
  formDirty: bool,
};

let component = ReasonReact.reducerComponent("CourseEditor__ImageHandler");

let updateButtonText = updating => updating ? "Updating..." : "Update Image";

let formId = "course-editor-form-image-form";

let handleUpdateCB = (json, state, updateImageCB) => {
  let filename =
    switch (state.filename) {
    | Some(filename) => filename
    | None => "unknown"
    };
  let url = json |> Json.Decode.(field("image_url", string));
  let image = Course.makeImage(url, filename);
  updateImageCB(image);
};

let handleUpdateImages = (send, state, course, updateImageCB, event) => {
  event |> ReactEvent.Form.preventDefault;
  send(BeginUpdate);

  let element = ReactDOMRe._getElementById(formId);
  switch (element) {
  | Some(element) =>
    Api.sendFormData(
      "courses/" ++ (course |> Course.id |> string_of_int) ++ "/attach_image",
      DomUtils.FormData.create(element),
      json => {
        Notification.success(
          "Done!",
          "Image have been updated successfully.",
        );
        handleUpdateCB(json, state, updateImageCB);
        send(DoneUpdating);
      },
      () => send(ErrorOccured),
    )
  | None => ()
  };
};

let updateButtonDisabled = state =>
  if (state.updating) {
    true;
  } else {
    !state.formDirty || state.invalidImage;
  };

let optionalImageLabelText = (image, selectedFilename) =>
  switch (selectedFilename) {
  | Some(name) =>
    <span>
      {"You have selected " |> str}
      <code className="mr-1"> {name |> str} </code>
      {". Click to replace the current image." |> str}
    </span>
  | None =>
    switch (image) {
    | Some(existingImage) =>
      <span>
        {"Please pick a file to replace " |> str}
        <code> {existingImage |> Course.filename |> str} </code>
      </span>
    | None => "Please choose an image file to customize course cover" |> str
    }
  };

let maxAllowedSize = 1 * 1024 * 1024;

let isInvalidImageFile = image =>
  (
    switch (image##_type) {
    | "image/jpeg"
    | "image/png" => false
    | _ => true
    }
  )
  ||
  image##size > maxAllowedSize;

let updateImage = (send, event) => {
  let imageFile = ReactEvent.Form.target(event)##files[0];
  send(SelectImage(imageFile##name, imageFile |> isInvalidImageFile));
};

let make = (~course, ~updateImageCB, _children) => {
  ...component,
  initialState: () => {
    filename: None,
    invalidImage: false,
    updating: false,
    formDirty: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | SelectImage(name, invalid) =>
      ReasonReact.Update({
        ...state,
        filename: Some(name),
        invalidImage: invalid,
        formDirty: true,
      })
    | BeginUpdate => ReasonReact.Update({...state, updating: true})
    | DoneUpdating =>
      ReasonReact.Update({...state, updating: false, formDirty: false})
    | ErrorOccured => ReasonReact.Update({...state, updating: false})
    },
  render: ({state, send}) => {
    let image = course |> Course.image;
    <form
      id=formId
      key="sc-images-editor__form"
      onSubmit={handleUpdateImages(send, state, course, updateImageCB)}>
      <input
        name="authenticity_token"
        type_="hidden"
        value={AuthenticityToken.fromHead()}
      />
      <DisablingCover.Jsx2 disabled={state.updating}>
        <div
          key="sc-images-editor__logo-on-400-bg-input-group" className="mt-4">
          <label
            className="block tracking-wide text-gray-800 text-xs font-semibold"
            htmlFor="sc-images-editor__logo-on-400-bg-input">
            {"Logo on a light background" |> str}
          </label>
          <input
            disabled={state.updating}
            className="hidden"
            name="course_cover_image"
            type_="file"
            accept=".jpg,.jpeg,.png,.gif,image/x-png,image/gif,image/jpeg"
            id="sc-images-editor__logo-on-400-bg-input"
            required=false
            multiple=false
            onChange={updateImage(send)}
          />
          <label
            className="file-input-label mt-2"
            htmlFor="sc-images-editor__logo-on-400-bg-input">
            <i className="fas fa-upload" />
            <span className="ml-2 truncate">
              {optionalImageLabelText(image, state.filename)}
            </span>
          </label>
          <School__InputGroupError.Jsx2
            message="must be a JPEG / PNG under 2 MB in size"
            active={state.invalidImage}
          />
        </div>
        <button
          type_="submit"
          key="sc-images-editor__update-button"
          disabled={updateButtonDisabled(state)}
          className="btn btn-primary btn-large mt-6">
          {updateButtonText(state.updating) |> str}
        </button>
      </DisablingCover.Jsx2>
    </form>;
  },
};
