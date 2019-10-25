open SchoolCustomize__Types;

let str = ReasonReact.string;

type action =
  | SelectLogoOnLightBgFile(string, bool)
  | SelectLogoOnDarkBgFile(string, bool)
  | SelectIconFile(string, bool)
  | BeginUpdate
  | ErrorOccured
  | DoneUpdating;

type state = {
  logoOnLightBgFilename: option(string),
  logoOnLightBgInvalid: bool,
  logoOnDarkBgFilename: option(string),
  logoOnDarkBgInvalid: bool,
  iconFilename: option(string),
  iconInvalid: bool,
  updating: bool,
  formDirty: bool,
};

let component = ReasonReact.reducerComponent("SchoolCustomize__ImagesEditor");

let updateButtonText = updating => updating ? "Updating..." : "Update Images";

let formId = "sc-images-editor__form";

let handleUpdateImages = (send, updateImagesCB, event) => {
  event |> ReactEvent.Form.preventDefault;
  send(BeginUpdate);

  let element = ReactDOMRe._getElementById(formId);
  switch (element) {
  | Some(element) =>
    Api.sendFormData(
      "/school/images",
      DomUtils.FormData.create(element),
      json => {
        Notification.success(
          "Done!",
          "Images have been updated successfully.",
        );
        updateImagesCB(json);
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
    !state.formDirty
    || state.logoOnLightBgInvalid
    || state.logoOnDarkBgInvalid
    || state.iconInvalid;
  };

let optionalImageLabelText = (image, selectedFilename) =>
  switch (selectedFilename) {
  | Some(name) =>
    <span>
      {"You have selected " |> str}
      <code className="mr-1"> {name |> str} </code>
      {" to replace the current image." |> str}
    </span>
  | None =>
    switch (image) {
    | Some(existingImage) =>
      <span>
        {"Please pick a file to replace " |> str}
        <code> {existingImage |> Customizations.filename |> str} </code>
      </span>
    | None => "Please choose an image file to customize" |> str
    }
  };

let iconLabelText = (icon, iconFilename) =>
  switch (iconFilename) {
  | Some(name) =>
    <span>
      {"You have selected " |> str}
      <code className="mr-1"> {name |> str} </code>
      {" to replace the current icon." |> str}
    </span>
  | None =>
    <span>
      {"Please pick a file to replace " |> str}
      <code> {icon |> Customizations.filename |> str} </code>
    </span>
  };

let maxAllowedSize = 2 * 1024 * 1024;

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

let updateLogoOnLightBg = (send, event) => {
  let imageFile = ReactEvent.Form.target(event)##files[0];
  send(
    SelectLogoOnLightBgFile(imageFile##name, imageFile |> isInvalidImageFile),
  );
};

let updateLogoOnDarkBg = (send, event) => {
  let imageFile = ReactEvent.Form.target(event)##files[0];
  send(
    SelectLogoOnDarkBgFile(imageFile##name, imageFile |> isInvalidImageFile),
  );
};

let updateIcon = (send, event) => {
  let imageFile = ReactEvent.Form.target(event)##files[0];
  send(SelectIconFile(imageFile##name, imageFile |> isInvalidImageFile));
};

let make = (~customizations, ~updateImagesCB, ~authenticityToken, _children) => {
  ...component,
  initialState: () => {
    logoOnLightBgFilename: None,
    logoOnLightBgInvalid: false,
    logoOnDarkBgFilename: None,
    logoOnDarkBgInvalid: false,
    iconFilename: None,
    iconInvalid: false,
    updating: false,
    formDirty: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | SelectLogoOnLightBgFile(name, invalid) =>
      ReasonReact.Update({
        ...state,
        logoOnLightBgFilename: Some(name),
        logoOnLightBgInvalid: invalid,
        formDirty: true,
      })
    | SelectLogoOnDarkBgFile(name, invalid) =>
      ReasonReact.Update({
        ...state,
        logoOnDarkBgFilename: Some(name),
        logoOnDarkBgInvalid: invalid,
        formDirty: true,
      })
    | SelectIconFile(name, invalid) =>
      ReasonReact.Update({
        ...state,
        iconFilename: Some(name),
        iconInvalid: invalid,
        formDirty: true,
      })
    | BeginUpdate => ReasonReact.Update({...state, updating: true})
    | ErrorOccured => ReasonReact.Update({...state, updating: false})
    | DoneUpdating =>
      ReasonReact.Update({
        updating: false,
        formDirty: false,
        logoOnLightBgFilename: None,
        logoOnLightBgInvalid: false,
        logoOnDarkBgFilename: None,
        logoOnDarkBgInvalid: false,
        iconFilename: None,
        iconInvalid: false,
      })
    },
  render: ({state, send}) => {
    let logoOnLightBg = customizations |> Customizations.logoOnLightBg;
    let logoOnDarkBg = customizations |> Customizations.logoOnDarkBg;
    let icon = customizations |> Customizations.icon;

    <form
      className="mx-8 pt-8"
      id=formId
      key="sc-images-editor__form"
      onSubmit={handleUpdateImages(send, updateImagesCB)}>
      <input
        name="authenticity_token"
        type_="hidden"
        value=authenticityToken
      />
      <h5 className="uppercase text-center border-b border-gray-400 pb-2">
        {"Manage Images" |> str}
      </h5>
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
            name="logo_on_light_bg"
            type_="file"
            accept=".jpg,.jpeg,.png,.gif,image/x-png,image/gif,image/jpeg"
            id="sc-images-editor__logo-on-400-bg-input"
            required=false
            multiple=false
            onChange={updateLogoOnLightBg(send)}
          />
          <label
            className="file-input-label mt-2"
            htmlFor="sc-images-editor__logo-on-400-bg-input">
            <i className="fas fa-upload" />
            <span className="ml-2 truncate">
              {
                optionalImageLabelText(
                  logoOnLightBg,
                  state.logoOnLightBgFilename,
                )
              }
            </span>
          </label>
          <School__InputGroupError.Jsx2
            message="must be a JPEG / PNG under 2 MB in size"
            active={state.logoOnLightBgInvalid}
          />
        </div>
        <div
          key="sc-images-editor__logo-on-600-bg-input-group" className="mt-4">
          <label
            className="block tracking-wide text-gray-800 text-xs font-semibold"
            htmlFor="sc-images-editor__logo-on-600-bg-input">
            {"Logo on a dark background" |> str}
          </label>
          <input
            disabled={state.updating}
            className="hidden"
            name="logo_on_dark_bg"
            type_="file"
            accept=".jpg,.jpeg,.png,.gif,image/x-png,image/gif,image/jpeg"
            id="sc-images-editor__logo-on-600-bg-input"
            required=false
            multiple=false
            onChange={updateLogoOnDarkBg(send)}
          />
          <label
            className="file-input-label mt-2"
            htmlFor="sc-images-editor__logo-on-600-bg-input">
            <i className="fas fa-upload" />
            <span className="ml-2 truncate">
              {
                optionalImageLabelText(
                  logoOnDarkBg,
                  state.logoOnDarkBgFilename,
                )
              }
            </span>
          </label>
          <School__InputGroupError.Jsx2
            message="must be a JPEG / PNG under 2 MB in size"
            active={state.logoOnDarkBgInvalid}
          />
        </div>
        <div key="sc-images-editor__icon-input-group" className="mt-4">
          <label
            className="block tracking-wide text-gray-800 text-xs font-semibold"
            htmlFor="sc-images-editor__icon-input">
            {"Icon" |> str}
          </label>
          <input
            disabled={state.updating}
            className="hidden"
            name="icon"
            type_="file"
            accept=".jpg,.jpeg,.png,.gif,image/x-png,image/gif,image/jpeg"
            id="sc-images-editor__icon-input"
            required=false
            multiple=false
            onChange={updateIcon(send)}
          />
          <label
            className="file-input-label mt-2"
            htmlFor="sc-images-editor__icon-input">
            <i className="fas fa-upload" />
            <span className="ml-2 truncate">
              {iconLabelText(icon, state.iconFilename)}
            </span>
          </label>
          <School__InputGroupError.Jsx2
            message="must be a JPEG / PNG under 2 MB in size"
            active={state.iconInvalid}
          />
        </div>
        <div className="flex justify-end">
          <button
            type_="submit"
            key="sc-images-editor__update-button"
            disabled={updateButtonDisabled(state)}
            className="btn btn-primary btn-large mt-6">
            {updateButtonText(state.updating) |> str}
          </button>
        </div>
      </DisablingCover.Jsx2>
    </form>;
  },
};
