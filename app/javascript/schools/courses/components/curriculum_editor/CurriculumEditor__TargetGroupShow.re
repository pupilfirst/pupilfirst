open CurriculumEditor__Types;

let str = ReasonReact.string;

type state = {
  targetTitle: string,
  savingNewTarget: bool,
  validTargetTitle: bool,
};

module CreateTargetMutation = [%graphql
  {|
   mutation($title: String!, $targetGroupId: String!) {
     createTarget(title: $title, targetGroupId: $targetGroupId ) {
       target {
         id
         contentBlockId
         sampleContent
       }
     }
   }
   |}
];

type action =
  | UpdateTargetTitle(string)
  | UpdateTargetSaving;

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetGroupShow");
let archivedClasses = archived =>
  archived ?
    "target-group__header cursor-pointer hover:bg-gray-100 hover:text-primary-500 target-group__header--archived px-6 pb-5 text-center rounded-lg rounded-b-none" :
    "target-group__header cursor-pointer hover:bg-gray-100 hover:text-primary-500 bg-white px-6 pb-5 text-center rounded-lg rounded-b-none";

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
        targetsInTG
        |> List.filter(target => !(target |> Target.visibility === Archived));
    let handleResponseCB = target => {
      let targetId = target##id;
      let targetGroupId = targetGroup |> TargetGroup.id;
      /* let sortIndex = json |> Json.Decode.(field("sortIndex", int)); */
      let newTarget =
        Target.create(
          targetId,
          targetGroupId,
          state.targetTitle,
          [],
          [],
          [],
          None,
          999,
          Draft,
        );
      send(UpdateTargetSaving);
      send(UpdateTargetTitle(""));
      updateTargetCB(newTarget, false);
      showTargetEditorCB(targetGroupId, newTarget);
    };
    let handleCreateTarget = (title, targetGroupId) => {
      send(UpdateTargetSaving);
      CreateTargetMutation.make(~title, ~targetGroupId, ())
      |> GraphqlQuery.sendQuery(authenticityToken)
      |> Js.Promise.then_(response => {
           switch (response##createTarget##target) {
           | Some(target) => handleResponseCB(target)
           | None => ()
           };
           Js.Promise.resolve();
         })
      |> ignore;
    };

    <div className="target-group__box relative mt-12 rounded-lg shadow">
      <div
        id="target_group"
        className={archivedClasses(targetGroup |> TargetGroup.archived)}
        onClick={_event => showTargetGroupEditorCB(Some(targetGroup))}>
        {
          milestone ?
            <div
              className="inline-block px-3 py-2 bg-orange-400 font-bold text-xs rounded-b-lg leading-tight text-white uppercase">
              {"Milestone Targets" |> str}
            </div> :
            ReasonReact.null
        }
        <div className="target-group__title pt-5">
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
               key={target |> Target.id}
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
            className="target-group__target-create relative bg-gray-100 flex items-center border border-dashed border-gray-400 text-gray-700 hover:text-gray-900 active:text-gray-900 focus:text-gray-900 hover:shadow-lg hover:border-gray-500 rounded-lg rounded-t-none overflow-hidden">
            <label
              htmlFor={
                "create-target-input" ++ (targetGroup |> TargetGroup.id)
              }
              className="absolute flex items-center h-full cursor-pointer pl-4">
              <i className="fal fa-plus-circle text-2xl" />
            </label>
            <input
              id={"create-target-input" ++ (targetGroup |> TargetGroup.id)}
              title="Create target"
              value={state.targetTitle}
              onChange={
                event =>
                  send(
                    UpdateTargetTitle(ReactEvent.Form.target(event)##value),
                  )
              }
              placeholder="Create a target"
              className="target-create__input text-xs text-left bg-gray-100 pr-5 pl-12 py-6 rounded-b appearance-none block w-full text-sm text-gray-900 font-semibold leading-tight hover:bg-gray-100 focus:outline-none focus:bg-white focus:border-gray-500"
            />
            {
              state.validTargetTitle ?
                <button
                  onClick={
                    _e =>
                      handleCreateTarget(
                        state.targetTitle,
                        targetGroup |> TargetGroup.id,
                      )
                  }
                  disabled={state.savingNewTarget}
                  className="flex items-center whitespace-no-wrap text-sm font-semibold py-2 px-4 mr-4 rounded btn-primary appearance-none focus:outline-none text-center">
                  {"Create" |> str}
                </button> :
                ReasonReact.null
            }
          </div>
      }
    </div>;
  },
};
