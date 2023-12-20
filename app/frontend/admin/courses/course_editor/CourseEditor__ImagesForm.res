open CourseEditor__Types

let str = React.string

let t = I18n.t(~scope="components.CourseEditor__ImagesForm")

type action =
  | SelectCover(string, bool)
  | SelectThumb(string, bool)
  | BeginUpdate
  | ErrorOccured
  | DoneUpdating

type state = {
  filenameThumb: option<string>,
  filenameCover: option<string>,
  invalidThumb: bool,
  invalidCover: bool,
  updating: bool,
  formDirty: bool,
}

let updateButtonText = updating =>
  updating ? t("button_text.updating") : t("button_text.update_images")

let formId = "course-editor-form-image-form"

let filename = optionalFilename => optionalFilename->Belt.Option.getWithDefault("unknown")

let handleUpdateCB = (json, state, course, updateCourseCB) => {
  let coverUrl = json |> {
    open Json.Decode
    field("cover_url", optional(string))
  }
  let thumbnailUrl = json |> {
    open Json.Decode
    field("thumbnail_url", optional(string))
  }

  let newCourse =
    course->Course.addImages(
      ~coverUrl,
      ~thumbnailUrl,
      ~coverFilename=filename(state.filenameCover),
      ~thumbnailFilename=filename(state.filenameThumb),
    )

  updateCourseCB(newCourse)
}

let handleUpdateImages = (send, state, course, updateCourseCB, event) => {
  event->ReactEvent.Form.preventDefault
  send(BeginUpdate)

  let element = ReactDOM.querySelector("#" ++ formId)
  switch element {
  | Some(element) =>
    Api.sendFormData(
      "/school/courses/" ++ (Course.id(course) ++ "/attach_images"),
      DomUtils.FormData.create(element),
      json => {
        Notification.success(t("notification_success.title"), t("notification_success.description"))
        handleUpdateCB(json, state, course, updateCourseCB)
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
    !state.formDirty || (state.invalidThumb || state.invalidCover)
  }

let optionalImageLabelText = (image, selectedFilename) =>
  switch selectedFilename {
  | Some(name) =>
    <span>
      {t("image_label.start")->str}
      <code className="me-1"> {name->str} </code>
      {t("image_label.end")->str}
    </span>
  | None =>
    switch image {
    | Some(existingImage) =>
      <span>
        {t("replace_image_label")->str}
        <code> {Course.filename(existingImage)->str} </code>
      </span>
    | None => t("empty_image_label") |> str
    }
  }

let maxAllowedSize = 2 * 1024 * 1024

let isInvalidImageFile = image =>
  switch image["_type"] {
  | "image/jpeg"
  | "image/png" => false
  | _ => true
  } ||
  image["size"] > maxAllowedSize

let updateImage = (send, isCover, event) => {
  let imageFile = ReactEvent.Form.target(event)["files"][0]
  isCover
    ? send(SelectCover(imageFile["name"], imageFile |> isInvalidImageFile))
    : send(SelectThumb(imageFile["name"], imageFile |> isInvalidImageFile))
}

let initialState = () => {
  filenameThumb: None,
  filenameCover: None,
  invalidThumb: false,
  invalidCover: false,
  updating: false,
  formDirty: false,
}

let reducer = (state, action) =>
  switch action {
  | SelectThumb(name, invalid) => {
      ...state,
      filenameThumb: Some(name),
      invalidThumb: invalid,
      formDirty: true,
    }
  | SelectCover(name, invalid) => {
      ...state,
      filenameCover: Some(name),
      invalidCover: invalid,
      formDirty: true,
    }
  | BeginUpdate => {...state, updating: true}
  | DoneUpdating => {...state, updating: false, formDirty: false}
  | ErrorOccured => {...state, updating: false}
  }

@react.component
let make = (~course, ~updateCourseCB) => {
  let (state, send) = React.useReducer(reducer, initialState())

  let thumbnail = course->Course.thumbnail
  let cover = course->Course.cover

  <form
    id=formId
    key="sc-images-editor__form"
    onSubmit={handleUpdateImages(send, state, course, updateCourseCB)}>
    <input name="authenticity_token" type_="hidden" value={AuthenticityToken.fromHead()} />
    <DisablingCover disabled=state.updating>
      <div key="course-images-editor__thumbnail" className="mt-4">
        <label
          className="tracking-wide text-gray-800 text-xs font-semibold"
          htmlFor="sc-images-editor__logo-on-400-bg-input">
          {t("thumbnail.label")->str}
        </label>
        <HelpIcon
          className="text-xs ms-1"
          responsiveAlignment=HelpIcon.NonResponsive(AlignLeft)
          link={t("thumbnail.help_url")}>
          {t("thumbnail.help")->str}
        </HelpIcon>
        <div
          className="rounded focus-within:outline-none focus-within:ring-2 focus-within:ring-focusColor-500">
          <input
            disabled=state.updating
            className="absolute h-0 w-0 focus:outline-none"
            name="course_thumbnail"
            type_="file"
            accept=".jpg,.jpeg,.png,.gif,image/x-png,image/gif,image/jpeg"
            id="course-images-editor__thumbnail"
            required=false
            multiple=false
            onChange={updateImage(send, false)}
          />
          <label className="file-input-label mt-2" htmlFor="course-images-editor__thumbnail">
            <i className="fas fa-upload text-primary-300 text-lg" />
            <span className="ms-2 truncate">
              {optionalImageLabelText(thumbnail, state.filenameThumb)}
            </span>
          </label>
        </div>
        <School__InputGroupError message={t("thumbnail.error_message")} active=state.invalidThumb />
      </div>
      <div key="course-images-editor__cover" className="mt-4">
        <label
          className="tracking-wide text-gray-800 text-xs font-semibold"
          htmlFor="sc-images-editor__logo-on-400-bg-input">
          {t("cover_image.label") |> str}
        </label>
        <HelpIcon
          className="text-xs ms-1"
          responsiveAlignment=HelpIcon.NonResponsive(AlignLeft)
          link={t("cover_image.help_url")}>
          {t("cover_image.help") |> str}
        </HelpIcon>
        <div
          className="rounded focus-within:outline-none focus-within:ring-2 focus-within:ring-focusColor-500">
          <input
            disabled=state.updating
            className="absolute h-0 w-0 focus:outline-none"
            name="course_cover"
            type_="file"
            accept=".jpg,.jpeg,.png,.gif,image/x-png,image/gif,image/jpeg"
            id="course-images-editor__cover"
            required=false
            multiple=false
            onChange={updateImage(send, true)}
          />
          <label className="file-input-label mt-2" htmlFor="course-images-editor__cover">
            <i className="fas fa-upload text-primary-300 text-lg" />
            <span className="ms-2 truncate">
              {optionalImageLabelText(cover, state.filenameCover)}
            </span>
          </label>
        </div>
        <School__InputGroupError
          message={t("cover_image.error_message")} active=state.invalidCover
        />
      </div>
      <button
        type_="submit"
        key="sc-images-editor__update-button"
        disabled={updateButtonDisabled(state)}
        className="btn btn-primary btn-large mt-6">
        {updateButtonText(state.updating) |> str}
      </button>
    </DisablingCover>
  </form>
}
