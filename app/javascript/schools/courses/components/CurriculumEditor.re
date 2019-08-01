open CurriculumEditor__Types;

type props = {
  course: Course.t,
  evaluationCriteria: list(EvaluationCriteria.t),
  levels: list(Level.t),
  targetGroups: list(TargetGroup.t),
  targets: list(Target.t),
  contentBlocks: list(ContentBlock.t),
  authenticityToken: string,
};

type editorAction =
  | Hidden
  | ShowTargetEditor(string, Target.t)
  | ShowTargetGroupEditor(option(TargetGroup.t))
  | ShowLevelEditor(option(Level.t));

type state = {
  selectedLevel: Level.t,
  editorAction,
  levels: list(Level.t),
  targetGroups: list(TargetGroup.t),
  contentBlocks: list(ContentBlock.t),
  targets: list(Target.t),
  showArchived: bool,
};

type action =
  | SelectLevel(Level.t)
  | UpdateEditorAction(editorAction)
  | UpdateLevels(Level.t)
  | UpdateTargetGroups(TargetGroup.t, editorAction)
  | UpdateTarget(Target.t, list(ContentBlock.t))
  | UpdateTargets(list(Target.t))
  | RemoveContentBlock(string)
  | AddContentBlock(ContentBlock.t)
  | ToggleShowArchived
  | UpdateContentBlocks(list(ContentBlock.t));

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
    |> List.filter(target => target |> Target.visibility === Archived)
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
      ~contentBlocks,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  initialState: () => {
    selectedLevel:
      levels
      |> List.sort((l1, l2) => (l2 |> Level.number) - (l1 |> Level.number))
      |> List.hd,
    editorAction: Hidden,
    targetGroups,
    contentBlocks,
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
    | UpdateTargetGroups(targetGroup, action) =>
      let newtargetGroups =
        targetGroup |> TargetGroup.updateList(state.targetGroups);
      ReasonReact.Update({
        ...state,
        targetGroups: newtargetGroups,
        editorAction: action,
      });
    | UpdateTarget(target, contentBlocks) =>
      let newtargets = target |> Target.updateList(state.targets);
      let newContentBlocks =
        state.contentBlocks
        |> List.filter(cb => ContentBlock.targetId(cb) != Target.id(target))
        |> List.append(contentBlocks);
      ReasonReact.Update({
        ...state,
        targets: newtargets,
        contentBlocks: newContentBlocks,
      });
    | ToggleShowArchived =>
      ReasonReact.Update({...state, showArchived: !state.showArchived})
    | UpdateTargets(targets) => ReasonReact.Update({...state, targets})
    | RemoveContentBlock(contentBlockId) =>
      ReasonReact.Update({
        ...state,
        contentBlocks:
          state.contentBlocks
          |> List.filter(cb => ContentBlock.id(cb) != contentBlockId),
      })
    | AddContentBlock(contentBlock) =>
      ReasonReact.Update({
        ...state,
        contentBlocks: List.append(contentBlocks, [contentBlock]),
      })
    | UpdateContentBlocks(contentBlocks) =>
      ReasonReact.Update({...state, contentBlocks})
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

    let updateTargetCB = (target, contentBlocks, closeEditor) => {
      let targetGroup =
        state.targetGroups |> TargetGroup.find(target |> Target.targetGroupId);

      let newTargetGroup =
        target |> Target.visibility === Archived ?
          targetGroup : targetGroup |> TargetGroup.archive(false);

      let editorAction =
        closeEditor ?
          Hidden : ShowTargetEditor(newTargetGroup |> TargetGroup.id, target);

      send(UpdateTarget(target, contentBlocks));
      send(UpdateTargetGroups(newTargetGroup, editorAction));
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
                   Target.archive(target) : target
               );
          send(UpdateTargets(newTargets));
        } :
        ();

      send(UpdateTargetGroups(targetGroup, Hidden));
    };

    let updateContentBlocksCB = (targetId, contentBlocks) => {
      let updatedContentBlocks =
        state.contentBlocks
        |> List.filter(cb => ContentBlock.targetId(cb) != targetId)
        |> List.append(contentBlocks);
      send(UpdateContentBlocks(updatedContentBlocks));
    };
    <div className="flex-1 flex flex-col">
      <div className="bg-white p-4 md:hidden shadow border-b">
        <button
          className="sa-toggle__menu-btn sa-toggle__menu-btn--arrow hover:bg-gray-200 focus:outline-none">
          <span className="sa-toggle__menu-btn-box">
            <span className="sa-toggle__menu-btn-inner" />
          </span>
        </button>
      </div>
      {
        switch (state.editorAction) {
        | Hidden => ReasonReact.null
        | ShowTargetEditor(targetGroupId, target) =>
          let targetContentBlocks =
            state.contentBlocks
            |> List.filter(contentBlock =>
                 ContentBlock.targetId(contentBlock) == Target.id(target)
               );
          <CurriculumEditor__TargetEditor.Jsx2
            target
            targetGroupId
            contentBlocks=targetContentBlocks
            evaluationCriteria
            targets={state.targets}
            targetGroupIdsInLevel
            authenticityToken
            updateTargetCB
            hideEditorActionCB
            updateContentBlocksCB
          />;
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
      <div className="px-6 pb-4 flex-1 bg-gray-100 relative overflow-y-scroll">
        <div
          className="w-full py-4 relative md:sticky top-0 z-20 bg-gray-100 border-b">
          <div className="max-w-3xl flex items-center justify-between mx-auto">
            <div className="flex">
              <div className="inline-block relative w-auto md:w-64">
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
                  className="block appearance-none w-full bg-white border text-sm border-gray-400 hover:border-gray-500 px-4 py-3 pr-8 rounded-r-none leading-tight focus:outline-none">
                  {
                    state.levels
                    |> Level.sort
                    |> List.map(level =>
                         <option
                           key={Level.id(level)} value={level |> Level.name}>
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
                  className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-3 text-gray-800">
                  <Icon.Jsx2 kind=Icon.Down size="3" />
                </div>
              </div>
              <button
                className="flex text-gray-600 hover:text-gray-900 text-sm font-bold border border-gray-400 border-l-0 py-1 px-2 rounded-r focus:outline-none"
                onClick={
                  _ =>
                    send(
                      UpdateEditorAction(
                        ShowLevelEditor(Some(state.selectedLevel)),
                      ),
                    )
                }>
                <i title="edit" className="fas fa-pencil" />
              </button>
              <button
                className="btn btn-primary ml-4"
                onClick={
                  _ => send(UpdateEditorAction(ShowLevelEditor(None)))
                }>
                <i className="fal fa-layer-plus mr-2 text-lg" />
                <span> {"Create Level" |> str} </span>
              </button>
            </div>
            {
              showArchivedButton(targetGroupsInLevel, state.targets) ?
                <button
                  className="btn btn-default"
                  onClick={_ => send(ToggleShowArchived)}>
                  {
                    (state.showArchived ? "Hide Archived" : "Show Archived")
                    |> str
                  }
                </button> :
                ReasonReact.null
            }
          </div>
        </div>
        <div
          className="target-group__container max-w-3xl mt-5 mx-auto relative">
          {
            targetGroupsToDisplay
            |> List.map(targetGroup =>
                 <CurriculumEditor__TargetGroupShow
                   key={targetGroup |> TargetGroup.id}
                   targetGroup
                   targets={state.targets}
                   showTargetGroupEditorCB
                   showTargetEditorCB
                   updateTargetCB
                   showArchived={state.showArchived}
                   authenticityToken
                 />
               )
            |> Array.of_list
            |> ReasonReact.array
          }
          <div
            onClick={
              _ => send(UpdateEditorAction(ShowTargetGroupEditor(None)))
            }
            className="target-group__create flex flex-col items-center justify-center relative bg-white border-2 border-dashed border-gray-400 p-6 z-10 hover:text-primary-500 hover:shadow-lg hover:border-primary-400 hover:border-primary-400 rounded-lg mt-12 cursor-pointer">
            <span className="flex bg-gray-200 p-2 rounded-full">
              <i className="fal fa-plus-circle text-2xl" />
            </span>
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
    contentBlocks: json |> field("contentBlocks", list(ContentBlock.decode)),
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
        ~contentBlocks=props.contentBlocks,
        ~authenticityToken=props.authenticityToken,
        [||],
      );
    },
  );