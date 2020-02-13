[@bs.config {jsx: 3}];

let str = React.string;

[%bs.raw {|require("./Tooltip.css")|}];

let width = testerWidth => {
  let widthInPx = (testerWidth |> string_of_int) ++ "px";
  ReactDOMRe.Style.make(~width=widthInPx, ());
};

let bubbleClasses = position => {
  let positionClass =
    switch (position) {
    | `Top => "tooltip__bubble--top"
    | `Right => "tooltip__bubble--right"
    | `Bottom => "tooltip__bubble--bottom"
    | `Left => "tooltip__bubble--left"
    };

  "tooltip__bubble " ++ positionClass;
};

[@react.component]
let make = (~tip, ~className="", ~position=`Top, ~children) => {
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

  <div className={"tooltip " ++ className}>
    <div id=testerId className="invisible fixed max-w-xs">
      <div className="text-xs p-2 text-center leading-snug"> tip </div>
    </div>
    <div className="tooltip__trigger"> children </div>
    <div style={width(testerWidth)} className={bubbleClasses(position)}>
      <div
        className="text-white text-xs p-2 text-center leading-snug rounded bg-gray-900">
        tip
      </div>
    </div>
  </div>;
};
