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
  | ShowTargetEditor
  | ShowTargetGroupEditor
  | ShowLevelEditor(Level.t);

type state = {
  selectedLevel: Level.t,
  editorAction,
  selectedTargetGroupId: int,
};

type action =
  | SelectLevel(Level.t)
  | UpdateEditorAction(editorAction);

let str = ReasonReact.string;

let component = ReasonReact.reducerComponent("CurriculumEditor");

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
    selectedTargetGroupId: 1,
  },
  reducer: (action, state) =>
    switch (action) {
    | SelectLevel(selectedLevel) =>
      ReasonReact.Update({...state, selectedLevel})
    | UpdateEditorAction(editorAction) =>
      ReasonReact.Update({...state, editorAction})
    },
  render: ({state, send}) => {
    let currentLevel = state.selectedLevel;
    let currentLevelId =
      switch (state.selectedLevel |> Level.id) {
      | Some(id) => id
      | None => 999
      };
    let targetGroupsInLevel =
      targetGroups
      |> List.filter(targetGroup =>
           targetGroup |> TargetGroup.levelId == currentLevelId
         );
    let showTargetEditorCB = () =>
      send(UpdateEditorAction(ShowTargetEditor));
    let hideEditorActionCB = () => send(UpdateEditorAction(Hidden));
    let targetGroupId = state.selectedTargetGroupId;

    <div>
      {
        switch (state.editorAction) {
        | Hidden => ReasonReact.null
        | ShowTargetEditor =>
          <CurriculumEditor__TargetEditor
            targetGroupId
            evaluationCriteria
            targets
            authenticityToken
            hideEditorActionCB
          />
        | ShowTargetGroupEditor =>
          <CurriculumEditor__TargetGroupEditor
            currentLevelId
            authenticityToken
            hideEditorActionCB
          />
        | ShowLevelEditor(level) =>
          <CurriculumEditor__LevelEditor
            level
            course
            authenticityToken
            hideEditorActionCB
          />
        }
      }
      <div
        className="border-b flex px-6 py-2 h-16 items-center justify-between">
        <div className="inline-block relative w-64">
          <select
            onChange={
              event => {
                let level_name = ReactEvent.Form.target(event)##value;
                send(SelectLevel(Level.selectLevel(levels, level_name)));
              }
            }
            value={currentLevel |> Level.name}
            className="block appearance-none w-full bg-white border border-grey-light hover:border-grey px-4 py-2 pr-8 rounded leading-tight focus:outline-none">
            {
              levels
              |> List.map(level =>
                   <option
                     key={
                       (
                         switch (level |> Level.id) {
                         | Some(id) => id
                         | None => 999
                         }
                       )
                       |> string_of_int
                     }
                     value={level |> Level.name}>
                     {level |> Level.name |> str}
                   </option>
                 )
              |> Array.of_list
              |> ReasonReact.array
            }
          </select>
          <div
            className="pointer-events-none absolute pin-y pin-r flex items-center px-2 text-grey-darker">
            <svg
              className="fill-current h-4 w-4"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20">
              <path
                d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"
              />
            </svg>
          </div>
        </div>
        <button
          className="bg-indigo-dark hover:bg-blue-dark text-white font-bold py-2 px-4 rounded focus:outline-none"
          onClick={
            _ => send(UpdateEditorAction(ShowLevelEditor(currentLevel)))
          }>
          {"Edit Level" |> str}
        </button>
        <button
          className="bg-indigo-dark hover:bg-blue-dark text-white font-bold py-2 px-4 rounded focus:outline-none"
          onClick={
            _ => send(UpdateEditorAction(ShowLevelEditor(Level.empty(12))))
          }>
          {"Create New Level" |> str}
        </button>
      </div>
      <div className="px-6 py-4 flex-1 overflow-y-scroll">
        <div
          className="target-group__container max-w-lg mt-5 mx-auto relative">
          {
            targetGroupsInLevel
            |> List.map(targetGroup =>
                 <CurriculumEditor__TargetGroupShow
                   key={targetGroup |> TargetGroup.id |> string_of_int}
                   targetGroup
                   targets
                   showTargetEditorCB
                 />
               )
            |> Array.of_list
            |> ReasonReact.array
          }
          <div
            onClick={_ => send(UpdateEditorAction(ShowTargetGroupEditor))}
            className="target-group__create flex items-center relative bg-grey-lighter border-2 border-dashed p-6 z-10 rounded-lg mt-12 cursor-pointer">
            <svg className="svg-icon w-12 h-12" viewBox="0 0 20 20">
              <path
                fill="#A8B7C7"
                d="M13.388,9.624h-3.011v-3.01c0-0.208-0.168-0.377-0.376-0.377S9.624,6.405,9.624,6.613v3.01H6.613c-0.208,0-0.376,0.168-0.376,0.376s0.168,0.376,0.376,0.376h3.011v3.01c0,0.208,0.168,0.378,0.376,0.378s0.376-0.17,0.376-0.378v-3.01h3.011c0.207,0,0.377-0.168,0.377-0.376S13.595,9.624,13.388,9.624z M10,1.344c-4.781,0-8.656,3.875-8.656,8.656c0,4.781,3.875,8.656,8.656,8.656c4.781,0,8.656-3.875,8.656-8.656C18.656,5.219,14.781,1.344,10,1.344z M10,17.903c-4.365,0-7.904-3.538-7.904-7.903S5.635,2.096,10,2.096S17.903,5.635,17.903,10S14.365,17.903,10,17.903z"
              />
            </svg>
            <h4 className="font-semibold ml-2">
              {"Creat another target group" |> str}
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