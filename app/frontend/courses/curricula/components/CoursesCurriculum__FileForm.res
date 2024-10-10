exception FormNotFound(string)
exception UnexpectedResponse(int)

@val @scope(("window", "pupilfirst"))
external maxUploadFileSize: int = "maxUploadFileSize"

let str = React.string

let tr = I18n.t(~scope="components.CoursesCurriculum__FileForm", ...)

type state = {
  formId: string,
  filename: string,
  errors: list<string>,
}

type action =
  | AttachFile(string)
  | SelectFile(string, list<string>)
  | ResetForm

let defaultTitle = tr("choose_upload")

let reducer = (state, action) =>
  switch action {
  | AttachFile(filename) => {...state, filename, errors: list{}}
  | SelectFile(filename, errors) => {...state, filename, errors}
  | ResetForm => {...state, errors: list{}, filename: defaultTitle}
  }

let handleResponseJSON = (filename, send, attachFileCB, json) => {
  let id = {
    open Json.Decode
    field("id", string)
  }(json)
  attachFileCB(id, filename)
  send(ResetForm)
}

let apiErrorTitle = x =>
  switch x {
  | UnexpectedResponse(code) => tr("error") ++ string_of_int(code)
  | _ => tr("smth_went_wrong")
  }

let uploadFile = (filename, send, attachFileCB, formData) => {
  open Js.Promise

  ignore(
    catch(
      error => {
        let title = PromiseUtils.errorToExn(error)->apiErrorTitle
        Notification.error(title, tr("please_reload"))
        Js.Promise.resolve()
      },
      then_(
        json => resolve(handleResponseJSON(filename, send, attachFileCB, json)),
        then_(
          response =>
            if Fetch.Response.ok(response) {
              Fetch.Response.json(response)
            } else {
              Js.Promise.reject(UnexpectedResponse(Fetch.Response.status(response)))
            },
          Fetch.fetchWithInit(
            "/timeline_event_files/",
            Fetch.RequestInit.make(
              ~method_=Post,
              ~body=Fetch.BodyInit.makeWithFormData(formData),
              ~credentials=Fetch.SameOrigin,
              (),
            ),
          ),
        ),
      ),
    ),
  )
}

let submitForm = (filename, formId, send, addFileAttachmentCB) => {
  let element = Webapi.Dom.Document.getElementById(Webapi.Dom.document, formId)
  switch element {
  | Some(element) =>
    uploadFile(filename, send, addFileAttachmentCB, DomUtils.FormData.create(element))
  | None => raise(FormNotFound(formId))
  }
}

let attachFile = (state, send, attachingCB, attachFileCB, preview, event) =>
  preview
    ? Notification.notice(tr("preview_mode"), tr("cannot_attach"))
    : switch ReactEvent.Form.target(event)["files"] {
      | [] => ()
      | files =>
        let file = files[0]

        let errors = file["size"] > maxUploadFileSize ? list{tr("max_file_size")} : list{}

        if ListUtils.isEmpty(errors) {
          let filename = file["name"]
          attachingCB(true)
          send(AttachFile(filename))
          submitForm(filename, state.formId, send, attachFileCB)
        } else {
          send(SelectFile(file["name"], errors))
        }
      }

@react.component
let make = (~attachFileCB, ~attachingCB, ~preview, ~index) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      formId: string_of_int(Random.int(99999)),
      filename: defaultTitle,
      errors: list{},
    },
  )

  <div>
    <form className="flex items-center flex-wrap" id=state.formId>
      <input name="authenticity_token" type_="hidden" value={AuthenticityToken.fromHead()} />
      <input
        id={"attachment_file_" ++ string_of_int(index)}
        className="hidden"
        name="file"
        required=true
        multiple=false
        type_="file"
        onChange={attachFile(state, send, attachingCB, attachFileCB, preview)}
      />
      <label
        className="text-center cursor-pointer truncate bg-gray-50 border border-dashed border-gray-600 flex px-4 py-5 items-center font-semibold rounded text-sm hover:text-primary-600 hover:bg-primary-100 hover:border-primary-500 grow"
        htmlFor={"attachment_file_" ++ string_of_int(index)}>
        <span className="w-full">
          <i className="fas fa-upload me-2 text-lg" />
          <span className="truncate"> {str(state.filename)} </span>
        </span>
      </label>
    </form>
    {React.array(Array.of_list(List.map(error =>
          <div className="mt-2 text-red-700 text-sm" key=error>
            <i className="fas fa-exclamation-circle me-2" />
            <span> {str(error)} </span>
          </div>
        , state.errors)))}
    {ListUtils.isEmpty(state.errors)
      ? React.null
      : <div className="px-4 mt-2 text-sm"> {str(tr("another_file"))} </div>}
  </div>
}
