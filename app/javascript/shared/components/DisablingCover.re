[@bs.config {jsx: 3}];

[@react.component]
let make = (~disabled, ~containerClasses="", ~children) =>
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
                className="loading-poolball relative poolball-animation mx-auto">
                <div className="shape shape1" />
                <div className="shape shape2" />
                <div className="shape shape3" />
                <div className="shape shape4" />
              </div>
              <span className="block p-3 font-semibold">
                {"Loading..." |> React.string}
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