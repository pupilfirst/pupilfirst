exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let str = ReasonReact.string;

type resourceType =
  | Link
  | File;

type state = {
  id: int,
  resourceType,
  submittable: bool,
  title: string,
  fileName: string,
  saving: bool,
};

type action =
  | UpdateResourceType(resourceType)
  | UpdateSubmittable(bool)
  | UpdateTitle(string)
  | UpdateFileName(string)
  | UpdateSaving
  | GenerateNewId;

let component =
  ReasonReact.reducerComponent("CurriculumEditor__FileUploader");

let resourcesUploadTabClasses = value =>
  value ?
    "mr-1 resources-upload-tab__link resources-upload-tab__link--active" :
    "mr-1 resources-upload-tab__link";
let formClasses = value => value ? "opacity-50" : "";

let resetForm = send => {
  send(GenerateNewId);
  send(UpdateFileName("Choose file to upload"));
};

let updateResourceType = (state, send, resourceType) =>
  state.saving ? () : send(UpdateResourceType(resourceType));

let make = (~authenticityToken, ~addResourceCB, _children) => {
  ...component,
  initialState: () => {
    id: Random.int(99999),
    resourceType: File,
    submittable: false,
    title: "",
    fileName: "Choose file to upload",
    saving: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateResourceType(resourceType) =>
      ReasonReact.Update({...state, resourceType})
    | UpdateSubmittable(submittable) =>
      ReasonReact.Update({...state, submittable})
    | UpdateTitle(title) => ReasonReact.Update({...state, title})
    | GenerateNewId => ReasonReact.Update({...state, id: Random.int(99999)})
    | UpdateFileName(fileName) => ReasonReact.Update({...state, fileName})
    | UpdateSaving => ReasonReact.Update({...state, saving: !state.saving})
    },
  render: ({state, send}) => {
    let formId = "target-resource-form" ++ (state.id |> string_of_int);
    let addResource = json => {
      let id = json |> Json.Decode.(field("id", int));
      addResourceCB(id, state.title);
      send(UpdateSaving);
      resetForm(send);
    };

    let handleResponseJSON = json => {
      let error =
        json
        |> Json.Decode.(field("error", nullable(string)))
        |> Js.Null.toOption;
      switch (error) {
      | Some(err) => Notification.error("Something went wrong!", err)
      | None => addResource(json)
      };
    };

    let sendResource = formData =>
      Js.Promise.(
        Fetch.fetchWithInit(
          "/school/resources/",
          Fetch.RequestInit.make(
            ~method_=Post,
            ~body=Fetch.BodyInit.makeWithFormData(formData),
            ~credentials=Fetch.SameOrigin,
            (),
          ),
        )
        |> then_(response =>
             if (Fetch.Response.ok(response)
                 || Fetch.Response.status(response) == 422) {
               response |> Fetch.Response.json;
             } else {
               Js.Promise.reject(
                 UnexpectedResponse(response |> Fetch.Response.status),
               );
             }
           )
        |> then_(json => handleResponseJSON(json) |> resolve)
        |> catch(error =>
             (
               switch (error |> handleApiError) {
               | Some(code) =>
                 Notification.error(code |> string_of_int, "Please try again")
               | None =>
                 Notification.error(
                   "Something went wrong!",
                   "Please try again",
                 )
               }
             )
             |> resolve
           )
        |> ignore
      );

    let submitForm = event => {
      ReactEvent.Form.preventDefault(event);
      send(UpdateSaving);
      let element = ReactDOMRe._getElementById(formId);
      switch (element) {
      | Some(element) => sendResource(DomUtils.FormData.create(element))
      | None => ()
      };
    };

    <div className={formClasses(state.saving)}>
      <ul className="list-reset resources-upload-tab flex border-b">
        <li className={resourcesUploadTabClasses(state.resourceType == File)}>
          <a
            onClick={
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                updateResourceType(state, send, File);
              }
            }
            className="inline-block text-grey-darker hover:text-indigo-darker p-4 text-xs font-semibold">
            {"Upload File" |> str}
          </a>
        </li>
        <li className={resourcesUploadTabClasses(state.resourceType == Link)}>
          <a
            onClick={
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                updateResourceType(state, send, Link);
              }
            }
            className="inline-block text-grey-darker p-4 hover:text-indigo-darker text-xs font-semibold">
            {"Add URL" |> str}
          </a>
        </li>
      </ul>
      <form
        key={state.id |> string_of_int}
        id=formId
        onSubmit={event => submitForm(event)}>
        <input
          name="authenticity_token"
          type_="hidden"
          value=authenticityToken
        />
        <div
          className="resources-upload-tab__body p-5 border-l border-r border-b rounded rounded-tl-none rounded-tr-none">
          <input
            disabled={state.saving}
            name="resource[title]"
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-4 leading-tight focus:outline-none focus:bg-white focus:border-grey"
            id="resource_title"
            type_="text"
            placeholder="Type resource title here"
            required=true
            onChange={
              event =>
                send(UpdateTitle(ReactEvent.Form.target(event)##value))
            }
          />
          {
            state.resourceType == File ?
              <div
                className="input-file__container flex items-center relative mb-4">
                <input
                  disabled={state.saving}
                  className="input-file__input cursor-pointer px-4"
                  name="resource[file]"
                  type_="file"
                  id="file"
                  required=true
                  multiple=false
                  onChange={
                    event =>
                      send(
                        UpdateFileName(
                          ReactEvent.Form.target(event)##files[0]##name,
                        ),
                      )
                  }
                />
                <label
                  className="input-file__label flex px-4 items-center font-semibold rounded text-sm"
                  htmlFor="file">
                  <i className="material-icons mr-2 text-grey-dark">
                    {"file_upload" |> str}
                  </i>
                  <span className="truncate"> {state.fileName |> str} </span>
                </label>
              </div> :
              <input
                disabled={state.saving}
                className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-4 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                name="resource[link]"
                id="link"
                type_="url"
                required=true
                placeholder="Paste URL here"
              />
          }
          <button
            disabled={state.saving}
            className="bg-indigo-dark hover:bg-grey text-white text-sm font-semibold py-2 px-6 focus:outline-none">
            {(state.saving ? "Uploading" : "Add Resource") |> str}
          </button>
        </div>
      </form>
    </div>;
  },
};