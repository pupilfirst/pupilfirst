open CurriculumEditor__Types;

let str = ReasonReact.string;

let component =
  ReasonReact.statelessComponent("CurriculumEditor__TargetShow");

let make = (~target, ~targetGroup, ~showTargetEditorCB, _children) => {
  ...component,
  render: _self =>
    <div
      className="target-group__target hover:bg-grey-lighter bg-white border border-b-0 px-5 py-6"
      onClick={
        _e => showTargetEditorCB(targetGroup |> TargetGroup.id, Some(target))
      }>
      <h5 className="font-semibold"> {target |> Target.title |> str} </h5>
    </div>,
};