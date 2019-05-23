[@bs.config {jsx: 3}];

let str = React.string;

[@react.component]
let make = (~targetId, ~targetStatus, ~closeOverlayCB) => {
  Js.log2(targetId, targetStatus);
  <div className="absolute top-0 left-0 min-h-screen w-full bg-white">
    <button onClick={_e => closeOverlayCB()}> {"Close" |> str} </button>
    <div> {"This is the overlay" |> str} </div>
  </div>;
};