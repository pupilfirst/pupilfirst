open CurriculumEditor__Types;

type props = {
  course: Course.t,
  evaluationCriteria: list(EvaluationCriteria.t),
  levels: list(Level.t),
  targetGroups: list(TargetGroup.t),
  targets: list(Target.t),
  authenticityToken: string,
};

type editorAction =
  | Hidden
  | ShowTargetEditor(int, option(Target.t))
  | ShowTargetGroupEditor(option(TargetGroup.t))
  | ShowLevelEditor(option(Level.t));

type state = {
  selectedLevel: Level.t,
  editorAction,
  levels: list(Level.t),
  targetGroups: list(TargetGroup.t),
  targets: list(Target.t),
  showArchived: bool,
};

type action =
  | SelectLevel(Level.t)
  | UpdateEditorAction(editorAction)
  | UpdateLevels(Level.t)
  | UpdateTargetGroups(TargetGroup.t)
  | UpdateTarget(Target.t)
  | UpdateTargets(list(Target.t))
  | ToggleShowArchived;

let str = ReasonReact.string;

let component = ReasonReact.reducerComponent("CurriculumEditor");

let showArchivedButton = (targetGroupsInLevel, targets) => {
  let tgIds = targetGroupsInLevel |> List.map(tg => tg |> TargetGroup.id);

  let numberOfArchivedTargetGroupsInLevel =
    targetGroupsInLevel
    |> List.filter(tg => tg |> TargetGroup.archived)
    |> List.length;
  let numberOfArchivedTargetsInLevel =
    targets
    |> List.filter(target =>
         tgIds |> List.mem(target |> Target.targetGroupId)
       )
    |> List.filter(target => target |> Target.archived)
    |> List.length;

  numberOfArchivedTargetGroupsInLevel > 0 || numberOfArchivedTargetsInLevel > 0;
};

