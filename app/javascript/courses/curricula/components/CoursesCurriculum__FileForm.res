exception FormNotFound(string)
exception UnexpectedResponse(int)

let str = React.string

type state = {
  formId: string,
  filename: string,
  errors: list<string>,
}

type action =
  | AttachFile(string)
  | SelectFile(string, list<string>)
  | ResetForm

let defaultTitle = "Choose file to upload"

let reducer = (state, action) =>
  switch action {
  | AttachFile(filename) => {...state, filename: filename, errors: list{}}
  | SelectFile(filename, errors) => {...state, filename: filename, errors: errors}
  | ResetForm => {...state, errors: list{}, filename: defaultTitle}
  }

let handleResponseJSON = (filename, send, attachFileCB, json) => {
  let id = json |> {
    open Json.Decode
    field("id", string)
  }
  attachFileCB(id, filename)
  send(ResetForm)
}

let apiErrorTitle = x =>
  switch x {
  | UnexpectedResponse(code) => "Error " ++ (code |> string_of_int)
  | _ => "Something went wrong!"
  }

let uploadFile = (filename, send, attachFileCB, formData) => {
  open Js.Promise
  Fetch.fetchWithInit(
    "/timeline_event_files/",
    Fetch.RequestInit.make(
      ~method_=Post,
      ~body=Fetch.BodyInit.makeWithFormData(formData),
      ~credentials=Fetch.SameOrigin,
      (),
    ),
  )
  |> then_(response =>
    if Fetch.Response.ok(response) {
      response |> Fetch.Response.json
    } else {
      Js.Promise.reject(UnexpectedResponse(response |> Fetch.Response.status))
    }
  )
  |> then_(json => handleResponseJSON(filename, send, attachFileCB, json) |> resolve)
  |> catch(error => {
    let title = PromiseUtils.errorToExn(error)->apiErrorTitle
    Notification.error(title, "Please reload the page and try again.")
    Js.Promise.resolve()
  })
  |> ignore
}

let submitForm = (filename, formId, send, addFileAttachmentCB) => {
  let element = Webapi.Dom.Document.getElementById(formId, Webapi.Dom.document)
  switch element {
  | Some(element) =>
    DomUtils.FormData.create(element) |> uploadFile(filename, send, addFileAttachmentCB)
  | None => raise(FormNotFound(formId))
  }
}

let attachFile = (state, send, attachingCB, attachFileCB, preview, event) =>
  preview
    ? Notification.notice("Preview Mode", "You cannot attach files.")
    : switch ReactEvent.Form.target(event)["files"] {
      | [] => ()
      | files =>
        let file = files[0]
        let maxFileSize = 5 * 1024 * 1024

        let errors = file["size"] > maxFileSize ? list{"The maximum file size is 5 MB."} : list{}

        if errors |> ListUtils.isEmpty {
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
      formId: Random.int(99999) |> string_of_int,
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
        className="text-center cursor-pointer truncate bg-gray-50 border border-dashed border-gray-600 flex px-4 py-5 items-center font-semibold rounded text-sm hover:text-primary-600 hover:bg-primary-100 hover:border-primary-500 flex-grow"
        htmlFor={"attachment_file_" ++ string_of_int(index)}>
        <span className="w-full">
          <i className="fas fa-upload mr-2 text-lg" />
          <span className="truncate"> {state.filename |> str} </span>
        </span>
      </label>
    </form>
    {state.errors
    |> List.map(error =>
      <div className="mt-2 text-red-700 text-sm" key=error>
        <i className="fas fa-exclamation-circle mr-2" /> <span> {error |> str} </span>
      </div>
    )
    |> Array.of_list
    |> React.array}
    {state.errors |> ListUtils.isEmpty
      ? React.null
      : <div className="px-4 mt-2 text-sm">
          {"Please choose another file for upload." |> str}
        </div>}
  </div>
}
