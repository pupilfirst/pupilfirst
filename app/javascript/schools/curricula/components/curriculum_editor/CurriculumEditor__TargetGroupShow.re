open CurriculumEditor__Types;

let str = ReasonReact.string;

let component =
  ReasonReact.statelessComponent("CurriculumEditor__TargetGroupShow");
let archivedClasses = archived =>
  archived ?
    "target-group__header hover:bg-grey-200 target-group__header--archived p-6 border border-b-0 text-center rounded-lg rounded-b-none" :
    "target-group__header hover:bg-grey-200hter bg-white p-6 border border-b-0 text-center rounded-lg rounded-b-none";

let make =
    (
      ~targetGroup,
      ~targets,
      ~showTargetGroupEditorCB,
      ~showTargetEditorCB,
      ~showArchived,
      _children,
    ) => {
  ...component,
  render: _self => {
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

    <div className="target-group__box relative mt-12 rounded-lg">
      <div
        id="target_group"
        className={archivedClasses(targetGroup |> TargetGroup.archived)}
        onClick={_event => showTargetGroupEditorCB(Some(targetGroup))}>
        {milestone ? <div> {"Milestone" |> str} </div> : ReasonReact.null}
        <div className="target-group__title">
          <h2> {targetGroup |> TargetGroup.name |> str} </h2>
        </div>
        <div className="target-group__description pt-2">
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
            className="target-group__target-create flex items-center bg-grey-200 border-2 border-dashed p-5 rounded-lg rounded-t-none cursor-pointer"
            onClick={
              _event =>
                showTargetEditorCB(targetGroup |> TargetGroup.id, None)
            }>
            <Icon kind=Icon.PlusCircle size="6" />
            <h5 className="font-semibold ml-2">
              {"Create a target" |> str}
            </h5>
          </div>
      }
    </div>;
  },
};