open CurriculumEditor__Types;

let str = ReasonReact.string;

let component =
  ReasonReact.statelessComponent("CurriculumEditor__TargetGroupShow");
let make =
    (
      ~targetGroup,
      ~targets,
      ~showTargetGroupEditorCB,
      ~showTargetEditorCB,
      _children,
    ) => {
  ...component,
  render: _self => {
    let targetsInTG =
      targets
      |> List.filter(target =>
           target |> Target.targetGroupId == (targetGroup |> TargetGroup.id)
         )
      |> Target.sort;
    <div className="target-group__box relative mt-12 rounded-lg">
      <div
        className="target-group__header hover:bg-grey-lighter bg-white p-4 border border-b-0 text-center rounded-lg rounded-b-none"
        onClick={_event => showTargetGroupEditorCB(Some(targetGroup))}>
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
        targetsInTG
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
      <div
        className="target-group__target-create flex items-center bg-grey-lighter border-2 border-t-0 border-dashed p-5 rounded-lg rounded-t-none cursor-pointer"
        onClick={
          _event => showTargetEditorCB(targetGroup |> TargetGroup.id, None)
        }>
        <svg className="svg-icon w-8 h-8" viewBox="0 0 20 20">
          <path
            fill="#A8B7C7"
            d="M13.388,9.624h-3.011v-3.01c0-0.208-0.168-0.377-0.376-0.377S9.624,6.405,9.624,6.613v3.01H6.613c-0.208,0-0.376,0.168-0.376,0.376s0.168,0.376,0.376,0.376h3.011v3.01c0,0.208,0.168,0.378,0.376,0.378s0.376-0.17,0.376-0.378v-3.01h3.011c0.207,0,0.377-0.168,0.377-0.376S13.595,9.624,13.388,9.624z M10,1.344c-4.781,0-8.656,3.875-8.656,8.656c0,4.781,3.875,8.656,8.656,8.656c4.781,0,8.656-3.875,8.656-8.656C18.656,5.219,14.781,1.344,10,1.344z M10,17.903c-4.365,0-7.904-3.538-7.904-7.903S5.635,2.096,10,2.096S17.903,5.635,17.903,10S14.365,17.903,10,17.903z"
          />
        </svg>
        <h5 className="font-semibold ml-2">
          {"Create another target" |> str}
        </h5>
      </div>
    </div>;
  },
};