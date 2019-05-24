[@bs.config {jsx: 3}];

open CourseShow__Types;

let str = React.string;

let loadTargetDetails = (target, setTargetDetails, ()) => {
  Js.Promise.(
    Fetch.fetch("/targets/" ++ (target |> Target.id) ++ "/details_v2")
    |> then_(Fetch.Response.json)
    |> then_(json =>
         setTargetDetails(_ => Some(json |> TargetDetails.decode)) |> resolve
       )
  )
  |> ignore;

  None;
};

let content = targetDetails =>
  switch (targetDetails) {
  | Some(details) =>
    details
    |> TargetDetails.contentBlocks
    |> List.map(block => {
         let renderedBlock =
           switch (block |> ContentBlock.blockType) {
           | Markdown(markdown) => <MarkdownBlock markdown className="" />
           | File(url, title) => <a href=url> {"File: " ++ title |> str} </a>
           | Image(url, caption) => <img src=url alt=caption />
           | Embed(_url, embedCode) =>
             <div dangerouslySetInnerHTML={"__html": embedCode} />
           };

         <div key={block |> ContentBlock.id}> renderedBlock </div>;
       })
    |> Array.of_list
    |> React.array
  | None => <div> {"Loading..." |> str} </div>
  };

[@react.component]
let make = (~target, ~targetStatus, ~closeOverlayCB) => {
  let (targetDetails, setTargetDetails) = React.useState(() => None);

  React.useEffect1(
    loadTargetDetails(target, setTargetDetails),
    [|target |> Target.id|],
  );

  <div className="absolute top-0 left-0 min-h-screen w-full bg-white">
    <button onClick={_e => closeOverlayCB()}> {"Close" |> str} </button>
    <h1> {target |> Target.title |> str} </h1>
    <h2> {"Learn" |> str} </h2>
    {content(targetDetails)}
    <h2> {"Discuss" |> str} </h2>
    <h2> {"Complete" |> str} </h2>
    <div> {"This is the overlay" |> str} </div>
  </div>;
};