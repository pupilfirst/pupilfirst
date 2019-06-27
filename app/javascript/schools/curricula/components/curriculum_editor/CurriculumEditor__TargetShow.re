open CurriculumEditor__Types;

let str = ReasonReact.string;

let component =
  ReasonReact.statelessComponent("CurriculumEditor__TargetShow");

let archivedClasses = target =>
  switch (target |> Target.visibility) {
  | Archived => "target-group__target flex justify-between items-center hover:bg-gray-200 target-group__target--archived border border-b-0 px-5 py-4"
  | _ => "target-group__target flex justify-between items-center hover:bg-gray-200 bg-white border border-b-0 px-5 py-6"
  };

let make = (~target, ~targetGroup, ~showTargetEditorCB, _children) => {
  ...component,
  render: _self =>
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
            className="target-group__target-draft-pill items-center leading-tight text-xs py-1 px-2 font-semibold rounded-lg border bg-blue-100 text-blue-700 border-blue-400">
            <i className="far fa-list-alt text-sm" />
            <span className="ml-1"> {"Draft" |> str} </span>
          </span>
        | _ => React.null
        }
      }
    </div>,
};