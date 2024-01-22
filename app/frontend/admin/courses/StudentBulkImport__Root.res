let str = React.string

open StudentsEditor__Types

let t = I18n.t(~scope="components.StudentBulkImport__Root")
let ts = I18n.ts

type fileInfo = {
  size: int,
  name: string,
}

type fileInvalid =
  | ParseError(string)
  | InvalidCSVFile
  | EmptyFile
  | InvalidTemplate
  | ExceededEntries
  | InvalidData(array<CSVDataError.t>)

type state = {
  fileInfo: option<fileInfo>,
  saving: bool,
  csvData: array<StudentCSVRow.t>,
  fileInvalid: option<fileInvalid>,
  notifyStudents: bool,
  loading: bool,
  cohorts: array<Cohort.t>,
  selectedCohort: option<Cohort.t>,
}

let initialState = {
  fileInfo: None,
  saving: false,
  csvData: [],
  fileInvalid: None,
  notifyStudents: true,
  loading: false,
  cohorts: [],
  selectedCohort: None,
}

let validTemplate = csvData => {
  let firstRow = Js.Array.unsafe_get(csvData, 0)
  StudentCSVRow.name(firstRow)->Belt.Option.isSome
}

let validateFile = (csvData, fileInfo) => {
  fileInfo.size > FileUtils.maxUploadFileSize
    ? Some(InvalidCSVFile)
    : ArrayUtils.isEmpty(csvData)
    ? Some(EmptyFile)
    : !validTemplate(csvData)
    ? Some(InvalidTemplate)
    : Array.length(csvData) > 1000
    ? Some(ExceededEntries)
    : {
        let dataErrors = CSVDataError.parseError(csvData)
        ArrayUtils.isNotEmpty(dataErrors) ? Some(InvalidData(dataErrors)) : None
      }
}

type action =
  | UpdateFileInvalid(option<fileInvalid>)
  | LoadCSVData(array<StudentCSVRow.t>, fileInfo)
  | ClearCSVData
  | ToggleNotifyStudents
  | BeginSaving
  | EndSaving
  | FailSaving
  | SetBaseData(array<Cohort.t>)
  | SetSelectedCohort(Cohort.t)
  | SetLoading
  | ClearLoading

module ParserType = {
  type t = StudentCSVRow.t
}

module CSVParser = Papaparse.Make(ParserType)

let onParseComplete = (send, results, file) => {
  let fileInfo = {
    size: file["size"],
    name: file["name"],
  }

  let expectedHeaders = ["name", "email", "title", "team_name", "tags", "affiliation"]

  let hasExpectedHeaders = switch results["meta"]["fields"] {
  | Some(actualHeaders) => expectedHeaders->Js.Array2.every(Js.Array2.includes(actualHeaders))
  | None => false
  }

  if ArrayUtils.isNotEmpty(results["errors"]) {
    let errorMessage = CSVParser.errorMessage(results["errors"][0])
    send(UpdateFileInvalid(Some(ParseError(errorMessage))))
  } else if !hasExpectedHeaders {
    send(UpdateFileInvalid(Some(InvalidTemplate)))
  } else {
    send(LoadCSVData(results["data"], fileInfo))
  }
}

let onSelectFile = (event, send) => {
  let csvFile = ReactEvent.Form.target(event)["files"][0]

  let config = CSVParser.config(
    ~header=true,
    ~skipEmptyLines=true,
    ~complete=(results, file) => onParseComplete(send, results, file),
    (),
  )
  CSVParser.parseFile(csvFile, config)->ignore
}

let fileInputText = (~fileInfo: option<fileInfo>) =>
  fileInfo->Belt.Option.mapWithDefault(t("csv_file_input.placeholder"), info => info.name)

