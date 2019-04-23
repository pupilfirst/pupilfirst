let component = ReasonReact.statelessComponent("SchoolCustomize__SocialLink");

let twitter = [%bs.re "/twitter/"];
let facebook = [%bs.re "/facebook/"];
let instagram = [%bs.re "/instagram/"];
let youtube = [%bs.re "/youtube/"];

let iconClass = url =>
  switch (url) {
  | url when twitter |> Js.Re.test(url) => "fab fa-twitter"
  | url when facebook |> Js.Re.test(url) => "fab fa-facebook"
  | url when instagram |> Js.Re.test(url) => "fab fa-instagram"
  | url when youtube |> Js.Re.test(url) => "fab fa-youtube"
  | _unknownUrl => "fas fa-users"
  };

let make = (~url, _children) => {
  ...component,
  render: _self =>
    <div
      className="h-12 w-12 border-0 rounded-full bg-grey-lightest mr-3 mt-3 flex items-center justify-center">
      <i className={"text-black text-2xl " ++ iconClass(url)} />
    </div>,
};