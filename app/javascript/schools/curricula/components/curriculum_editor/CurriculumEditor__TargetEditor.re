open CurriculumEditor__Types;

exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let str = ReasonReact.string;

type methodOfCompletion =
  | NotSelected
  | Evaluated
  | VisitLink
  | TakeQuiz
  | MarkAsComplete;

type keyForStateUpdation =
  | Title
  | Description
  | VideoEmbed
  | SlideshowEmbed
  | LinkToComplete;

type evaluationCriterion = (int, string, bool);

type prerequisiteTarget = (int, string, bool);

type resource = (int, string);

type state = {
  title: string,
  description: string,
  videoEmbed: string,
  slideshowEmbed: string,
  evaluationCriteria: list(evaluationCriterion),
  prerequisiteTargets: list(prerequisiteTarget),
  methodOfCompletion,
  quiz: list(QuizQuestion.t),
  resources: list(resource),
  linkToComplete: string,
};

type action =
  | UpdateState(keyForStateUpdation, string)
  | UpdateEvaluationCriterion(int, string, bool)
  | UpdatePrerequisiteTargets(int, string, bool)
  | UpdateMethodOfCompletion(methodOfCompletion)
  | AddQuizQuestion
  | UpdateQuizQuestion(int, QuizQuestion.t)
  | RemoveQuizQuestion(int)
  | AddResource(int, string)
  | RemoveResource(int);

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
  let tg_id = targetGroupId |> string_of_int;
  let resourceIds = state.resources |> List.map(((key, _)) => key);
  let evaluationCriteriaIds =
    state.evaluationCriteria |> List.map(((key, _, _)) => key);
  let prerequisiteTargetIds =
    state.evaluationCriteria |> List.map(((key, _, _)) => key);

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
  Js.Dict.set(
    payload,
    "resource_ids",
    resourceIds |> Json.Encode.(list(int)),
  );
  Js.Dict.set(
    payload,
    "prerequisite_targets",
    prerequisiteTargetIds |> Json.Encode.(list(int)),
  );

  switch (state.methodOfCompletion) {
  | Evaluated =>
    Js.Dict.set(
      payload,
      "evaluation_criteria",
      evaluationCriteriaIds |> Json.Encode.(list(int)),
    )
  | VisitLink =>
    Js.Dict.set(
      payload,
      "link_to_complete",
      state.linkToComplete |> Js.Json.string,
    )
  | TakeQuiz => ()
  | MarkAsComplete => ()
  | NotSelected => ()
  };

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

let completionButtonClasses = value =>
  value ?
    "flex flex-col items-center bg-white border border-grey-light hover:bg-grey-lighter text-green text-sm font-semibold focus:outline-none rounded p-4" :
    "flex flex-col items-center bg-white border border-grey-light hover:bg-grey-lighter text-grey-darkest text-sm font-semibold focus:outline-none rounded p-4";