let reducer = (state, action) =>
  switch action {
  | UpdateFileInvalid(fileInvalid) => {...state, fileInvalid}
  | ClearCSVData => {...state, fileInfo: None, fileInvalid: None, csvData: []}
  | ToggleNotifyStudents => {...state, notifyStudents: !state.notifyStudents}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | EndSaving => initialState
  | LoadCSVData(csvData, fileInfo) => {
      ...state,
      csvData,
      fileInfo: Some(fileInfo),
      fileInvalid: validateFile(csvData, fileInfo),
    }
  | SetBaseData(cohorts) => {...state, cohorts, loading: false}
  | SetSelectedCohort(cohort) => {...state, selectedCohort: Some(cohort)}
  | SetLoading => {...state, loading: true}
  | ClearLoading => {...state, loading: false}
  }
let saveDisabled = state =>
  state.fileInfo->Belt.Option.isNone ||
  state.fileInvalid->Belt.Option.isSome ||
  state.saving ||
  Belt.Option.isNone(state.selectedCohort)

let submitForm = (cohort, exitUrl, send, event) => {
  ReactEvent.Form.preventDefault(event)
  send(BeginSaving)

  let formData =
    ReactEvent.Form.target(event)->DomUtils.EventTarget.unsafeToElement->DomUtils.FormData.create

  switch cohort {
  | Some(c) => {
      let url = "/school/cohorts/" ++ Cohort.id(c) ++ "/bulk_import_students"

      Api.sendFormData(
        url,
        formData,
        json => {
          Json.Decode.field("success", Json.Decode.bool, json)
            ? {
                Notification.success(
                  ts("notifications.done_exclamation"),
                  t("success_notification"),
                )
                RescriptReactRouter.push(exitUrl)
              }
            : ()
          send(EndSaving)
        },
        () => send(FailSaving),
      )
    }
  | None => ()
  }
}

module CohortFragment = Cohort.Fragment
module StudentBulkImportDataQuery = %graphql(`
  query StudentBulkImportDataQuery($courseId: ID!) {
    course(id: $courseId) {
      cohorts {
        ...CohortFragment
      }

    }
  }
  `)

let loadData = (courseId, send) => {
  send(SetLoading)
  StudentBulkImportDataQuery.fetch({courseId: courseId})
  |> Js.Promise.then_((response: StudentBulkImportDataQuery.t) => {
    send(SetBaseData(response.course.cohorts->Js.Array2.map(Cohort.makeFromFragment)))
    Js.Promise.resolve()
  })
  |> ignore
}

let tableHeader = {
  <thead>
    <tr className="bg-gray-300">
      <th className="w-12 border border-gray-400 text-xs px-2 py-1 font-semibold" />
      <th className="border border-gray-400 text-xs px-2 py-1 font-semibold">
        {ts("name")->str}
      </th>
      <th className="border border-gray-400 text-xs px-2 py-1 font-semibold">
        {ts("email")->str}
      </th>
      <th className="border border-gray-400 text-xs px-2 py-1 font-semibold">
        {ts("title")->str}
      </th>
      <th className="border border-gray-400 text-xs px-2 py-1 font-semibold">
        {ts("team_name")->str}
      </th>
      <th className="border border-gray-400 text-xs px-2 py-1 font-semibold">
        {ts("tags")->str}
      </th>
      <th className="border border-gray-400 text-xs px-2 py-1 font-semibold">
        {ts("affiliation")->str}
      </th>
    </tr>
  </thead>
}

let tableRows = (csvData, ~startingRow=0, ()) => {
  Js.Array.mapi((studentData, index) =>
    <tr key={string_of_int(index)}>
      <td className="w-12 bg-gray-300 border border-gray-400 truncate text-xs px-2 py-1">
        {string_of_int(startingRow + index + 2)->str}
      </td>
      <td className="border border-gray-400 truncate text-xs px-2 py-1">
        {StudentCSVRow.name(studentData)->Belt.Option.getWithDefault("")->str}
      </td>
      <td className="border border-gray-400 truncate text-xs px-2 py-1">
        {StudentCSVRow.email(studentData)->Belt.Option.getWithDefault("")->str}
      </td>
      <td className="border border-gray-400 truncate text-xs px-2 py-1">
        {StudentCSVRow.title(studentData)->Belt.Option.getWithDefault("")->str}
      </td>
      <td className="border border-gray-400 truncate text-xs px-2 py-1">
        {StudentCSVRow.teamName(studentData)->Belt.Option.getWithDefault("")->str}
      </td>
      <td className="border border-gray-400 truncate text-xs px-2 py-1">
        {StudentCSVRow.tags(studentData)->Belt.Option.getWithDefault("")->str}
      </td>
      <td className="border border-gray-400 truncate text-xs px-2 py-1">
        {StudentCSVRow.affiliation(studentData)->Belt.Option.getWithDefault("")->str}
      </td>
    </tr>
  , csvData)->React.array
}

