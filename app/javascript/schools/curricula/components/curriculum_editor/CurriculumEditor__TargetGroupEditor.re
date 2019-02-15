open CurriculumEditor__Types;

exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let str = ReasonReact.string;

type keyForStateUpdation =
  | Title
  | Description;

type state = {
  title: string,
  description: string,
  milestone: bool,
};

type action =
  | UpdateState(keyForStateUpdation, string)
  | UpdateMilestone(bool);

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetGroupEditor");

let handleResponseJSON = json =>
  switch (
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption
  ) {
  | Some(error) => Notification.error("Something went wrong!", error)
  | None => Notification.success("Success", "Target Created")
  };

let createTargetGroup = (authenticityToken, currentLevel, state) => {
  let payload = Js.Dict.empty();
  let level_id = currentLevel |> Level.id |> string_of_int;

  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(payload, "sort_index", 12 |> string_of_int |> Js.Json.string);
  Js.Dict.set(payload, "name", state.title |> Js.Json.string);
  Js.Dict.set(payload, "description", state.description |> Js.Json.string);
  /* Js.Dict.set(payload, "milestone", state.milestone |> Js.Json.bool; */

  Js.Promise.(
    Fetch.fetchWithInit(
      "/school/levels/" ++ level_id ++ "/target_groups",
      Fetch.RequestInit.make(
        ~method_=Post,
        ~body=
          Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
        ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
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
             Notification.error("Something went wrong!", "Please try again")
           }
         )
         |> resolve
       )
    |> ignore
  );
};

let milestoneButtonClasses = value =>
  value ?
    "w-1/2 bg-grey hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none" :
    "w-1/2 bg-white border-l hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none";

let make = (~currentLevel, ~authenticityToken, ~hideEditorStateCB, _children) => {
  ...component,
  initialState: () => {title: "", description: "", milestone: false},
  reducer: (action, state) =>
    switch (action) {
    | UpdateState(keyForStateUpdation, string) =>
      switch (keyForStateUpdation) {
      | Title => ReasonReact.Update({...state, title: string})
      | Description => ReasonReact.Update({...state, description: string})
      }
    | UpdateMilestone(milestone) => ReasonReact.Update({...state, milestone})
    },
  render: ({state, send}) =>
    <div className="blanket">
      <div className="drawer-right">
        <div className="create-target-form w-full">
          <div className="w-full">
            <div
              className="create-target-form__target-details mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  {"Target Group Details" |> str}
                </h5>
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="title">
                  {"Title*  " |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="title"
                  type_="text"
                  placeholder="Type target group title here"
                  onChange={
                    event =>
                      send(
                        UpdateState(
                          Title,
                          ReactEvent.Form.target(event)##value,
                        ),
                      )
                  }
                />
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="title">
                  {" Description*" |> str}
                </label>
                <textarea
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="title"
                  placeholder="Type target group description"
                  onChange={
                    event =>
                      send(
                        UpdateState(
                          Description,
                          ReactEvent.Form.target(event)##value,
                        ),
                      )
                  }
                  rows=5
                  cols=33
                />
                <div className="flex items-center mb-6">
                  <label
                    className="block tracking-wide text-grey-darker text-xs font-semibold mr-6"
                    htmlFor="title">
                    {"Is this a milestone target?" |> str}
                  </label>
                  <div
                    className="inline-flex w-64 rounded-lg overflow-hidden border">
                    <button
                      onClick={
                        _event => {
                          ReactEvent.Mouse.preventDefault(_event);
                          send(UpdateMilestone(true));
                        }
                      }
                      className={
                        milestoneButtonClasses(state.milestone == true)
                      }>
                      {"Yes" |> str}
                    </button>
                    <button
                      onClick={
                        _event => {
                          ReactEvent.Mouse.preventDefault(_event);
                          send(UpdateMilestone(false));
                        }
                      }
                      className={
                        milestoneButtonClasses(state.milestone == false)
                      }>
                      {"No" |> str}
                    </button>
                  </div>
                </div>
                <div className="flex">
                  <button
                    onClick={_ => hideEditorStateCB()}
                    className="bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                    {"Close" |> str}
                  </button>
                </div>
                <div className="flex">
                  <button
                    onClick={
                      _event =>
                        createTargetGroup(
                          authenticityToken,
                          currentLevel,
                          state,
                        )
                    }
                    className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                    {"Save All" |> str}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>,
};