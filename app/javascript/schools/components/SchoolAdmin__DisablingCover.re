let component = ReasonReact.statelessComponent("SchoolAdmin__DisablingCover");

let make = (~disabled, children) => {
  ...component,
  render: self =>
    <div className="relative">
      {
        if (disabled) {
          <div
            className="absolute w-full h-full bg-white opacity-50 z-20 flex items-center justify-center">
            {"Loading" |> ReasonReact.string}
          </div>;
        } else {
          ReasonReact.null;
        }
      }
      {children |> ReasonReact.array}
    </div>,
};