let make = (~targetGroupId, ~evaluationCriteria, ~targets, _children) => {
  ...component,
  initialState: () => {
    title: "",
    description: "",
    videoEmbed: "",
    slideshowEmbed: "",
    evaluationCriteria:
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
    quiz: [QuizQuestion.empty(0)],
    methodOfCompletion: NotSelected,
    resources: [(1, "a"), (2, "b")],
    linkToComplete: "",
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateState(keyForStateUpdation, string) =>
      switch (keyForStateUpdation) {
      | Title => ReasonReact.Update({...state, title: string})
      | Description => ReasonReact.Update({...state, description: string})
      | VideoEmbed => ReasonReact.Update({...state, videoEmbed: string})
      | SlideshowEmbed =>
        ReasonReact.Update({...state, slideshowEmbed: string})
      | LinkToComplete =>
        ReasonReact.Update({...state, linkToComplete: string})
      }
    | UpdateEvaluationCriterion(key, value, selected) =>
      let oldEC =
        state.evaluationCriteria
        |> List.filter(((item, _, _)) => item !== key);
      ReasonReact.Update({
        ...state,
        evaluationCriteria: [(key, value, selected), ...oldEC],
      });
    | UpdatePrerequisiteTargets(key, value, selected) =>
      let oldPT =
        state.prerequisiteTargets
        |> List.filter(((item, _, _)) => item !== key);
      ReasonReact.Update({
        ...state,
        prerequisiteTargets: [(key, value, selected), ...oldPT],
      });
    | UpdateMethodOfCompletion(methodOfCompletion) =>
      ReasonReact.Update({...state, methodOfCompletion})
    | AddQuizQuestion =>
      let lastQuestionId =
        state.quiz |> List.rev |> List.hd |> QuizQuestion.id;
      ReasonReact.Update({
        ...state,
        quiz:
          state.quiz
          |> List.rev
          |> List.append([QuizQuestion.empty(lastQuestionId + 1)])
          |> List.rev,
      });
    | UpdateQuizQuestion(id, quizQuestion) =>
      let newQuiz =
        state.quiz
        |> List.map(a => a |> QuizQuestion.id == id ? quizQuestion : a);
      ReasonReact.Update({...state, quiz: newQuiz});

    | RemoveQuizQuestion(id) =>
      ReasonReact.Update({
        ...state,
        quiz: state.quiz |> List.filter(a => a |> QuizQuestion.id !== id),
      })
    | AddResource(key, value) =>
      ReasonReact.Update({
        ...state,
        resources: [(key, value), ...state.resources],
      })
    | RemoveResource(key) =>
      let newResources =
        state.resources |> List.filter(((_key, _)) => _key !== key);
      ReasonReact.Update({...state, resources: newResources});
    },
  render: ({state, send}) => {
    let multiSelectPrerequisiteTargetsCB = (key, value, selected) =>
      send(UpdatePrerequisiteTargets(key, value, selected));
    let multiSelectEvaluationCriterionCB = (key, value, selected) =>
      send(UpdateEvaluationCriterion(key, value, selected));
    let removeQuizQuestionCB = id => send(RemoveQuizQuestion(id));
    let updateQuizQuestionCB = (id, quizQuestion) =>
      send(UpdateQuizQuestion(id, quizQuestion));
    let questionCanBeRemoved = state.quiz |> List.length > 1;
    let addResourceCB = (key, value) => send(AddResource(key, value));
    let isValidQuiz =
      state.quiz
      |> List.filter(quizQuestion =>
           quizQuestion |> QuizQuestion.isValidQuizQuestion != true
         )
      |> List.length == 0;

    <div className="blanket">
      <div className="drawer-right">
        <div className="create-target-form w-full">
          <div className="w-full">
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
                  placeholder="Type target description"
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
                        UpdateState(
                          VideoEmbed,
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
                        UpdateState(
                          SlideshowEmbed,
                          ReactEvent.Form.target(event)##value,
                        ),
                      )
                  }
                />
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="title">
                  {"Resources" |> str}
                </label>
                {
                  state.resources
                  |> List.map(((_key, value)) =>
                       <div
                         key={_key |> string_of_int}
                         className="select-list__item-selected flex items-center justify-between bg-grey-lightest text-xs text-grey-dark border rounded p-3 mb-2">
                         {value |> str}
                         <button
                           onClick={
                             _event => {
                               ReactEvent.Mouse.preventDefault(_event);
                               send(RemoveResource(_key));
                             }
                           }>
                           <svg
                             className="w-3"
                             id="fa3b28d3-128c-4841-a4e9-49257a824d7b"
                             xmlns="http://www.w3.org/2000/svg"
                             viewBox="0 0 14 15.99">
                             <path
                               d="M13,1H9A1,1,0,0,0,8,0H6A1,1,0,0,0,5,1H1A1,1,0,0,0,0,2V3H14V2A1,1,0,0,0,13,1ZM11,13a1,1,0,1,1-2,0V7a1,1,0,0,1,2,0ZM8,13a1,1,0,1,1-2,0V7A1,1,0,0,1,8,7ZM5,13a1,1,0,1,1-2,0V7A1,1,0,0,1,5,7Zm8.5-9H.5a.5.5,0,0,0,0,1H1V15a1,1,0,0,0,1,1H12a1,1,0,0,0,1-1V5h.5a.5.5,0,0,0,0-1Z"
                               fill="#525252"
                             />
                           </svg>
                         </button>
                       </div>
                     )
                  |> Array.of_list
                  |> ReasonReact.array
                }
                <CurriculumEditor__ResourceUploader addResourceCB />
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
                    multiSelectCB=multiSelectPrerequisiteTargetsCB
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
                          send(UpdateMethodOfCompletion(Evaluated));
                        }
                      }
                      className="w-1/2 bg-white hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none">
                      {"Yes" |> str}
                    </button>
                    <button
                      onClick={
                        _event => {
                          ReactEvent.Mouse.preventDefault(_event);
                          send(UpdateMethodOfCompletion(MarkAsComplete));
                        }
                      }
                      className="w-1/2 bg-white border-l hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none">
                      {"No" |> str}
                    </button>
                  </div>
                </div>
                {
                  state.methodOfCompletion == Evaluated
                  || state.methodOfCompletion == NotSelected ?
                    ReasonReact.null :
                    <div>
                      <div className="mb-6">
                        <label
                          className="block tracking-wide text-grey-darker text-xs font-semibold mr-6 mb-3"
                          htmlFor="title">
                          {
                            "How do you want the student to complete the target?"
                            |> str
                          }
                        </label>
                        <div className="flex -mx-2">
                          <div className="w-1/3 px-2">
                            <button
                              onClick={
                                _event => {
                                  ReactEvent.Mouse.preventDefault(_event);
                                  send(
                                    UpdateMethodOfCompletion(MarkAsComplete),
                                  );
                                }
                              }
                              className={
                                completionButtonClasses(
                                  state.methodOfCompletion == MarkAsComplete,
                                )
                              }>
                              <svg
                                className="fill-current w-8 mb-2"
                                xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 24 29.4">
                                <g id="bfe57d46-3bb7-42f0-b4e6-eccc9a02f1dd">
                                  <g id="ea523c13-a500-4391-9a0e-cf57c4f4a027">
                                    <path
                                      d="M6.35,5.89a.47.47,0,0,0-.46.46,1,1,0,1,1-1-1,.46.46,0,0,0,0-.92A1.94,1.94,0,1,0,6.81,6.35.46.46,0,0,0,6.35,5.89Z"
                                    />
                                    <path
                                      d="M6.35,11.29a.47.47,0,0,0-.46.46,1,1,0,1,1-1-1,.46.46,0,0,0,.46-.46.47.47,0,0,0-.46-.46,1.94,1.94,0,1,0,1.93,1.93A.46.46,0,0,0,6.35,11.29Z"
                                    />
                                    <path
                                      d="M11.75,12.28H8.32a.45.45,0,0,0-.46.46.46.46,0,0,0,.46.46h3.43a.46.46,0,0,0,.46-.46A.45.45,0,0,0,11.75,12.28Z"
                                    />
                                    <path
                                      d="M11.75,10.31H8.32a.46.46,0,0,0-.46.46.45.45,0,0,0,.46.46h3.43a.45.45,0,0,0,.46-.46A.46.46,0,0,0,11.75,10.31Z"
                                    />
                                    <path
                                      d="M10.77,17.68H8.32a.45.45,0,0,0-.46.46.46.46,0,0,0,.46.46h2.45a.46.46,0,0,0,.46-.46A.45.45,0,0,0,10.77,17.68Z"
                                    />
                                    <path
                                      d="M11.75,15.71H8.32a.46.46,0,0,0-.46.46.45.45,0,0,0,.46.46h3.43a.45.45,0,0,0,.46-.46A.46.46,0,0,0,11.75,15.71Z"
                                    />
                                    <path
                                      d="M16.17,6.87H8.32a.47.47,0,0,0,0,.93h7.85a.47.47,0,0,0,0-.93Z"
                                    />
                                    <path
                                      d="M14.21,4.91H8.32a.46.46,0,0,0-.46.46.45.45,0,0,0,.46.46h5.89a.46.46,0,0,0,.46-.46A.47.47,0,0,0,14.21,4.91Z"
                                    />
                                    <path
                                      d="M6.35,16.7a.46.46,0,0,0-.46.46,1,1,0,1,1-1-1,.46.46,0,0,0,.46-.46.47.47,0,0,0-.46-.46,1.94,1.94,0,1,0,1.93,1.94A.45.45,0,0,0,6.35,16.7Z"
                                    />
                                    <path
                                      d="M18.14,0H1.44A1.45,1.45,0,0,0,0,1.44V22.07a1.45,1.45,0,0,0,1.44,1.44H9.79a.47.47,0,0,0,.46-.46.46.46,0,0,0-.46-.46H1.44a.52.52,0,0,1-.52-.52V1.44A.52.52,0,0,1,1.44.92h16.7a.52.52,0,0,1,.52.52V16.67a.46.46,0,1,0,.92,0V1.44A1.45,1.45,0,0,0,18.14,0Z"
                                    />
                                    <path
                                      d="M22.48,18.67a1.75,1.75,0,0,0-1.19.33,1.67,1.67,0,0,0-2.45-.49,1.67,1.67,0,0,0-1.27-.82,1.7,1.7,0,0,0-.94.17V12a1.68,1.68,0,0,0-1.86-1.68,1.74,1.74,0,0,0-1.51,1.75V18L11.91,19.3A2.91,2.91,0,0,0,11.13,22l1,4.37a3.87,3.87,0,0,0,3.79,3H20.1A3.91,3.91,0,0,0,24,25.5V20.42A1.74,1.74,0,0,0,22.48,18.67Zm.6,6.83a3,3,0,0,1-3,3H16a3,3,0,0,1-2.9-2.29l-1-4.37A2,2,0,0,1,12.56,20l.7-.7v1.59a.46.46,0,0,0,.46.46.47.47,0,0,0,.46-.46V12.07a.81.81,0,0,1,.69-.83.71.71,0,0,1,.59.19.77.77,0,0,1,.25.57v8.1a.46.46,0,0,0,.46.46.45.45,0,0,0,.46-.46v-.73a.77.77,0,0,1,.26-.57.75.75,0,0,1,.59-.2.82.82,0,0,1,.69.84v1.15a.46.46,0,0,0,.92,0v-.73a.76.76,0,0,1,.25-.57.79.79,0,0,1,.6-.2.82.82,0,0,1,.68.84v1.15a.47.47,0,0,0,.93,0v-.73a.77.77,0,0,1,.84-.77.82.82,0,0,1,.69.84V25.5Z"
                                    />
                                  </g>
                                </g>
                              </svg>
                              {"Simply mark the target as completed." |> str}
                            </button>
                          </div>
                          <div className="w-1/3 px-2">
                            <button
                              onClick={
                                _event => {
                                  ReactEvent.Mouse.preventDefault(_event);
                                  send(UpdateMethodOfCompletion(VisitLink));
                                }
                              }
                              className={
                                completionButtonClasses(
                                  state.methodOfCompletion == VisitLink,
                                )
                              }>
                              <svg
                                className="fill-current w-8 mb-2"
                                xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 24 29.4">
                                <g id="bfe57d46-3bb7-42f0-b4e6-eccc9a02f1dd">
                                  <g id="ea523c13-a500-4391-9a0e-cf57c4f4a027">
                                    <path
                                      d="M6.35,5.89a.47.47,0,0,0-.46.46,1,1,0,1,1-1-1,.46.46,0,0,0,0-.92A1.94,1.94,0,1,0,6.81,6.35.46.46,0,0,0,6.35,5.89Z"
                                    />
                                    <path
                                      d="M6.35,11.29a.47.47,0,0,0-.46.46,1,1,0,1,1-1-1,.46.46,0,0,0,.46-.46.47.47,0,0,0-.46-.46,1.94,1.94,0,1,0,1.93,1.93A.46.46,0,0,0,6.35,11.29Z"
                                    />
                                    <path
                                      d="M11.75,12.28H8.32a.45.45,0,0,0-.46.46.46.46,0,0,0,.46.46h3.43a.46.46,0,0,0,.46-.46A.45.45,0,0,0,11.75,12.28Z"
                                    />
                                    <path
                                      d="M11.75,10.31H8.32a.46.46,0,0,0-.46.46.45.45,0,0,0,.46.46h3.43a.45.45,0,0,0,.46-.46A.46.46,0,0,0,11.75,10.31Z"
                                    />
                                    <path
                                      d="M10.77,17.68H8.32a.45.45,0,0,0-.46.46.46.46,0,0,0,.46.46h2.45a.46.46,0,0,0,.46-.46A.45.45,0,0,0,10.77,17.68Z"
                                    />
                                    <path
                                      d="M11.75,15.71H8.32a.46.46,0,0,0-.46.46.45.45,0,0,0,.46.46h3.43a.45.45,0,0,0,.46-.46A.46.46,0,0,0,11.75,15.71Z"
                                    />
                                    <path
                                      d="M16.17,6.87H8.32a.47.47,0,0,0,0,.93h7.85a.47.47,0,0,0,0-.93Z"
                                    />
                                    <path
                                      d="M14.21,4.91H8.32a.46.46,0,0,0-.46.46.45.45,0,0,0,.46.46h5.89a.46.46,0,0,0,.46-.46A.47.47,0,0,0,14.21,4.91Z"
                                    />
                                    <path
                                      d="M6.35,16.7a.46.46,0,0,0-.46.46,1,1,0,1,1-1-1,.46.46,0,0,0,.46-.46.47.47,0,0,0-.46-.46,1.94,1.94,0,1,0,1.93,1.94A.45.45,0,0,0,6.35,16.7Z"
                                    />
                                    <path
                                      d="M18.14,0H1.44A1.45,1.45,0,0,0,0,1.44V22.07a1.45,1.45,0,0,0,1.44,1.44H9.79a.47.47,0,0,0,.46-.46.46.46,0,0,0-.46-.46H1.44a.52.52,0,0,1-.52-.52V1.44A.52.52,0,0,1,1.44.92h16.7a.52.52,0,0,1,.52.52V16.67a.46.46,0,1,0,.92,0V1.44A1.45,1.45,0,0,0,18.14,0Z"
                                    />
                                    <path
                                      d="M22.48,18.67a1.75,1.75,0,0,0-1.19.33,1.67,1.67,0,0,0-2.45-.49,1.67,1.67,0,0,0-1.27-.82,1.7,1.7,0,0,0-.94.17V12a1.68,1.68,0,0,0-1.86-1.68,1.74,1.74,0,0,0-1.51,1.75V18L11.91,19.3A2.91,2.91,0,0,0,11.13,22l1,4.37a3.87,3.87,0,0,0,3.79,3H20.1A3.91,3.91,0,0,0,24,25.5V20.42A1.74,1.74,0,0,0,22.48,18.67Zm.6,6.83a3,3,0,0,1-3,3H16a3,3,0,0,1-2.9-2.29l-1-4.37A2,2,0,0,1,12.56,20l.7-.7v1.59a.46.46,0,0,0,.46.46.47.47,0,0,0,.46-.46V12.07a.81.81,0,0,1,.69-.83.71.71,0,0,1,.59.19.77.77,0,0,1,.25.57v8.1a.46.46,0,0,0,.46.46.45.45,0,0,0,.46-.46v-.73a.77.77,0,0,1,.26-.57.75.75,0,0,1,.59-.2.82.82,0,0,1,.69.84v1.15a.46.46,0,0,0,.92,0v-.73a.76.76,0,0,1,.25-.57.79.79,0,0,1,.6-.2.82.82,0,0,1,.68.84v1.15a.47.47,0,0,0,.93,0v-.73a.77.77,0,0,1,.84-.77.82.82,0,0,1,.69.84V25.5Z"
                                    />
                                  </g>
                                </g>
                              </svg>
                              {"Visit a link to complete the target." |> str}
                            </button>
                          </div>
                          <div className="w-1/3 px-2">
                            <button
                              onClick={
                                _event => {
                                  ReactEvent.Mouse.preventDefault(_event);
                                  send(UpdateMethodOfCompletion(TakeQuiz));
                                }
                              }
                              className={
                                completionButtonClasses(
                                  state.methodOfCompletion == TakeQuiz,
                                )
                              }>
                              <svg
                                className="fill-current w-8 mb-2"
                                xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 24 29.4">
                                <g id="bfe57d46-3bb7-42f0-b4e6-eccc9a02f1dd">
                                  <g id="ea523c13-a500-4391-9a0e-cf57c4f4a027">
                                    <path
                                      d="M6.35,5.89a.47.47,0,0,0-.46.46,1,1,0,1,1-1-1,.46.46,0,0,0,0-.92A1.94,1.94,0,1,0,6.81,6.35.46.46,0,0,0,6.35,5.89Z"
                                    />
                                    <path
                                      d="M6.35,11.29a.47.47,0,0,0-.46.46,1,1,0,1,1-1-1,.46.46,0,0,0,.46-.46.47.47,0,0,0-.46-.46,1.94,1.94,0,1,0,1.93,1.93A.46.46,0,0,0,6.35,11.29Z"
                                    />
                                    <path
                                      d="M11.75,12.28H8.32a.45.45,0,0,0-.46.46.46.46,0,0,0,.46.46h3.43a.46.46,0,0,0,.46-.46A.45.45,0,0,0,11.75,12.28Z"
                                    />
                                    <path
                                      d="M11.75,10.31H8.32a.46.46,0,0,0-.46.46.45.45,0,0,0,.46.46h3.43a.45.45,0,0,0,.46-.46A.46.46,0,0,0,11.75,10.31Z"
                                    />
                                    <path
                                      d="M10.77,17.68H8.32a.45.45,0,0,0-.46.46.46.46,0,0,0,.46.46h2.45a.46.46,0,0,0,.46-.46A.45.45,0,0,0,10.77,17.68Z"
                                    />
                                    <path
                                      d="M11.75,15.71H8.32a.46.46,0,0,0-.46.46.45.45,0,0,0,.46.46h3.43a.45.45,0,0,0,.46-.46A.46.46,0,0,0,11.75,15.71Z"
                                    />
                                    <path
                                      d="M16.17,6.87H8.32a.47.47,0,0,0,0,.93h7.85a.47.47,0,0,0,0-.93Z"
                                    />
                                    <path
                                      d="M14.21,4.91H8.32a.46.46,0,0,0-.46.46.45.45,0,0,0,.46.46h5.89a.46.46,0,0,0,.46-.46A.47.47,0,0,0,14.21,4.91Z"
                                    />
                                    <path
                                      d="M6.35,16.7a.46.46,0,0,0-.46.46,1,1,0,1,1-1-1,.46.46,0,0,0,.46-.46.47.47,0,0,0-.46-.46,1.94,1.94,0,1,0,1.93,1.94A.45.45,0,0,0,6.35,16.7Z"
                                    />
                                    <path
                                      d="M18.14,0H1.44A1.45,1.45,0,0,0,0,1.44V22.07a1.45,1.45,0,0,0,1.44,1.44H9.79a.47.47,0,0,0,.46-.46.46.46,0,0,0-.46-.46H1.44a.52.52,0,0,1-.52-.52V1.44A.52.52,0,0,1,1.44.92h16.7a.52.52,0,0,1,.52.52V16.67a.46.46,0,1,0,.92,0V1.44A1.45,1.45,0,0,0,18.14,0Z"
                                    />
                                    <path
                                      d="M22.48,18.67a1.75,1.75,0,0,0-1.19.33,1.67,1.67,0,0,0-2.45-.49,1.67,1.67,0,0,0-1.27-.82,1.7,1.7,0,0,0-.94.17V12a1.68,1.68,0,0,0-1.86-1.68,1.74,1.74,0,0,0-1.51,1.75V18L11.91,19.3A2.91,2.91,0,0,0,11.13,22l1,4.37a3.87,3.87,0,0,0,3.79,3H20.1A3.91,3.91,0,0,0,24,25.5V20.42A1.74,1.74,0,0,0,22.48,18.67Zm.6,6.83a3,3,0,0,1-3,3H16a3,3,0,0,1-2.9-2.29l-1-4.37A2,2,0,0,1,12.56,20l.7-.7v1.59a.46.46,0,0,0,.46.46.47.47,0,0,0,.46-.46V12.07a.81.81,0,0,1,.69-.83.71.71,0,0,1,.59.19.77.77,0,0,1,.25.57v8.1a.46.46,0,0,0,.46.46.45.45,0,0,0,.46-.46v-.73a.77.77,0,0,1,.26-.57.75.75,0,0,1,.59-.2.82.82,0,0,1,.69.84v1.15a.46.46,0,0,0,.92,0v-.73a.76.76,0,0,1,.25-.57.79.79,0,0,1,.6-.2.82.82,0,0,1,.68.84v1.15a.47.47,0,0,0,.93,0v-.73a.77.77,0,0,1,.84-.77.82.82,0,0,1,.69.84V25.5Z"
                                    />
                                  </g>
                                </g>
                              </svg>
                              {"Take a quiz to complete the target." |> str}
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                }
                {
                  switch (state.methodOfCompletion) {
                  | Evaluated =>
                    <div className="mb-6">
                      <label
                        className="block tracking-wide text-grey-darker text-xs font-semibold mr-6 mb-2"
                        htmlFor="title">
                        {"Choose evaluation criteria from your list" |> str}
                      </label>
                      <CurriculumEditor__SelectBox
                        items={state.evaluationCriteria}
                        multiSelectCB=multiSelectEvaluationCriterionCB
                      />
                    </div>
                  | MarkAsComplete => ReasonReact.null
                  | TakeQuiz =>
                    <div>
                      <label
                        className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                        htmlFor="Quiz question 1">
                        {"Prepare the quiz now." |> str}
                      </label>
                      {
                        state.quiz
                        |> List.map(quizQuestion =>
                             <CurriculumEditor__TargetQuizQuestion
                               key={
                                 quizQuestion
                                 |> QuizQuestion.id
                                 |> string_of_int
                               }
                               quizQuestion
                               updateQuizQuestionCB
                               removeQuizQuestionCB
                               questionCanBeRemoved
                             />
                           )
                        |> Array.of_list
                        |> ReasonReact.array
                      }
                      <div
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            send(AddQuizQuestion);
                          }
                        )
                        className="flex items-center py-3 cursor-pointer">
                        <svg className="svg-icon w-8 h-8" viewBox="0 0 20 20">
                          <path
                            fill="#A8B7C7"
                            d="M13.388,9.624h-3.011v-3.01c0-0.208-0.168-0.377-0.376-0.377S9.624,6.405,9.624,6.613v3.01H6.613c-0.208,0-0.376,0.168-0.376,0.376s0.168,0.376,0.376,0.376h3.011v3.01c0,0.208,0.168,0.378,0.376,0.378s0.376-0.17,0.376-0.378v-3.01h3.011c0.207,0,0.377-0.168,0.377-0.376S13.595,9.624,13.388,9.624z M10,1.344c-4.781,0-8.656,3.875-8.656,8.656c0,4.781,3.875,8.656,8.656,8.656c4.781,0,8.656-3.875,8.656-8.656C18.656,5.219,14.781,1.344,10,1.344z M10,17.903c-4.365,0-7.904-3.538-7.904-7.903S5.635,2.096,10,2.096S17.903,5.635,17.903,10S14.365,17.903,10,17.903z"
                          />
                        </svg>
                        <h5 className="font-semibold ml-2">
                          {"Add another Question" |> str}
                        </h5>
                      </div>
                    </div>
                  | VisitLink =>
                    <div>
                      <label
                        className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                        htmlFor="title">
                        {"Link to complete*  " |> str}
                      </label>
                      <input
                        className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                        id="title"
                        type_="text"
                        placeholder="Paste link to complete"
                        onChange=(
                          event =>
                            send(
                              UpdateState(
                                LinkToComplete,
                                ReactEvent.Form.target(event)##value,
                              ),
                            )
                        )
                      />
                    </div>
                  | NotSelected => ReasonReact.null
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
          </div>
        </div>
      </div>
    </div>;
  },
};