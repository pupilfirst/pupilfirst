[@bs.config {jsx: 3}];

[@react.component]
let make = (~disabled, ~containerClasses="", ~children) =>
  <div className={"relative " ++ containerClasses}>
    {
      if (disabled) {
        [|
          <div
            key="school-admin-disabling-cover__blanket"
            className="absolute w-full h-full bg-white opacity-50 z-20 flex items-center justify-center"
          />,
          <div
            key="school-admin-disabling-cover__body"
            className="absolute w-full h-full z-20 flex items-center justify-center">
            <span className="p-3 border bg-grey-light rounded-full">
              {"Loading..." |> React.string}
            </span>
          </div>,
        |]
        |> React.array;
      } else {
        React.null;
      }
    }
    children
  </div>;

module Jsx2 = {
  let component =
    ReasonReact.statelessComponent("SchoolAdmin__DisablingCover");

  let make = (~disabled, ~containerClasses="", children) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(
        ~disabled,
        ~containerClasses,
        ~children=children |> React.array,
        (),
      ),
      children,
    );
};