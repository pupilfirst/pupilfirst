open CurriculumEditor__Types;

let str = ReasonReact.string;

let component =
  ReasonReact.statelessComponent("CurriculumEditor__TargetShow");

let archivedClasses = target =>
  switch (target |> Target.visibility) {
  | Archived => "target-group__target flex justify-between items-center target-group__target--archived pl-2 pr-5 py-4"
  | _ => "target-group__target flex justify-between items-center pl-2 pr-5 py-6"
  };

let updateSortIndex =
    (targets, index, up, updateTagetSortIndexCB, authenticityToken) => {
  let newTargets = targets |> ListUtils.swap(index, up);
  let targetIds = newTargets |> List.map(t => t |> Target.id) |> Array.of_list;
  targetIds
  |> CurriculumEditor__SortResourcesMutation.sort(
       CurriculumEditor__SortResourcesMutation.Target,
       authenticityToken,
     );
  updateTagetSortIndexCB(newTargets);
};

let make =
    (
      ~index,
      ~target,
      ~targetGroup,
      ~showTargetEditorCB,
      ~targets,
      ~updateTagetSortIndexCB,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  render: _self =>
    <div
      className="flex target-group__target-container border-t bg-white overflow-hidden items-center relative hover:bg-gray-100 hover:text-primary-500">
      <div
        className="target-group__target-reorder relative flex flex-col z-10 h-full border-r border-transparent text-gray-700 justify-between items-center">
        <div
          title="Move Up"
          className="target-group__target-reorder-up flex items-center justify-center cursor-pointer w-9 h-9 p-1 text-gray-400 hover:bg-gray-200"
          onClick={
            _ =>
              updateSortIndex(
                targets,
                index,
                true,
                updateTagetSortIndexCB,
                authenticityToken,
              )
          }>
          <i className="fas fa-arrow-up text-sm" />
        </div>
        <div
          title="Move Down"
          className="target-group__target-reorder-down flex items-center justify-center cursor-pointer w-9 h-9 p-1 border-t border-transparent text-gray-400 hover:bg-gray-200"
          onClick={
            _ =>
              updateSortIndex(
                targets,
                index,
                false,
                updateTagetSortIndexCB,
                authenticityToken,
              )
          }>
          <i className="fas fa-arrow-down text-sm" />
        </div>
      </div>
      <div
        id={"target-show-" ++ (target |> Target.id)}
        className={archivedClasses(target)}
        onClick={
          _e => showTargetEditorCB(targetGroup |> TargetGroup.id, target)
        }>
        <p className="font-semibold text-sm">
          {target |> Target.title |> str}
        </p>
        {
          switch (target |> Target.visibility) {
          | Draft =>
            <span
              className="target-group__target-draft-pill flex-shrink-0 items-center leading-tight text-xs py-1 px-2 font-semibold rounded-lg border bg-blue-100 text-blue-700 border-blue-400">
              <i className="fas fa-file-signature text-sm" />
              <span className="ml-1"> {"Draft" |> str} </span>
            </span>
          | _ => React.null
          }
        }
      </div>
    </div>,
};