let make =
    (
      ~course,
      ~evaluationCriteria,
      ~levels,
      ~targetGroups,
      ~targets,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  initialState: () => {
    selectedLevel: levels |> List.rev |> List.hd,
    editorAction: Hidden,
    targetGroups,
    levels,
    targets,
    showArchived: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | SelectLevel(selectedLevel) =>
      ReasonReact.Update({...state, selectedLevel})
    | UpdateEditorAction(editorAction) =>
      ReasonReact.Update({...state, editorAction})
    | UpdateLevels(level) =>
      let newLevels = level |> Level.updateList(state.levels);
      ReasonReact.Update({
        ...state,
        levels: newLevels,
        editorAction: Hidden,
        selectedLevel: level,
      });
    | UpdateTargetGroups(targetGroup) =>
      let newtargetGroups =
        targetGroup |> TargetGroup.updateList(state.targetGroups);
      ReasonReact.Update({
        ...state,
        targetGroups: newtargetGroups,
        editorAction: Hidden,
      });
    | UpdateTarget(target) =>
      let newtargets = target |> Target.updateList(state.targets);
      ReasonReact.Update({
        ...state,
        targets: newtargets,
        editorAction: Hidden,
      });
    | ToggleShowArchived =>
      ReasonReact.Update({...state, showArchived: !state.showArchived})
    | UpdateTargets(targets) => ReasonReact.Update({...state, targets})
    },
  render: ({state, send}) => {
    let hideEditorActionCB = () => send(UpdateEditorAction(Hidden));
    let currentLevel = state.selectedLevel;
    let currentLevelId = Level.id(currentLevel);
    let updateLevelsCB = level => send(UpdateLevels(level));
    let targetGroupsInLevel =
      state.targetGroups
      |> List.filter(targetGroup =>
           targetGroup |> TargetGroup.levelId == currentLevelId
         )
      |> TargetGroup.sort;
    let targetGroupsToDisplay =
      state.showArchived ?
        targetGroupsInLevel :
        targetGroupsInLevel |> List.filter(tg => !(tg |> TargetGroup.archived));
    let targetGroupIdsInLevel =
      targetGroupsInLevel
      |> List.filter(tg => !(tg |> TargetGroup.archived))
      |> List.map(tg => tg |> TargetGroup.id);
    let showTargetEditorCB = (targetGroupId, target) =>
      send(UpdateEditorAction(ShowTargetEditor(targetGroupId, target)));
    let showTargetGroupEditorCB = targetGroup =>
      send(UpdateEditorAction(ShowTargetGroupEditor(targetGroup)));

    let updateTargetCB = target => {
      let targetGroup =
        state.targetGroups |> TargetGroup.find(target |> Target.targetGroupId);

      let newTargetGroup =
        target |> Target.archived ?
          targetGroup : targetGroup |> TargetGroup.archive(false);

      send(UpdateTarget(target));
      send(UpdateTargetGroups(newTargetGroup));
    };

    let updateTargetGroupsCB = targetGroup => {
      targetGroup |> TargetGroup.archived ?
        {
          let targetIdsInTargerGroup =
            state.targets
            |> Target.targetIdsInTargetGroup(targetGroup |> TargetGroup.id);
          let newTargets =
            state.targets
            |> List.map(target =>
                 targetIdsInTargerGroup |> List.mem(target |> Target.id) ?
                   Target.archive(target, true) : target
               );
          send(UpdateTargets(newTargets));
        } :
        ();

      send(UpdateTargetGroups(targetGroup));
    };
    <div className="flex-1 flex">
      {
        switch (state.editorAction) {
        | Hidden => ReasonReact.null
        | ShowTargetEditor(targetGroupId, target) =>
          <CurriculumEditor__TargetEditor
            target
            targetGroupId
            evaluationCriteria
            targets={state.targets}
            targetGroupIdsInLevel
            authenticityToken
            updateTargetCB
            hideEditorActionCB
          />
        | ShowTargetGroupEditor(targetGroup) =>
          <CurriculumEditor__TargetGroupEditor
            targetGroup
            currentLevelId
            authenticityToken
            updateTargetGroupsCB
            hideEditorActionCB
          />
        | ShowLevelEditor(level) =>
          <CurriculumEditor__LevelEditor
            level
            course
            authenticityToken
            hideEditorActionCB
            updateLevelsCB
          />
        }
      }
      <div
        className="px-6 pb-4 flex-1 bg-grey-lightest relative overflow-y-scroll">
        <div
          className="max-w-lg flex py-4 items-center relative md:sticky pin-t z-20 bg-grey-lightest border-b justify-between mx-auto">
          <div className="flex">
            <div className="inline-block relative w-64">
              <select
                onChange={
                  event => {
                    let level_name = ReactEvent.Form.target(event)##value;
                    send(
                      SelectLevel(
                        Level.selectLevel(state.levels, level_name),
                      ),
                    );
                  }
                }
                value={currentLevel |> Level.name}
                className="block appearance-none w-full bg-white border text-sm border-grey-light hover:border-grey px-4 py-2 pr-8 rounded-r-none leading-tight focus:outline-none">
                {
                  state.levels
                  |> Level.sort
                  |> List.map(level =>
                       <option
                         key={Level.id(level) |> string_of_int}
                         value={level |> Level.name}>
                         {
                           "Level "
                           ++ (level |> Level.number |> string_of_int)
                           ++ ": "
                           ++ (level |> Level.name)
                           |> str
                         }
                       </option>
                     )
                  |> Array.of_list
                  |> ReasonReact.array
                }
              </select>
              <div
                className="pointer-events-none absolute pin-y pin-r flex items-center px-2 text-grey-darker">
                <Icon kind=Icon.Down size="3" />
              </div>
            </div>
            <button
              className="flex text-grey-dark hover:text-grey-darkest text-sm font-bold border -ml-1 py-1 px-2 rounded-r focus:outline-none"
              onClick={
                _ =>
                  send(
                    UpdateEditorAction(
                      ShowLevelEditor(Some(state.selectedLevel)),
                    ),
                  )
              }>
              <i className="material-icons"> {"edit" |> str} </i>
            </button>
            <button
              className="text-indigo-dark hover:bg-indigo-dark font-semibold text-sm hover:text-white focus:outline-none border border-dashed border-blue hover:border-transparent flex items-center px-2 py-1 ml-4 rounded-lg cursor-pointer"
              onClick={_ => send(UpdateEditorAction(ShowLevelEditor(None)))}>
              <i className="material-icons mr-2">
                {"add_circle_outline" |> str}
              </i>
              {"Create New Level" |> str}
            </button>
          </div>
          {
            showArchivedButton(targetGroupsInLevel, state.targets) ?
              <button
                className="bg-indigo-lightest hover:bg-indigo text-indigo-dark text-sm hover:text-indigo-lightest font-semibold py-2 px-4 rounded focus:outline-none"
                onClick={_ => send(ToggleShowArchived)}>
                {
                  (state.showArchived ? "Hide Archived" : "Show Archived")
                  |> str
                }
              </button> :
              ReasonReact.null
          }
        </div>
        <div
          className="target-group__container max-w-lg mt-5 mx-auto relative">
          {
            targetGroupsToDisplay
            |> List.map(targetGroup =>
                 <CurriculumEditor__TargetGroupShow
                   key={targetGroup |> TargetGroup.id |> string_of_int}
                   targetGroup
                   targets={state.targets}
                   showTargetGroupEditorCB
                   showTargetEditorCB
                   showArchived={state.showArchived}
                 />
               )
            |> Array.of_list
            |> ReasonReact.array
          }
          <div
            onClick={
              _ => send(UpdateEditorAction(ShowTargetGroupEditor(None)))
            }
            className="target-group__create flex items-center relative bg-grey-lighter border-2 border-dashed p-6 z-10 rounded-lg mt-12 cursor-pointer">
            <Icon kind=Icon.PlusCircle size="8" />
            <h4 className="font-semibold ml-2">
              {"Create a target group" |> str}
            </h4>
          </div>
        </div>
      </div>
    </div>;
  },
};

let decode = json =>
  Json.Decode.{
    course: json |> field("course", Course.decode),
    evaluationCriteria:
      json |> field("evaluationCriteria", list(EvaluationCriteria.decode)),
    levels: json |> field("levels", list(Level.decode)),
    targetGroups: json |> field("targetGroups", list(TargetGroup.decode)),
    targets: json |> field("targets", list(Target.decode)),
    authenticityToken: json |> field("authenticityToken", string),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~course=props.course,
        ~evaluationCriteria=props.evaluationCriteria,
        ~levels=props.levels,
        ~targetGroups=props.targetGroups,
        ~targets=props.targets,
        ~authenticityToken=props.authenticityToken,
        [||],
      );
    },
  );