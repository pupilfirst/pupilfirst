let component = ReasonReact.statelessComponent("SchoolAdmin__DisablingCover");

let make = (~disabled, ~containerClasses="", children) => {
  ...component,
  render: _self =>
    <div className={"relative " ++ containerClasses}>
      {
        if (disabled) {
          [|
            <div
              key="school-admin-disabling-cover__blanket"
              className="absolute w-full h-full bg-white opacity-75 z-20 flex items-center justify-center"
            />,
            <div
              key="school-admin-disabling-cover__body"
              className="absolute w-full h-full z-20 flex items-center justify-center">
              <span className="p-3 border bg-grey-light rounded-full">
                {"Loading..." |> ReasonReact.string}
              </span>
            </div>,
          |]
          |> ReasonReact.array;
        } else {
          ReasonReact.null;
        }
      }
      {children |> ReasonReact.array}
    </div>,
};