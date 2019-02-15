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
  | UpdateTitle(string);

let component =
  ReasonReact.reducerComponent("CurriculumEditor__FileUploader");

let resourcesUploadTabClasses = value =>
  value ?
    "mr-1 resources-upload-tab__link resources-upload-tab__link--active" :
    "mr-1 resources-upload-tab__link";

let make = (~addResourceCB, _children) => {
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
    },
  render: ({state, send}) => {
    let formId = "target-resource-form" ++ (state.id |> string_of_int);

    let handleResponseJSON = json => {
      let id =
        json |> Json.Decode.(field("id", nullable(int))) |> Js.Null.toOption;
      Js.log(id);
      switch (id) {
      | Some(id) => addResourceCB(id, state.title)
      | None => Notification.success("Success", "Target Created")
      };
      let error =
        json
        |> Json.Decode.(field("error", nullable(string)))
        |> Js.Null.toOption;
      switch (error) {
      | Some(err) => Notification.error("Something went wrong!", err)
      | None => Notification.success("Success", "Target Created")
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

    <div className="create-target-form__resources">
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
      <form id=formId onSubmit={event => submitForm(event)}>
        <div
          className="resources-upload-tab__body p-5 border-l border-r border-b rounded rounded-tl-none rounded-tr-none">
          <input
            name="resource[title]"
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
            id="title"
            type_="text"
            placeholder="Type target title here"
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
                multiple=false
              /> :
              <input
                className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                name="resource[link]"
                id="link"
                type_="link"
                placeholder="Paste file"
              />
          }
          <button
            className="bg-indigo-dark hover:bg-grey text-white text-sm font-semibold py-2 px-6 focus:outline-none">
            {"Add Resource" |> str}
          </button>
        </div>
      </form>
      <div className="flex items-center py-3 cursor-pointer">
        <svg className="svg-icon w-8 h-8" viewBox="0 0 20 20">
          <path
            fill="#A8B7C7"
            d="M13.388,9.624h-3.011v-3.01c0-0.208-0.168-0.377-0.376-0.377S9.624,6.405,9.624,6.613v3.01H6.613c-0.208,0-0.376,0.168-0.376,0.376s0.168,0.376,0.376,0.376h3.011v3.01c0,0.208,0.168,0.378,0.376,0.378s0.376-0.17,0.376-0.378v-3.01h3.011c0.207,0,0.377-0.168,0.377-0.376S13.595,9.624,13.388,9.624z M10,1.344c-4.781,0-8.656,3.875-8.656,8.656c0,4.781,3.875,8.656,8.656,8.656c4.781,0,8.656-3.875,8.656-8.656C18.656,5.219,14.781,1.344,10,1.344z M10,17.903c-4.365,0-7.904-3.538-7.904-7.903S5.635,2.096,10,2.096S17.903,5.635,17.903,10S14.365,17.903,10,17.903z"
          />
        </svg>
        <h5 className="font-semibold ml-2">
          {"Add another resource" |> str}
        </h5>
      </div>
    </div>;
  },
};