let truncatedTable = csvData => {
  let firsTwoRows = Js.Array.slice(~start=0, ~end_=2, csvData)
  let lastTwoRows = Js.Array.sliceFrom(Js.Array.length(csvData) - 2, csvData)
  <div>
    <table className="table-fixed mt-2 border w-full overflow-x-scroll">
      {tableHeader}
      <tbody> {tableRows(firsTwoRows, ())} </tbody>
    </table>
    <table className="table-fixed relative w-full overflow-x-scroll">
      <tbody>
        <tr
          className="divide-x divide-dashed divide-gray-400 border-x border-dashed border-gray-400">
          <td className="w-12 px-2 py-3" />
          <td className="px-2 py-3" />
          <td colSpan=3 className="px-2 py-3">
            <div>
              <div className="absolute inset-0 flex items-center" ariaHidden=true>
                <div className="w-full border-t border-b py-1 border-dashed border-gray-400" />
              </div>
              <div className="relative flex justify-center">
                <span className="px-2 bg-white text-xs italic text-center text-gray-700">
                  {("- - - " ++ string_of_int(Array.length(csvData) - 4) ++ " Rows - - -")->str}
                </span>
              </div>
            </div>
          </td>
          <td className="px-2 py-3" />
          <td className="px-2 py-3" />
        </tr>
      </tbody>
    </table>
    <table className="table-fixed border w-full overflow-x-scroll">
      <tbody> {tableRows(lastTwoRows, ~startingRow={Js.Array.length(csvData) - 2}, ())} </tbody>
    </table>
  </div>
}

let csvDataTable = (csvData, fileInvalid) => {
  ReactUtils.nullIf(
    <div className="mt-4">
      <p
        className="flex items-center bg-green-200 text-green-800 font-semibold text-xs p-2 rounded">
        <PfIcon className="if i-check-regular if-fw me-2" />
        <span> {t("valid_data_message")->str} </span>
      </p>
      <p className="font-semibold text-xs mt-4"> {t("valid_data_summary_text")->str} </p>
      {Js.Array.length(csvData) <= 10
        ? <table className="table-fixed mt-2 border w-full overflow-x-scroll">
            {tableHeader}
            <tbody> {tableRows(csvData, ())} </tbody>
          </table>
        : truncatedTable(csvData)}
    </div>,
    fileInvalid->Belt.Option.isSome,
  )
}

let clearFile = (send, inputId) => {
  DomUtils.Element.clearFileInput(~inputId, ~callBack={() => send(ClearCSVData)}, ())
}

let rowClasses = hasError =>
  "border border-gray-400 truncate text-xs px-2 py-1 " ++ (
    hasError ? "bg-red-200 text-red-800" : ""
  )

