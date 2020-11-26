open CourseCertificates__Types

let str = React.string
let t = I18n.t(~scope="components.CourseCertificates__CreateDrawer")

type state = {
  name: string,
  imageFilename: option<string>,
  saving: bool,
  fileInvalid: bool,
}

let initialState = {
  name: "",
  imageFilename: None,
  saving: false,
  fileInvalid: false,
}

type action =
  | UpdateName(string)
  | UpdateImageFilename(string, bool)
  | RemoveFilename
  | BeginSaving
  | FailSaving

let reducer = (state, action) =>
  switch action {
  | UpdateName(name) => {...state, name: name}
  | UpdateImageFilename(imageFilename, fileInvalid) => {
      ...state,
      imageFilename: Some(imageFilename),
      fileInvalid: fileInvalid,
    }
  | RemoveFilename => {...state, imageFilename: None}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  }

let saveDisabled = state => state.imageFilename == None || (state.fileInvalid || state.saving)

let submitForm = (course, addCertificateCB, send, event) => {
  ReactEvent.Form.preventDefault(event)
  send(BeginSaving)

  let formData =
    ReactEvent.Form.target(event)->DomUtils.EventTarget.unsafeToElement->DomUtils.FormData.create

  let url = "/school/courses/" ++ (Course.id(course) ++ "/certificates")

  Api.sendFormData(
    url,
    formData,
    json => {
      Notification.success(t("done_exclamation"), t("success_notification"))
      Json.Decode.field("certificate", Certificate.decode, json) |> addCertificateCB
    },
    () => send(FailSaving),
  )
}

let imageInputText = imageFilename =>
  imageFilename->Belt.Option.getWithDefault(t("certificate_base_image_placeholder"))

let selectFile = (send, event) => {
  let files = ReactEvent.Form.target(event)["files"]

  // The user can cancel the selection, which will result in files being an empty array.
  if ArrayUtils.isEmpty(files) {
    send(RemoveFilename)
  } else {
    let file = Js.Array.unsafe_get(files, 0)
    let invalid = FileUtils.isInvalid(~image=true, file)
    send(UpdateImageFilename(file["name"], invalid))
  }
}

@react.component
let make = (~course, ~closeDrawerCB, ~addCertificateCB) => {
  let (state, send) = React.useReducer(reducer, initialState)

  <SchoolAdmin__EditorDrawer closeDrawerCB closeButtonTitle={t("cancel")}>
    <form onSubmit={submitForm(course, addCertificateCB, send)}>
      <input name="authenticity_token" type_="hidden" value={AuthenticityToken.fromHead()} />
      <DisablingCover containerClasses="w-full" disabled=state.saving message="Uploading...">
        <div className="flex flex-col min-h-screen">
          <div className="bg-white flex-grow-0">
            <div className="bg-gray-100 pt-6 pb-4 border-b">
              <div className="max-w-2xl px-4 mx-auto">
                <h5 className="uppercase"> {t("create_action")->str} </h5>
              </div>
            </div>
            <div className="max-w-2xl pt-6 px-4 mx-auto">
              <div className="max-w-2xl pb-6 mx-auto">
                <div className="mt-5">
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="name">
                    {t("name_label")->str}
                  </label>
                  <span className="text-xs"> {" (" ++ (t("optional") ++ ")") |> str} </span>
                  <input
                    className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                    id="name"
                    type_="text"
                    maxLength=30
                    name="name"
                    placeholder={t("name_placeholder")}
                    value=state.name
                    onChange={event => send(UpdateName(ReactEvent.Form.target(event)["value"]))}
                  />
                </div>
                <div className="mt-5">
                  <div>
                    <label
                      className="tracking-wide text-xs font-semibold"
                      htmlFor="certificate-file-input">
                      {t("certificate_base_image_label")->str}
                    </label>
                    <HelpIcon
                      className="ml-2"
                      link="https://docs.pupilfirst.com/#/certificates?id=uploading-a-new-certificate">
                      {str(
                        "This base image must include a full line's space to insert a student's name.",
                      )}
                    </HelpIcon>
                  </div>
                  <input
                    disabled=state.saving
                    className="hidden"
                    name="image"
                    type_="file"
                    id="certificate-file-input"
                    required=false
                    multiple=false
                    onChange={selectFile(send)}
                  />
                  <label className="file-input-label mt-2" htmlFor="certificate-file-input">
                    <i className="fas fa-upload mr-2 text-gray-600 text-lg" />
                    <span className="truncate"> {imageInputText(state.imageFilename)->str} </span>
                  </label>
                  <School__InputGroupError
                    message={t("image_file_invalid")} active=state.fileInvalid
                  />
                </div>
              </div>
            </div>
          </div>
          <div className="bg-gray-100 flex-grow">
            <div className="max-w-2xl p-6 mx-auto">
              <button disabled={saveDisabled(state)} className="w-auto btn btn-large btn-primary">
                {t("create_button_text")->str}
              </button>
            </div>
          </div>
        </div>
      </DisablingCover>
    </form>
  </SchoolAdmin__EditorDrawer>
}
