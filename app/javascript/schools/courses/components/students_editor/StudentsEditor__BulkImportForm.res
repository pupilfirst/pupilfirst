let str = React.string

open StudentsEditor__Types

let t = I18n.t(~scope="components.StudentsEditor__BulkImportForm")

module CSVData = {
  type t = StudentCSVData.t
}

module CSVReader = CSVReader.Make(CSVData)

type fileInvalid = InvalidCSVFile | EmptyFile | InvalidTemplate | ExceededEntries

type state = {
  fileInfo: option<CSVReader.fileInfo>,
  saving: bool,
  csvData: array<StudentCSVData.t>,
  fileInvalid: option<fileInvalid>,
  errors: array<CSVDataError.t>,
}

let initialState = {
  fileInfo: None,
  saving: false,
  csvData: [],
  fileInvalid: None,
  errors: [],
}

let validTemplate = csvData => {
  let firstRow = Js.Array.unsafe_get(csvData, 0)
  StudentCSVData.name(firstRow)->Belt.Option.isSome
}

let validateFile = (csvData, fileInfo) => {
  Js.log(CSVReader.fileSize(fileInfo))
  CSVReader.fileSize(fileInfo) > 100000 || CSVReader.fileType(fileInfo) != "text/csv"
    ? Some(InvalidCSVFile)
    : csvData |> ArrayUtils.isEmpty
    ? Some(EmptyFile)
    : !validTemplate(csvData)
    ? Some(InvalidTemplate)
    : Array.length(csvData) > 1000
    ? Some(ExceededEntries)
    : None
}

type action =
  | UpdateFileInvalid(option<fileInvalid>)
  | LoadCSVData(array<StudentCSVData.t>, CSVReader.fileInfo)
  | BeginSaving
  | FailSaving

let fileInputText = (~fileInfo: option<CSVReader.fileInfo>) =>
  fileInfo->Belt.Option.mapWithDefault(t("csv_file_input_placeholder"), info => info.name)

let reducer = (state, action) =>
  switch action {
  | UpdateFileInvalid(fileInvalid) => {...state, fileInvalid: fileInvalid}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | LoadCSVData(csvData, fileInfo) => {
      ...state,
      csvData: csvData,
      fileInfo: Some(fileInfo),
      errors: CSVDataError.parseError(csvData),
      fileInvalid: validateFile(csvData, fileInfo),
    }
  }

let saveDisabled = state =>
  state.fileInfo->Belt.Option.isNone ||
  ArrayUtils.isNotEmpty(state.errors) ||
  (state.fileInvalid->Belt.Option.isSome ||
  state.saving)

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

let csvDataTable = (csvData, fileInvalid, errors) => {
  ReactUtils.nullIf(
    <table className="table-auto mt-5 border w-full">
      <thead>
        <tr className="bg-gray-200">
          <th className="text-left"> {"no" |> str} </th>
          <th className="text-left"> {"name" |> str} </th>
          <th className="text-left"> {"email" |> str} </th>
          <th className="text-left"> {"title" |> str} </th>
          <th className="text-left"> {"team_name" |> str} </th>
          <th className="text-left"> {"tags" |> str} </th>
          <th className="text-left"> {"affiliation" |> str} </th>
        </tr>
      </thead>
      <tbody>
        {csvData
        |> Array.mapi((index, studentData) =>
          <tr key={string_of_int(index)}>
            <td className="border border-gray-400 truncate text-sm px-2 py-1">
              {string_of_int(index + 1) |> str}
            </td>
            <td className="border border-gray-400 truncate text-sm px-2 py-1">
              {StudentCSVData.name(studentData)->Belt.Option.getWithDefault("") |> str}
            </td>
            <td className="border border-gray-400 truncate text-sm px-2 py-1">
              {StudentCSVData.email(studentData)->Belt.Option.getWithDefault("") |> str}
            </td>
            <td className="border border-gray-400 truncate text-sm px-2 py-1">
              {StudentCSVData.title(studentData)->Belt.Option.getWithDefault("") |> str}
            </td>
            <td className="border border-gray-400 truncate text-sm px-2 py-1">
              {StudentCSVData.teamName(studentData)->Belt.Option.getWithDefault("") |> str}
            </td>
            <td className="border border-gray-400 truncate text-sm px-2 py-1">
              {StudentCSVData.tags(studentData)->Belt.Option.getWithDefault("") |> str}
            </td>
            <td className="border border-gray-400 truncate text-sm px-2 py-1">
              {StudentCSVData.affiliation(studentData)->Belt.Option.getWithDefault("") |> str}
            </td>
          </tr>
        )
        |> React.array}
      </tbody>
    </table>,
    fileInvalid->Belt.Option.isSome || ArrayUtils.isNotEmpty(errors),
  )
}

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
        <DisablingCover disabled={state.saving} message="Processing...">
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
              inputName="csv"
              cssClass="hidden"
              parserOptions={CSVReader.parserOptions(~header=true, ~skipEmptyLines="true", ())}
              onFileLoaded={(x, y) => {
                send(LoadCSVData(x, y))
              }}
              onError={_ => send(UpdateFileInvalid(Some(InvalidCSVFile)))}
            />
            <label className="file-input-label mt-2" htmlFor="csv-file-input">
              <i className="fas fa-upload mr-2 text-gray-600 text-lg" />
              <span className="truncate"> {fileInputText(~fileInfo=state.fileInfo)->str} </span>
            </label>
            {ReactUtils.nullIf(
              csvDataTable(state.csvData, state.fileInvalid, state.errors),
              ArrayUtils.isEmpty(state.csvData),
            )}
            <School__InputGroupError
              message={switch state.fileInvalid {
              | Some(invalidStatus) =>
                switch invalidStatus {
                | InvalidCSVFile => t("csv_file_errors.invalid")
                | EmptyFile => t("csv_file_errors.empty")
                | InvalidTemplate => t("csv_file_errors.invalid_template")
                | ExceededEntries => t("csv_file_errors.exceeded_entries")
                }
              | None => ""
              }}
              active={state.fileInvalid->Belt.Option.isSome}
            />
          </div>
        </DisablingCover>
      </div>
      <div className="max-w-2xl p-6 mx-auto">
        <button disabled={saveDisabled(state)} className="w-auto btn btn-large btn-primary">
          {t("import_button_text")->str}
        </button>
      </div>
    </div>
  </form>
}