let errorsTable = (csvData, errors) => {
  <table className="table-fixed mt-4 border w-full overflow-x-scroll">
    {tableHeader}
    <tbody> {Js.Array.mapi((error, index) => {
        let rowNumber = CSVDataError.rowNumber(error)
        let studentData = Js.Array2.unsafe_get(csvData, rowNumber - 2)
        <tr key={string_of_int(index)}>
          <td className={rowClasses(false)}> {rowNumber->string_of_int->str} </td>
          <td className={rowClasses(CSVDataError.hasNameError(error))}>
            {StudentCSVRow.name(studentData)->Belt.Option.getWithDefault("")->str}
          </td>
          <td className={rowClasses(CSVDataError.hasEmailError(error))}>
            {StudentCSVRow.email(studentData)->Belt.Option.getWithDefault("")->str}
          </td>
          <td className={rowClasses(CSVDataError.hasTitleError(error))}>
            {StudentCSVRow.title(studentData)->Belt.Option.getWithDefault("")->str}
          </td>
          <td className={rowClasses(CSVDataError.hasTeamNameError(error))}>
            {StudentCSVRow.teamName(studentData)->Belt.Option.getWithDefault("")->str}
          </td>
          <td className={rowClasses(CSVDataError.hasTagsError(error))}>
            {StudentCSVRow.tags(studentData)->Belt.Option.getWithDefault("")->str}
          </td>
          <td className={rowClasses(CSVDataError.hasAffiliationError(error))}>
            {StudentCSVRow.affiliation(studentData)->Belt.Option.getWithDefault("")->str}
          </td>
        </tr>
      }, errors)->React.array} </tbody>
  </table>
}

let errorMessage = error => {
  let key = switch CSVDataError.errorType(error) {
  | Name => "name"
  | Title => "title"
  | TeamName => "team_name"
  | Email => "email"
  | Affiliation => "affiliation"
  | Tags => "tags"
  }

  CSVDataError.errorVariant(error) == CSVDataError.InvalidCharacters
    ? t(~variables=[("column_name", ts(`${key}`))], "csv_data_errors.invalid_characters")
    : t(`csv_data_errors.invalid_${key}`)
}

let errorTabulation = (csvData, fileInvalid) => {
  switch fileInvalid {
  | None => React.null
  | Some(fileInvalid) =>
    switch fileInvalid {
    | InvalidData(errors) =>
      <div>
        {errors->Js.Array.length > 10
          ? {
              <div>
                {errorsTable(csvData, Js.Array.slice(~start=0, ~end_=10, errors))}
                <div className="text-red-700 text-sm mt-5">
                  {t("more_errors_text")->str}
                  <textArea
                    readOnly=true
                    className="border border-gray-400 bg-gray-100 rounded p-1 mt-1 w-full focus:outline-none focus:ring focus:border-primary-400">
                    {Js.Array.map(
                      error => CSVDataError.rowNumber(error),
                      Js.Array2.sliceFrom(errors, 10),
                    )
                    ->Js.Array2.joinWith(",")
                    ->str}
                  </textArea>
                </div>
              </div>
            }
          : errorsTable(csvData, errors)}
        <div className="text-red-700 text-sm mt-4 rounded-md bg-red-100 p-3">
          <div className="text-sm font-semibold pb-2"> {t("error_summary_title")->str} </div>
          <ul className="list-disc list-inside text-xs">
            {errors
            |> Js.Array.map(error => CSVDataError.errors(error))
            |> ArrayUtils.flattenV2
            |> ArrayUtils.distinct
            |> Js.Array.mapi((error, index) =>
              <li key={string_of_int(index)}> {str(errorMessage(error))} </li>
            )
            |> React.array}
          </ul>
        </div>
      </div>
    | _ => React.null
    }
  }
}

let str = React.string

let pageLinks = courseId => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/students/new`},
    ~title=t("pages.manual"),
    ~icon="fas fa-user",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/students/import`,
    ~title=t("pages.csv_import"),
    ~icon="fas fa-file",
    ~selected=true,
  ),
]

module Selectable = {
  type t = Cohort.t
  let id = t => Cohort.id(t)
  let name = t => Cohort.name(t)
}

module Dropdown = Select.Make(Selectable)

let findSelectedCohort = (cohorts, selectedCohort) => {
  Belt.Option.flatMap(selectedCohort, c =>
    Js.Array2.find(cohorts, u => Cohort.id(c) == Cohort.id(u))
  )
}

