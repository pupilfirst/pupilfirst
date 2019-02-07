open CurriculumEditor__Types;

exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let str = ReasonReact.string;

type resourceId = int;

type evaluationCriteria = (int, string, bool);

type prerequisiteTarget = (int, string, bool);

type methordOfCompletion =
  | WithEvaluationCriteria
  | WithoutEvaluationCriteria
  | NoMethodOfCompletion;

type state = {
  title: string,
  description: string,
  videoEmbed: string,
  slideshowEmbed: string,
  resourceIds: list(resourceId),
  evaluationCriterias: list(evaluationCriteria),
  prerequisiteTargets: list(prerequisiteTarget),
  methordOfCompletion,
  quizId: int,
};

type action =
  | UpdateTitle(string)
  | UpdateDescription(string)
  | UpdateVideoEmbed(string)
  | UpdateSlideshowEmbed(string)
  | UpdateEvaluationCriterion(int, string, bool)
  | UpdatePrerequisiteTargets(int, string, bool)
  | UpdateMethordOfCompletion(methordOfCompletion);

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetEditor");

let handleResponseJSON = json =>
  switch (
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption
  ) {
  | Some(error) => Notification.error("Something went wrong!", error)
  | None => Notification.success("Success", "Target Created")
  };

let createTarget = (state, targetGroupId) => {
  let payload = Js.Dict.empty();
  Js.Dict.set(payload, "role", "founder" |> Js.Json.string);
  Js.Dict.set(payload, "target_action_type", "Todo" |> Js.Json.string);
  Js.Dict.set(payload, "sort_index", 12 |> string_of_int |> Js.Json.string);

  Js.Dict.set(payload, "title", state.title |> Js.Json.string);
  Js.Dict.set(payload, "description", state.description |> Js.Json.string);

  Js.Dict.set(payload, "video_embed", state.videoEmbed |> Js.Json.string);
  Js.Dict.set(
    payload,
    "slideshow_embed",
    state.slideshowEmbed |> Js.Json.string,
  );

  let tg_id = targetGroupId |> string_of_int;
  Js.Promise.(
    Fetch.fetchWithInit(
      "/school/target_groups/" ++ tg_id ++ "/targets",
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

let make = (~targetGroupId, ~evaluationCriteria, ~targets, _children) => {
  ...component,
  initialState: () => {
    title: "",
    description: "",
    videoEmbed: "",
    slideshowEmbed: "",
    resourceIds: [],
    evaluationCriterias:
      evaluationCriteria
      |> List.map(criteria =>
           (
             criteria |> EvaluationCriteria.id,
             criteria |> EvaluationCriteria.name,
             true,
           )
         ),
    prerequisiteTargets:
      targets
      |> List.filter(target => target |> Target.targetGroupId == 1)
      |> List.map(_target =>
           (_target |> Target.id, _target |> Target.title, false)
         ),
    quizId: 0,
    methordOfCompletion: NoMethodOfCompletion,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateTitle(title) => ReasonReact.Update({...state, title})
    | UpdateDescription(description) =>
      ReasonReact.Update({...state, description})
    | UpdateVideoEmbed(videoEmbed) =>
      ReasonReact.Update({...state, videoEmbed})
    | UpdateSlideshowEmbed(slideshowEmbed) =>
      ReasonReact.Update({...state, slideshowEmbed})
    | UpdateEvaluationCriterion(key, value, selected) =>
      let oldEC =
        state.evaluationCriterias
        |> List.filter(((item, value, selected)) => item !== key);
      ReasonReact.Update({
        ...state,
        evaluationCriterias: [(key, value, selected), ...oldEC],
      });
    | UpdatePrerequisiteTargets(key, value, selected) =>
      let oldPT =
        state.prerequisiteTargets
        |> List.filter(((item, value, selected)) => item !== key);
      ReasonReact.Update({
        ...state,
        prerequisiteTargets: [(key, value, selected), ...oldPT],
      });
    | UpdateMethordOfCompletion(methordOfCompletion) =>
      ReasonReact.Update({...state, methordOfCompletion})
    },
  render: ({state, send}) => {
    let multiSelectPTCB = (key, value, selected) =>
      send(UpdatePrerequisiteTargets(key, value, selected));
    let multiSelectECCB = (key, value, selected) =>
      send(UpdateEvaluationCriterion(key, value, selected));
    <div className="blanket">
      <div className="drawer-right">
        <div className="create-target-form w-full">
          <form className="w-full">
            <div
              className="create-target-form__target-details mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  {"Target Details" |> str}
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
                  placeholder="Type target title here"
                  onChange={
                    event =>
                      send(
                        UpdateTitle(ReactEvent.Form.target(event)##value),
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
                  placeholder="Type target description"
                  onChange={
                    event =>
                      send(
                        UpdateDescription(
                          ReactEvent.Form.target(event)##value,
                        ),
                      )
                  }
                  rows=5
                  cols=33
                />
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="title">
                  {"Embed Video" |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="title"
                  type_="text"
                  placeholder="Paste video embed code here"
                  onChange={
                    event =>
                      send(
                        UpdateVideoEmbed(
                          ReactEvent.Form.target(event)##value,
                        ),
                      )
                  }
                />
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="title">
                  {"Embed Slideshow" |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="title"
                  type_="text"
                  placeholder="Paste slideshow embed code here"
                  onChange={
                    event =>
                      send(
                        UpdateSlideshowEmbed(
                          ReactEvent.Form.target(event)##value,
                        ),
                      )
                  }
                />
                <div className="create-target-form__resources">
                  <label
                    className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                    htmlFor="title">
                    {"Resources" |> str}
                  </label>
                  <ul
                    className="list-reset resources-upload-tab flex border-b">
                    <li
                      className="mr-1 resources-upload-tab__link resources-upload-tab__link--active">
                      <div
                        className="inline-block text-grey-darker p-4 text-xs font-semibold">
                        {"Upload File" |> str}
                      </div>
                    </li>
                    <li className="mr-1 resources-upload-tab__link">
                      <div
                        className="inline-block text-grey-darker p-4 text-xs hover:text-blue-darker font-semibold">
                        {"Add URL" |> str}
                      </div>
                    </li>
                  </ul>
                  <div
                    className="resources-upload-tab__body p-5 border-l border-r border-b rounded rounded-tl-none rounded-tr-none">
                    <input
                      type_="file"
                      id="file"
                      className="input-file"
                      multiple=true
                    />
                    <label
                      className="flex items-center text-sm" htmlFor="file">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="20"
                        height="17"
                        fill="#9FB0CC"
                        viewBox="0 0 20 17">
                        <path
                          d="M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z"
                        />
                      </svg>
                      <span className="ml-2">
                        {"Choose a file &hellip;" |> str}
                      </span>
                    </label>
                  </div>
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
                </div>
              </div>
            </div>
            <div className="create-target-form__target-behaviour mx-auto">
              <div className="max-w-md p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  {"Method of Target Completion" |> str}
                </h5>
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="title">
                  {"Any prerequisite targets?" |> str}
                </label>
                <div className="mb-6">
                  <CurriculumEditor__SelectBox
                    items={state.prerequisiteTargets}
                    multiSelectCB=multiSelectPTCB
                  />
                </div>
                <div className="flex items-center mb-6">
                  <label
                    className="block tracking-wide text-grey-darker text-xs font-semibold mr-6"
                    htmlFor="title">
                    {"Is this target reviewed by a faculty?" |> str}
                  </label>
                  <div
                    className="inline-flex w-64 rounded-lg overflow-hidden border">
                    <button
                      onClick={
                        _event => {
                          ReactEvent.Mouse.preventDefault(_event);
                          send(
                            UpdateMethordOfCompletion(WithEvaluationCriteria),
                          );
                        }
                      }
                      className="w-1/2 bg-white hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none">
                      {"Yes" |> str}
                    </button>
                    <button
                      onClick={
                        _event => {
                          ReactEvent.Mouse.preventDefault(_event);
                          send(
                            UpdateMethordOfCompletion(
                              WithoutEvaluationCriteria,
                            ),
                          );
                        }
                      }
                      className="w-1/2 bg-white border-l hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none">
                      {"No" |> str}
                    </button>
                  </div>
                </div>
                {
                  switch (state.methordOfCompletion) {
                  | WithEvaluationCriteria =>
                    <div className="mb-6">
                      <label
                        className="block tracking-wide text-grey-darker text-xs font-semibold mr-6 mb-2"
                        htmlFor="title">
                        {"Choose evaluation criteria from your list" |> str}
                      </label>
                      <CurriculumEditor__SelectBox
                        items={state.evaluationCriterias}
                        multiSelectCB=multiSelectECCB
                      />
                    </div>
                  | WithoutEvaluationCriteria =>
                    <CurriculumEditor__TargetCompletionWithoutEC />
                  | NoMethodOfCompletion => ReasonReact.null
                  }
                }
              </div>
            </div>
            <div className="flex">
              <button
                onClick={_event => createTarget(state, targetGroupId)}
                className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                {"Save All" |> str}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>;
  },
};