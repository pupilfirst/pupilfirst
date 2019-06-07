[@bs.config {jsx: 3}];

exception FormNotFound(string);
exception UnexpectedResponse(int);

let str = React.string;

type state = {
  formId: string,
  title: string,
  saving: bool,
  errors: list(string),
};

type action =
  | UpdateTitle(string)
  | UpdateSaving(bool)
  | GenerateNewId
  | SetErrors(list(string))
  | ClearErrors
  | ResetForm;

let defaultTitle = "Choose file to upload";

let reducer = (state, action) =>
  switch (action) {
  | UpdateTitle(title) => {...state, title}
  | UpdateSaving(saving) => {...state, saving}
  | GenerateNewId => {...state, formId: Random.int(99999) |> string_of_int}
  | SetErrors(errors) => {...state, errors}
  | ClearErrors => {...state, errors: []}
  | ResetForm => {...state, saving: false, errors: [], title: defaultTitle}
  };

let attachButtonContents = saving =>
  if (saving) {
    <span>
      <FaIcon classes="fal fa-spinner-third fa-spin mr-2" />
      {"Uploading..." |> str}
    </span>;
  } else {
    "Attach file" |> str;
  };

let addFileAttachment = (state, send, addFileAttachmentCB, json) => {
  let id = json |> Json.Decode.(field("id", int));
  addFileAttachmentCB(id, state.title);
  send(ResetForm);
};

let handleResponseJSON = (state, send, addFileAttachmentCB, json) => {
  let error =
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption;
  switch (error) {
  | Some(e) => Notification.error("Something went wrong!", e)
  | None => addFileAttachment(state, send, addFileAttachmentCB, json)
  };
};

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let uploadFile = (state, send, addFileAttachmentCB, formData) =>
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
         handleResponseJSON(state, send, addFileAttachmentCB, json) |> resolve
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

let handleSubmit = (state, send, addFileAttachmentCB, event) => {
  event |> ReactEvent.Form.preventDefault;
  send(UpdateSaving(true));
  let element = ReactDOMRe._getElementById(state.formId);
  switch (element) {
  | Some(element) =>
    DomUtils.FormData.create(element)
    |> uploadFile(state, send, addFileAttachmentCB)
  | None => raise(FormNotFound(state.formId))
  };
};

[@react.component]
let make = (~addFileAttachmentCB) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        formId: Random.int(99999) |> string_of_int,
        title: defaultTitle,
        saving: false,
        errors: [],
      },
    );

  <form
    className="flex items-center flex-wrap"
    onSubmit={handleSubmit(state, send, addFileAttachmentCB)}
    id={state.formId}>
    <input
      name="authenticity_token"
      type_="hidden"
      value="n3PCNUXI0JTS/4S9URK4uRc+b6f73Eoo0BSBLN29wVyO+DTlCX1rjxGeaVC3gHv9iSz1TdhDgaloy6Qn2a8UTg=="
    />
    <input
      disabled={state.saving}
      id="attachment_file"
      className="hidden"
      name="file"
      required=true
      multiple=false
      type_="file"
      onChange={
        event =>
          send(UpdateTitle(ReactEvent.Form.target(event)##files[0]##name))
      }
    />
    <label
      className="mt-2 cursor-pointer truncate h-10 border border-dashed flex px-4 items-center font-semibold rounded text-sm hover:bg-gray-400 flex-grow mr-2"
      htmlFor="attachment_file">
      <i className="fas fa-upload mr-2 text-gray-600 text-lg" />
      <span className="truncate"> {state.title |> str} </span>
    </label>
    <button
      disabled={state.saving}
      className="mt-2 bg-indigo-600 hover:bg-gray-500 text-white text-sm font-semibold py-2 px-6 focus:outline-none">
      {attachButtonContents(state.saving)}
    </button>
  </form>;
};