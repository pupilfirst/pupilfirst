[@bs.config {jsx: 3}];

open CourseShow__Types;

let str = React.string;

let loadTargetDetails = (targetId, setTargetDetails, ()) => {
  Js.Promise.(
    Fetch.fetch("/targets/" ++ targetId ++ "/details_v2")
    |> then_(Fetch.Response.json)
    |> then_(json =>
         {
           Js.log(json);
           setTargetDetails(_ => Some(json |> TargetDetails.decode));
         }
         |> resolve
       )
  )
  |> ignore;

  None;
};

[@react.component]
let make = (~targetId, ~targetStatus, ~closeOverlayCB) => {
  let (targetDetails, setTargetDetails) = React.useState(() => None);

  React.useEffect1(
    loadTargetDetails(targetId, setTargetDetails),
    [|targetId|],
  );

  Js.log2(targetId, targetStatus);

  <div className="absolute top-0 left-0 min-h-screen w-full bg-white">
    <button onClick={_e => closeOverlayCB()}> {"Close" |> str} </button>
    <div> {"This is the overlay" |> str} </div>
  </div>;
};