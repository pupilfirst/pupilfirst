open SchoolCustomize__Types

let str = React.string

let t = I18n.t(~scope="components.SchoolCustomize__ImagesEditor")
let ts = I18n.t(~scope="shared")

type action =
  | SelectLogoOnLightBgFile(string, bool)
  | SelectLogoOnDarkBgFile(string, bool)
  | SelectCoverImageFile(string, bool)
  | SelectIconOnLightBgFile(string, bool)
  | SelectIconOnDarkBgFile(string, bool)
  | BeginUpdate
  | ErrorOccured
  | DoneUpdating

type state = {
  logoOnLightBgFilename: option<string>,
  logoOnDarkBgFilename: option<string>,
  logoOnLightBgInvalid: bool,
  logoOnDarkBgInvalid: bool,
  coverImageFilename: option<string>,
  coverImageInvalid: bool,
  iconOnLightBgFilename: option<string>,
  iconOnLightBgInvalid: bool,
  iconOnDarkBgFilename: option<string>,
  iconOnDarkBgInvalid: bool,
  updating: bool,
  formDirty: bool,
}

let updateButtonText = updating => updating ? {ts("updating") ++ "..."} : t("update_images")

let formId = "sc-images-editor__form"

let handleUpdateImages = (send, updateImagesCB, event) => {
  event |> ReactEvent.Form.preventDefault
  send(BeginUpdate)

  let element = ReactDOM.querySelector("#" ++ formId)
  switch element {
  | Some(element) =>
    Api.sendFormData(
      "/school/images",
      DomUtils.FormData.create(element),
      json => {
        Notification.success(ts("notifications.done_exclamation"), t("updated_notification"))
        updateImagesCB(json)
        send(DoneUpdating)
      },
      () => send(ErrorOccured),
    )
  | None => ()
  }
}

let updateButtonDisabled = state =>
  if state.updating {
    true
  } else {
    !state.formDirty ||
    (state.logoOnLightBgInvalid ||
    state.iconOnLightBgInvalid ||
    state.iconOnDarkBgInvalid ||
    state.logoOnDarkBgInvalid)
  }

let maxAllowedSize = 2 * 1024 * 1024

let isInvalidImageFile = image =>
  switch image["_type"] {
  | "image/jpeg"
  | "image/png" => false
  | _ => true
  } ||
  image["size"] > maxAllowedSize

let updateLogoOnLightBg = (send, event) => {
  let imageFile = ReactEvent.Form.target(event)["files"][0]
  send(SelectLogoOnLightBgFile(imageFile["name"], imageFile->isInvalidImageFile))
}

let updateLogoOnDarkBg = (send, event) => {
  let imageFile = ReactEvent.Form.target(event)["files"][0]
  send(SelectLogoOnDarkBgFile(imageFile["name"], imageFile->isInvalidImageFile))
}

let updateCoverImage = (send, event) => {
  let imageFile = ReactEvent.Form.target(event)["files"][0]
  send(SelectCoverImageFile(imageFile["name"], imageFile->isInvalidImageFile))
}

let updateIconOnLightBg = (send, event) => {
  let imageFile = ReactEvent.Form.target(event)["files"][0]
  send(SelectIconOnLightBgFile(imageFile["name"], imageFile->isInvalidImageFile))
}

let updateIconOnDarkBg = (send, event) => {
  let imageFile = ReactEvent.Form.target(event)["files"][0]
  send(SelectIconOnDarkBgFile(imageFile["name"], imageFile->isInvalidImageFile))
}

let imageUploader = (
  ~id,
  ~disabled,
  ~name,
  ~onChange,
  ~labelText,
  ~optionalImageLabel,
  ~errorState,
  ~errorMessage,
) =>
  <div key=id className="mt-4">
    <label className="block tracking-wide text-gray-800 text-xs font-semibold" htmlFor=id>
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
      <i className="fas fa-upload text-primary-300 text-lg" />
      <span className="ms-2 truncate"> optionalImageLabel </span>
    </label>
    <School__InputGroupError message=errorMessage active=errorState />
  </div>

let initialState = () => {
  logoOnLightBgFilename: None,
  logoOnDarkBgFilename: None,
  logoOnLightBgInvalid: false,
  logoOnDarkBgInvalid: false,
  coverImageFilename: None,
  coverImageInvalid: false,
  iconOnLightBgFilename: None,
  iconOnLightBgInvalid: false,
  iconOnDarkBgFilename: None,
  iconOnDarkBgInvalid: false,
  updating: false,
  formDirty: false,
}

