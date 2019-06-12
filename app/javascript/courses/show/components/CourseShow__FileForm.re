[@bs.config {jsx: 3}];

exception FormNotFound(string);
exception UnexpectedResponse(int);

let str = React.string;

type state = {
  formId: string,
  filename: string,
  saving: bool,
  errors: list(string),
};

type action =
  | AttachFile(string)
  | SelectFile(string, list(string))
  | GenerateNewId
  | ClearErrors
  | ResetForm;

let defaultTitle = "Choose file to upload";

let reducer = (state, action) =>
  switch (action) {
  | AttachFile(filename) => {...state, filename, saving: true, errors: []}
  | SelectFile(filename, errors) => {...state, filename, errors}
  | GenerateNewId => {...state, formId: Random.int(99999) |> string_of_int}
  | ClearErrors => {...state, errors: []}
  | ResetForm => {...state, saving: false, errors: [], filename: defaultTitle}
  };

let handleResponseJSON = (filename, send, attachFileCB, json) => {
  let id = json |> Json.Decode.(field("id", string));
  attachFileCB(id, filename);
  send(ResetForm);
};

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let uploadFile = (filename, send, attachFileCB, formData) =>
  Js.Promise.(
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
         if (Fetch.Response.ok(response)) {
           response |> Fetch.Response.json;
         } else {
           Js.Promise.reject(
             UnexpectedResponse(response |> Fetch.Response.status),
           );
         }
       )
    |> then_(json =>
         handleResponseJSON(filename, send, attachFileCB, json) |> resolve
       )
    |> catch(error =>
         (
           switch (error |> handleApiError) {
           | Some(code) =>
             Notification.error(
               "Error " ++ (code |> string_of_int),
               "Please reload the page and try again.",
             )
           | None =>
             Notification.error(
               "Something went wrong!",
               "Our team has been notified of this error. Please reload the page and try again.",
             )
           }
         )
         |> resolve
       )
    |> ignore
  );

let submitForm = (filename, formId, send, addFileAttachmentCB) => {
  let element = ReactDOMRe._getElementById(formId);
  switch (element) {
  | Some(element) =>
    DomUtils.FormData.create(element)
    |> uploadFile(filename, send, addFileAttachmentCB)
  | None => raise(FormNotFound(formId))
  };
};

let attachFile = (state, send, attachingCB, attachFileCB, event) => {
  let file = ReactEvent.Form.target(event)##files[0];
  let maxFileSize = 5 * 1024 * 1024;

  let errors =
    file##size > maxFileSize ? ["The maximum file size is 5 MB."] : [];

  if (errors |> ListUtils.isEmpty) {
    let filename = file##name;
    attachingCB();
    send(AttachFile(filename));
    submitForm(filename, state.formId, send, attachFileCB);
  } else {
    send(SelectFile(file##name, errors));
  };
};

let labelContents = state => {
  let iconClasses =
    (state.saving ? "fal fa-spinner-third fa-spin" : "fas fa-upload")
    ++ " mr-2 text-gray-600 text-lg";
  let labelText =
    state.saving ? "Uploading " ++ state.filename : state.filename;

  <span>
    <FaIcon classes=iconClasses />
    <span className="truncate"> {labelText |> str} </span>
  </span>;
};

[@react.component]
let make = (~authenticityToken, ~attachFileCB, ~attachingCB) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        formId: Random.int(99999) |> string_of_int,
        filename: defaultTitle,
        saving: false,
        errors: [],
      },
    );

  <div>
    <form className="flex items-center flex-wrap" id={state.formId}>
      <input
        name="authenticity_token"
        type_="hidden"
        value=authenticityToken
      />
      <input
        disabled={state.saving}
        id="attachment_file"
        className="hidden"
        name="file"
        required=true
        multiple=false
        type_="file"
        onChange={attachFile(state, send, attachingCB, attachFileCB)}
      />
      <label
        className="mt-2 cursor-pointer truncate h-10 border border-dashed flex px-4 items-center font-semibold rounded text-sm hover:bg-gray-400 flex-grow"
        htmlFor="attachment_file">
        {labelContents(state)}
      </label>
    </form>
    {
      state.errors
      |> List.map(error =>
           <div className="px-4 mt-2 text-red-600 text-sm" key=error>
             <i className="fal fa-exclamation-circle mr-2" />
             <span> {error |> str} </span>
           </div>
         )
      |> Array.of_list
      |> React.array
    }
    {
      state.errors |> ListUtils.isEmpty ?
        React.null :
        <div className="px-4 mt-2 text-sm">
          {"Please choose another file for upload." |> str}
        </div>
    }
  </div>;
};
