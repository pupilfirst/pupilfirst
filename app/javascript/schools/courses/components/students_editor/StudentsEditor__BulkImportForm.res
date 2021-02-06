let str = React.string

open StudentsEditor__Types

let t = I18n.t(~scope="components.StudentsEditor__BulkImportForm")

type state = {
  fileName: option<string>,
  saving: bool,
  csvData: array<StudentCSVData.t>,
  fileInvalid: bool,
}

let initialState = {
  fileName: None,
  saving: false,
  csvData: [],
  fileInvalid: false,
}

type action =
  | UpdateFilename(string)
  | UpdateFileInvalid(bool)
  | LoadCSVData(array<StudentCSVData.t>)
  | RemoveFilename
  | BeginSaving
  | FailSaving

let fileInputText = fileName =>
  fileName->Belt.Option.getWithDefault(t("csv_file_input_placeholder"))


let reducer = (state, action) =>
  switch action {
  | UpdateFilename(imageFilename) => {
      ...state,
      fileName: Some(imageFilename),
    }
  | UpdateFileInvalid(fileInvalid) => {...state, fileInvalid: fileInvalid}
  | RemoveFilename => {...state, fileName: None}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | LoadCSVData(csvData) => {...state, csvData: csvData}
  }

let saveDisabled = state => state.fileName == None || (state.fileInvalid || state.saving)

let submitForm = (courseId, send, event) => {
  ReactEvent.Form.preventDefault(event)
  send(BeginSaving)

  let formData =
    ReactEvent.Form.target(event)->DomUtils.EventTarget.unsafeToElement->DomUtils.FormData.create

  let url = "/school/courses/" ++ courseId ++ "/bulk_import_students"

  Api.sendFormData(
    url,
    formData,
    json => {
      Notification.success(t("done_exclamation"), t("success_notification"))
      Js.log(Json.Decode.field("success", Json.Decode.bool, json))
    },
    () => send(FailSaving),
  )
}

module CSVData = {
  type t = StudentCSVData.t
}

module CSVReader = CSVReader.Make(CSVData)

@react.component
let make = (~courseId) => {
  let (state, send) = React.useReducer(reducer, initialState)
  {ArrayUtils.isNotEmpty(state.csvData) ? Js.log(state.csvData) : ()}
  <form onSubmit={submitForm(courseId, send)}>
    <input name="authenticity_token" type_="hidden" value={AuthenticityToken.fromHead()} />
    <div className="mx-auto bg-white">
      <div className="max-w-2xl p-6 mx-auto">
        <h5 className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
          {t("drawer_heading")->str}
        </h5>
        <div className="mt-5">
          <div>
            <label className="tracking-wide text-xs font-semibold" htmlFor="csv-file-input">
              {t("csv_file_input_label")->str}
            </label>
            <HelpIcon
              className="ml-2"
              link="https://docs.pupilfirst.com/#/certificates?id=uploading-a-new-certificate">
              {str(
                "This file will be used to import students in bulk. Check the sample file for the required format.",
              )}
            </HelpIcon>
          </div>
          <CSVReader
            label=""
            inputId="csv-file-input"
            cssClass="hidden"
            parserOptions=[("header", "true")]
            onFileLoaded={(x, y) => {
              send(LoadCSVData(x))
              send(UpdateFilename(y["name"]))
            }}
            onError={_ => send(UpdateFileInvalid(true))}
          />
          <label className="file-input-label mt-2" htmlFor="csv-file-input">
            <i className="fas fa-upload mr-2 text-gray-600 text-lg" />
            <span className="truncate"> {fileInputText(state.fileName)->str} </span>
          </label>
          <School__InputGroupError message={t("csv_file_invalid")} active=state.fileInvalid />
        </div>
      </div>
      <div className="max-w-2xl p-6 mx-auto">
        <button disabled={saveDisabled(state)} className="w-auto btn btn-large btn-primary">
          {t("import_button_text")->str}
        </button>
      </div>
    </div>
  </form>
}
