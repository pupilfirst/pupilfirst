open CurriculumEditor__Types;
open SchoolAdmin__Utils;

let str = ReasonReact.string;

type state = {
  targetTitle: string,
  savingNewTarget: bool,
  validTargetTitle: bool,
};

type action =
  | UpdateTargetTitle(string)
  | UpdateTargetSaving;

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetGroupShow");
let archivedClasses = archived =>
  archived ?
    "target-group__header hover:bg-gray-200 target-group__header--archived p-6 border border-b-0 text-center rounded-lg rounded-b-none" :
    "target-group__header hover:bg-gray-200 bg-white p-6 border border-b-0 text-center rounded-lg rounded-b-none";

let make =
    (
      ~targetGroup,
      ~targets,
      ~showTargetGroupEditorCB,
      ~showTargetEditorCB,
      ~updateTargetCB,
      ~showArchived,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  initialState: () => {
    targetTitle: "",
    savingNewTarget: false,
    validTargetTitle: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateTargetTitle(targetTitle) =>
      ReasonReact.Update({
        ...state,
        targetTitle,
        validTargetTitle: targetTitle |> String.length > 1,
      })
    | UpdateTargetSaving =>
      ReasonReact.Update({...state, savingNewTarget: !state.savingNewTarget})
    },
  render: ({state, send}) => {
    let milestone = targetGroup |> TargetGroup.milestone;
    let targetGroupArchived = targetGroup |> TargetGroup.archived;
    let targetsInTG =
      targets
      |> List.filter(target =>
           target |> Target.targetGroupId == (targetGroup |> TargetGroup.id)
         )
      |> Target.sort;

    let targetsToDisplay =
      showArchived ?
        targetsInTG :
        targetsInTG |> List.filter(target => !(target |> Target.archived));
    let handleResponseCB = json => {
      let id = json |> Json.Decode.(field("id", int));
      let targetGroupId = targetGroup |> TargetGroup.id;
      let sortIndex = json |> Json.Decode.(field("sortIndex", int));
      let newTarget =
        Target.create(
          id,
          targetGroupId,
          state.targetTitle,
          "",
          Some("youtubeId"),
          [],
          [],
          [QuizQuestion.empty(0)],
          [],
          None,
          "founder",
          "Todo",
          sortIndex,
          true,
        );
      send(UpdateTargetSaving);
      send(UpdateTargetTitle(""));
      updateTargetCB(newTarget);
      showTargetEditorCB(targetGroupId, Some(newTarget));
    };
    let handleErrorCB = () => send(UpdateTargetSaving);
    let handleCreateTarget = () => {
      send(UpdateTargetSaving);
      let payload = Js.Dict.empty();
      let targetData = Js.Dict.empty();
      Js.Dict.set(targetData, "title", state.targetTitle |> Js.Json.string);
      Js.Dict.set(targetData, "role", "founder" |> Js.Json.string);
      Js.Dict.set(targetData, "target_action_type", "Todo" |> Js.Json.string);

      Js.Dict.set(
        payload,
        "authenticity_token",
        authenticityToken |> Js.Json.string,
      );
      Js.Dict.set(payload, "target", targetData |> Js.Json.object_);
      let tgId = targetGroup |> TargetGroup.id |> string_of_int;
      let url = "/school/target_groups/" ++ tgId ++ "/targets";
      Api.create(url, payload, handleResponseCB, handleErrorCB);
    };

    <div className="target-group__box relative mt-12 rounded-lg">
      <div
        id="target_group"
        className={archivedClasses(targetGroup |> TargetGroup.archived)}
        onClick={_event => showTargetGroupEditorCB(Some(targetGroup))}>
        {milestone ? <div> {"Milestone" |> str} </div> : ReasonReact.null}
        <div className="target-group__title">
          <h4> {targetGroup |> TargetGroup.name |> str} </h4>
        </div>
        <div className="target-group__description pt-1">
          <p>
            {
              (
                switch (targetGroup |> TargetGroup.description) {
                | Some(description) => description
                | None => ""
                }
              )
              |> str
            }
          </p>
        </div>
      </div>
      {
        targetsToDisplay
        |> List.map(target =>
             <CurriculumEditor__TargetShow
               key={target |> Target.id |> string_of_int}
               target
               targetGroup
               showTargetEditorCB
             />
           )
        |> Array.of_list
        |> ReasonReact.array
      }
      {
        targetGroupArchived ?
          ReasonReact.null :
          <div
            className="target-group__target-create flex items-center bg-gray-200 border-2 border-dashed p-5 rounded-lg rounded-t-none cursor-pointer">
            <i className="fal fa-plus-circle text-lg" />
            <input
              title="Create target "
              value={state.targetTitle}
              onChange={
                event =>
                  send(
                    UpdateTargetTitle(ReactEvent.Form.target(event)##value),
                  )
              }
              placeholder="Create a target"
              className="community-qa-comment__input text-xs text-left bg-gray-200 py-3 px-4 rounded-b appearance-none block w-full leading-tight hover:bg-gray-100 focus:outline-none focus:bg-white focus:border-gray"
            />
            {
              state.validTargetTitle ?
                <button
                  onClick={_e => handleCreateTarget()}
                  disabled={state.savingNewTarget}
                  className="flex items-center whitespace-no-wrap text-sm font-semibold py-2 px-4 btn-primary appearance-none focus:outline-none text-center">
                  {"Create" |> str}
                </button> :
                ReasonReact.null
            }
          </div>
      }
    </div>;
  },
};