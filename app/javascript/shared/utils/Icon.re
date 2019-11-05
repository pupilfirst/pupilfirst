[@bs.config {jsx: 3}];

[@bs.module "./iconFirst"]
external transformIcons: unit => unit = "transformIcons";

[@react.component]
let make = (~className) => {
  React.useEffect1(
    () => {
      transformIcons();
      None;
    },
    [|className|],
  );
  <span className="inline-flex" key=className> <i className /> </span>;
};
