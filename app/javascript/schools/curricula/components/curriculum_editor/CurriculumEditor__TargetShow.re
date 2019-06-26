open CurriculumEditor__Types;

let str = ReasonReact.string;

let component =
  ReasonReact.statelessComponent("CurriculumEditor__TargetShow");

let archivedClasses = target =>
  switch (target |> Target.visibility) {
  | Archived => "target-group__target hover:bg-gray-200 target-group__target--archived border border-b-0 px-5 py-4"
  | _ => "target-group__target hover:bg-gray-200 bg-white border border-b-0 px-5 py-6"
  };

let make = (~target, ~targetGroup, ~showTargetEditorCB, _children) => {
  ...component,
  render: _self =>
    <div
      className={archivedClasses(target)}
      onClick={
        _e => showTargetEditorCB(targetGroup |> TargetGroup.id, target)
      }>
      <p className="font-semibold text-sm">
        {target |> Target.title |> str}
      </p>
      {
        switch (target |> Target.visibility) {
        | Draft => <span> {"Draft" |> str} </span>
        | _ => React.null
        }
      }
    </div>,
};