open CurriculumEditor__Types;

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
};

type action =
  | UpdateResourceType(resourceType)
  | UpdateSubmittable(bool)
  | UpdateTitle(string)
  | GenerateNewId;

let component =
  ReasonReact.reducerComponent("CurriculumEditor__FileUploader");

let resourcesUploadTabClasses = value =>
  value ?
    "mr-1 resources-upload-tab__link resources-upload-tab__link--active" :
    "mr-1 resources-upload-tab__link";

let make = (~authenticityToken, ~addResourceCB, _children) => {
  ...component,
  initialState: () => {
    id: Random.int(99999),
    resourceType: File,
    submittable: false,
    title: "",
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateResourceType(resourceType) =>
      ReasonReact.Update({...state, resourceType})
    | UpdateSubmittable(submittable) =>
      ReasonReact.Update({...state, submittable})
    | UpdateTitle(title) => ReasonReact.Update({...state, title})
    | GenerateNewId => ReasonReact.Update({...state, id: Random.int(99999)})
    },
  render: ({state, send}) => {
    let formId = "target-resource-form" ++ (state.id |> string_of_int);
    let addResource = json => {
      let id = json |> Json.Decode.(field("id", int));
      addResourceCB(id, state.title);
      send(GenerateNewId);
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
      let element = ReactDOMRe._getElementById(formId);
      switch (element) {
      | Some(element) => sendResource(FormData.create(element))
      | None => ()
      };
    };

    <div>
      <ul className="list-reset resources-upload-tab flex border-b">
        <li className={resourcesUploadTabClasses(state.resourceType == File)}>
          <div
            onClick={
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                send(UpdateResourceType(File));
              }
            }
            className="inline-block text-grey-darker p-4 text-xs font-semibold">
            {"Upload File" |> str}
          </div>
        </li>
        <li className={resourcesUploadTabClasses(state.resourceType == Link)}>
          <div
            onClick={
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                send(UpdateResourceType(Link));
              }
            }
            className="inline-block text-grey-darker p-4 text-xs hover:text-blue-darker font-semibold">
            {"Add URL" |> str}
          </div>
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
            name="resource[title]"
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
            id="title"
            type_="text"
            placeholder="Type target title here"
            required=true
            onChange={
              event =>
                send(UpdateTitle(ReactEvent.Form.target(event)##value))
            }
          />
          {
            state.resourceType == File ?
              <input
                name="resource[file]"
                type_="file"
                id="file"
                required=true
                multiple=false
              /> :
              <input
                className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                name="resource[link]"
                id="link"
                type_="url"
                required=true
                placeholder="Paste file"
              />
          }
          <button
            className="bg-indigo-dark hover:bg-grey text-white text-sm font-semibold py-2 px-6 focus:outline-none">
            {"Add Resource" |> str}
          </button>
        </div>
      </form>
    </div>;
  },
};