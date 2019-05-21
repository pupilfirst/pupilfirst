[@bs.config {jsx: 3}];

let str = React.string;

open StudentTopNav__Types;

let headerLink = (key, link) =>
  <div
    key
    className="ml-6 text-sm font-semibold cursor-default flex w-full justify-center p-2 md:p-0 border-t-2 md:border-t-0">
    <a className="no-underline text-black" href={link |> NavLink.url}>
      {link |> NavLink.title |> str}
    </a>
  </div>;

let isMobile = () => {
  let window = Webapi.Dom.window;
  Webapi.Dom.Window.innerWidth(window) < 640;
};

let headerLinks = links => {
  let (visibleLinks, dropdownLinks) =
    switch (links, isMobile()) {
    | (links, true) => (links, [])
    | ([l1, l2, l3, l4, l5, ...rest], false) => (
        [l1, l2, l3],
        [l4, l5, ...rest],
      )
    | (fourOrLessLinks, false) => (fourOrLessLinks, [])
    };

  switch (visibleLinks) {
  | visibleLinks =>
    (
      visibleLinks
      |> List.mapi((index, l) => headerLink(index |> string_of_int, l))
    )
    ->List.append([
        <StudentTopNav__DropDown links=dropdownLinks key="more-links" />,
      ])
    |> Array.of_list
    |> ReasonReact.array
  };
};

[@react.component]
let make = (~schoolName, ~logoUrl, ~links) => {
  let (menuHidden, toggleMenuHidden) = React.useState(() => isMobile());

  Js.log(isMobile());

  <div className="flex m-2">
    <nav
      className="flex flex-col md:flex-row w-full xl:max-w-5xl mx-auto justify-between items-center">
      <div className="flex w-full flex-row items-center justify-between">
        <a className="w-48 pr-6 pl-2 py-4" href="/">
          {
            switch (logoUrl) {
            | Some(url) =>
              <img className="" src=url alt={"Logo of" ++ schoolName} />
            | None =>
              <span className="text-2xl text-black">
                {schoolName |> str}
              </span>
            }
          }
        </a>
        <div onClick={_ => toggleMenuHidden(menuHidden => !menuHidden)}>
          <FaIcon
            classes={
              "text-2xl md:hidden mr-2 "
              ++ (menuHidden ? "fas fa-hamburger" : "fas fa-times")
            }
          />
        </div>
      </div>
      {
        menuHidden ?
          React.null :
          <div className="flex flex-col md:flex-row w-full md:w-1/2">
            {headerLinks(links)}
          </div>
      }
    </nav>
  </div>;
};