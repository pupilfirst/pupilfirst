[@bs.config {jsx: 3}];

let str = React.string;

[%bs.raw {|require("./Tooltip.css")|}];

let tipClasses = "overflow-y-auto mt-1 border border-gray-900 z-50 px-2 py-1 shadow-lg leading-snug rounded-lg bg-gray-900 text-white text-center";

let width = testerWidth => {
  let widthInPx = (testerWidth |> string_of_int) ++ "px";
  ReactDOMRe.Style.make(~width=widthInPx, ());
};

[@react.component]
let make = (~tip, ~className="", ~children) => {
  let (testerId, _) = React.useState(() => DateTime.randomId());
  let (testerWidth, setTesterWidth) = React.useState(() => 200);

  React.useEffect0(() => {
    let element = Webapi.Dom.(document |> Document.getElementById(testerId));

    element
    |> OptionUtils.mapWithDefault(
         element => {
           let testerWidth = (element |> Webapi.Dom.Element.clientWidth) + 5;
           setTesterWidth(_ => testerWidth);
         },
         (),
       );
    None;
  });

  <div className={"tooltip__container relative " ++ className}>
    <div id=testerId className={"invisible fixed max-w-xs " ++ tipClasses}>
      tip
    </div>
    children
    <div
      style={width(testerWidth)}
      className={"tooltip__tip-container absolute " ++ tipClasses}>
      tip
    </div>
  </div>;
};
