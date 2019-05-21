[@bs.config {jsx: 3}];

let str = React.string;

open StudentTopNav__Types;

let handleToggle = (linksVisible, setLinksVisible, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setLinksVisible(linksVisible => !linksVisible);
};

let additionalLinks = (linksVisible, links) =>
  linksVisible ?
    <div
      className="border-2 border-gray-200 rounded-lg absolute w-48 bg-white mt-2">
      {
        links
        |> List.mapi((index, link) =>
             <div key={index |> string_of_int} className="p-2 cursor-default">
               <a
                 className="no-underline text-black"
                 href={link |> NavLink.url}>
                 {link |> NavLink.title |> str}
               </a>
             </div>
           )
        |> Array.of_list
        |> ReasonReact.array
      }
    </div> :
    ReasonReact.null;

[@react.component]
let make = (~links) => {
  let (linksVisible, setLinksVisible) = React.useState(() => false);
  switch (links) {
  | [] => ReasonReact.null
  | moreLinks =>
    <div
      title="Show more links"
      className="ml-6 font-semibold text-sm cursor-pointer relative"
      onClick={handleToggle(linksVisible, setLinksVisible)}
      key="more-links">
      <span> {"More" |> str} </span>
      <i className="fas fa-angle-down ml-1" />
      {additionalLinks(linksVisible, moreLinks)}
    </div>
  };
};