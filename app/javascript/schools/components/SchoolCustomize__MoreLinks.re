let str = ReasonReact.string;

type state = bool;

let component = ReasonReact.reducerComponent("SchoolCustomize__MoreLinks");

let toggleState = (send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send();
};

let additionalLinks = (linksVisible, links) =>
  if (linksVisible) {
    links
    |> List.map(((id, title, _)) =>
         <div className="border p-4" key=id>
           <span> {title |> str} </span>
         </div>
       );
  } else {
    [];
  };

let make = (~links, _children) => {
  ...component,
  initialState: () => false,
  reducer: (_action, linksVisible) => ReasonReact.Update(!linksVisible),
  render: ({state, send}) =>
    switch (links) {
    | [] => ReasonReact.null
    | moreLinks =>
      [
        <div
          className="border p-4 cursor-pointer"
          onClick={toggleState(send)}
          key="more-links">
          <span> {"More" |> str} </span>
        </div>,
        ...additionalLinks(state, moreLinks),
      ]
      |> Array.of_list
      |> ReasonReact.array
    },
};