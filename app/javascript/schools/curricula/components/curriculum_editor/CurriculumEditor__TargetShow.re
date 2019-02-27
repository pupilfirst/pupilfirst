open CurriculumEditor__Types;

let str = ReasonReact.string;

type props = {target: Target.t};

let component =
  ReasonReact.statelessComponent("CurriculumEditor__TargetShow");

let make = (~target, ~targetGroup, ~showTargetEditorCB, _children) => {
  ...component,
  render: _self =>
    <div
      className="target-group__target hover:bg-grey-lighter bg-white border p-5"
      onClick={
        _e => showTargetEditorCB(targetGroup |> TargetGroup.id, Some(target))
      }>
      <h5 className="font-semibold"> {target |> Target.title |> str} </h5>
    </div>,
};