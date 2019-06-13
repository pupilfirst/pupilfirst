[@bs.config {jsx: 3}];

[%bs.raw {|require("./DisablingCover.css")|}];

[@react.component]
let make = (~disabled, ~message="Loading...", ~containerClasses="", ~children) =>
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
            <div className="bg-gray-200 rounded-lg p-6">
              <div
                className="disabling-cover__loading-poolball relative disabling-cover__poolball-animation mx-auto">
                <div
                  className="disabling-cover__shape disabling-cover__shape-1"
                />
                <div
                  className="disabling-cover__shape disabling-cover__shape-2"
                />
                <div
                  className="disabling-cover__shape disabling-cover__shape-3"
                />
                <div
                  className="disabling-cover__shape disabling-cover__shape-4"
                />
              </div>
              <span className="block p-3 font-semibold">
                {message |> React.string}
              </span>
            </div>
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