@react.component
let make = (~courseId) => {
  let (state, send) = React.useReducer(reducer, initialState)
  React.useEffect1(() => {
    loadData(courseId, send)
    None
  }, [courseId])

  let exitUrl = `/school/courses/${courseId}/students`
  <div>
    <School__PageHeader
      exitUrl
      title={t("page_title")}
      description={t("page_description")}
      links={pageLinks(courseId)}
    />
    <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
      <div className="mt-5 flex flex-col">
        <label className="block text-sm font-medium" htmlFor="email">
          {t("select_a_cohort")->str}
        </label>
        <Dropdown
          placeholder={t("pick_a_cohort")}
          selectables={state.cohorts}
          selected={findSelectedCohort(state.cohorts, state.selectedCohort)}
          onSelect={u => send(SetSelectedCohort(u))}
          loading={state.loading}
        />
      </div>
      <form onSubmit={submitForm(state.selectedCohort, exitUrl, send)}>
        <input name="authenticity_token" type_="hidden" value={AuthenticityToken.fromHead()} />
        <input name="notify_students" type_="hidden" value={string_of_bool(state.notifyStudents)} />
        <div className="mx-auto">
          <div className="py-6 mx-auto">
            <DisablingCover disabled={state.saving} message={ts("processing") ++ "..."}>
              <div className="mt-5">
                <div className="flex justify-between items-center text-center">
                  <div>
                    <label
                      className="tracking-wide text-xs font-semibold"
                      htmlFor="csv-file-input"
                      onClick={_event => clearFile(send, "csv-file-input")}>
                      {t("csv_file_input.label")->str}
                    </label>
                    <HelpIcon className="ms-2" link={t("csv_file_input.help_url")}>
                      {str(t("csv_file_input.help"))}
                    </HelpIcon>
                  </div>
                  <div
                    className="flex items-center text-primary-500 text-xs font-semibold hover:text-primary-700 hover:underline">
                    <PfIcon className="if i-download-regular if-fw me-2" />
                    <a
                      className="focus:outline-none focus:underline focus:text-primary-700 "
                      href={t("example_csv_link.url")}>
                      {t("example_csv_link.text")->str}
                    </a>
                  </div>
                </div>
                <div
                  className="rounded focus-within:outline-none focus-within:ring-2 focus-within:ring-focusColor-500">
                  <input
                    className="absolute w-0 h-0 overflow-hidden"
                    id="csv-file-input"
                    name="csv"
                    type_="file"
                    accept=".csv"
                    onChange={event => onSelectFile(event, send)}
                  />
                  <label
                    onClick={_event => clearFile(send, "csv-file-input")}
                    className="file-input-label mt-2"
                    htmlFor="csv-file-input">
                    <i className="fas fa-upload me-2 text-primary-300 text-lg" />
                    <span className="truncate">
                      {fileInputText(~fileInfo=state.fileInfo)->str}
                    </span>
                  </label>
                </div>
                {ReactUtils.nullIf(
                  csvDataTable(state.csvData, state.fileInvalid),
                  ArrayUtils.isEmpty(state.csvData),
                )}
                <School__InputGroupError
                  message={switch state.fileInvalid {
                  | Some(invalidStatus) =>
                    switch invalidStatus {
                    | ParseError(message) => t(~variables=[("message", message)], "csv_parse_error")
                    | InvalidCSVFile => t("csv_file_errors.invalid")
                    | EmptyFile => t("csv_file_errors.empty")
                    | InvalidTemplate => t("csv_file_errors.invalid_template")
                    | ExceededEntries => t("csv_file_errors.exceeded_entries")
                    | InvalidData(_) => t("csv_file_errors.invalid_data")
                    }
                  | None => ""
                  }}
                  active={state.fileInvalid->Belt.Option.isSome}
                />
                {errorTabulation(state.csvData, state.fileInvalid)}
              </div>
            </DisablingCover>
            {<div className="mt-4">
              <Checkbox
                id="notify-students"
                label={str(t("notify_students_label"))}
                onChange={_event => send(ToggleNotifyStudents)}
                checked={state.notifyStudents}
              />
            </div>}
          </div>
          <div className="flex pb-6 mx-auto">
            <button disabled={saveDisabled(state)} className="w-auto btn btn-primary">
              {t("import_button_text")->str}
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>
}