let reducer = (state, action) =>
  switch action {
  | SelectLogoOnLightBgFile(name, invalid) => {
      ...state,
      logoOnLightBgFilename: Some(name),
      logoOnLightBgInvalid: invalid,
      formDirty: true,
    }
  | SelectLogoOnDarkBgFile(name, invalid) => {
      ...state,
      logoOnDarkBgFilename: Some(name),
      logoOnDarkBgInvalid: invalid,
      formDirty: true,
    }
  | SelectIconOnLightBgFile(name, invalid) => {
      ...state,
      iconOnLightBgFilename: Some(name),
      iconOnLightBgInvalid: invalid,
      formDirty: true,
    }
  | SelectIconOnDarkBgFile(name, invalid) => {
      ...state,
      iconOnDarkBgFilename: Some(name),
      iconOnDarkBgInvalid: invalid,
      formDirty: true,
    }
  | SelectCoverImageFile(name, invalid) => {
      ...state,
      coverImageFilename: Some(name),
      coverImageInvalid: invalid,
      formDirty: true,
    }
  | BeginUpdate => {...state, updating: true}
  | ErrorOccured => {...state, updating: false}
  | DoneUpdating => initialState()
  }

@react.component
let make = (~customizations, ~updateImagesCB, ~authenticityToken) => {
  let (state, send) = React.useReducer(reducer, initialState())
  let logoOnLightBg = customizations->Customizations.logoOnLightBg
  let logoOnDarkBg = customizations->Customizations.logoOnDarkBg
  let coverImage = customizations->Customizations.coverImage
  let iconOnLightBg = customizations->Customizations.iconOnLightBg
  let iconOnDarkBg = customizations->Customizations.iconOnDarkBg

  <form
    className="mx-8 pt-8"
    id=formId
    key="sc-images-editor__form"
    onSubmit={handleUpdateImages(send, updateImagesCB)}>
    <input name="authenticity_token" type_="hidden" value=authenticityToken />
    <h5 className="uppercase text-center border-b border-gray-300 pb-2">
      {t("manage_images") |> str}
    </h5>
    <DisablingCover disabled=state.updating>
      <SchoolCustomize__ImageFileInput
        autoFocus=true
        id="sc-images-editor__logo-on-400-bg-input"
        disabled=state.updating
        name="logo_on_light_bg"
        onChange={updateLogoOnLightBg(send)}
        labelText={t("logo_light_label")}
        imageName={logoOnLightBg |> OptionUtils.map(Customizations.filename)}
        selectedImageName=state.logoOnLightBgFilename
        errorState=state.logoOnLightBgInvalid
      />
      <SchoolCustomize__ImageFileInput
        autoFocus=true
        id="sc-images-editor__logo-dark-on-400-bg-input"
        disabled=state.updating
        name="logo_on_dark_bg"
        onChange={updateLogoOnDarkBg(send)}
        labelText={t("logo_dark_label")}
        imageName={Customizations.filename->OptionUtils.map(logoOnDarkBg)}
        selectedImageName=state.logoOnDarkBgFilename
        errorState=state.logoOnDarkBgInvalid
      />
      <SchoolCustomize__ImageFileInput
        id="sc-images-editor__icon-light-input"
        disabled=state.updating
        name="icon_on_light_bg"
        onChange={updateIconOnLightBg(send)}
        labelText={t("icon_light_label")}
        imageName=Some(iconOnLightBg->Customizations.filename)
        selectedImageName=state.iconOnLightBgFilename
        errorState=state.iconOnLightBgInvalid
      />
      <SchoolCustomize__ImageFileInput
        id="sc-images-editor__icon-dark-input"
        disabled=state.updating
        name="icon_on_dark_bg"
        onChange={updateIconOnDarkBg(send)}
        labelText={t("icon_dark_label")}
        imageName=Some(iconOnDarkBg->Customizations.filename)
        selectedImageName=state.iconOnDarkBgFilename
        errorState=state.iconOnDarkBgInvalid
      />
      <SchoolCustomize__ImageFileInput
        id="sc-images-editor__cover-image-input"
        disabled=state.updating
        name="cover_image"
        onChange={updateCoverImage(send)}
        labelText={t("cover_image")}
        imageName={coverImage |> OptionUtils.map(Customizations.filename)}
        selectedImageName=state.coverImageFilename
        errorState=state.coverImageInvalid
      />
      <div className="flex justify-end">
        <button
          type_="submit"
          key="sc-images-editor__update-button"
          disabled={updateButtonDisabled(state)}
          className="btn btn-primary btn-large mt-6">
          {updateButtonText(state.updating) |> str}
        </button>
      </div>
    </DisablingCover>
  </form>
}
