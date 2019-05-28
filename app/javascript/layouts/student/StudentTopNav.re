[@bs.config {jsx: 3}];

let str = React.string;

open StudentTopNav__Types;

let headerLink = (key, link) =>
  <div
    key
    className="md:ml-6 text-sm font-semibold text-center cursor-default flex w-1/3 md:w-auto justify-center border-r border-b md:border-0">
    <a
      className="no-underline bg-gray-100 md:bg-white text-black hover:text-primary w-full p-4 md:p-2"
      href={link |> NavLink.url}>
      {link |> NavLink.title |> str}
    </a>
  </div>;

let logoutLink = () =>
  <div
    key="Logout-button"
    className="md:ml-6 text-sm font-semibold cursor-default flex w-1/3 md:w-auto justify-center border-r border-b md:border-0">
    <form className="button_to" method="post" action="/users/sign_out">
      <input name="_method" value="delete" type_="hidden" />
      <input name="authenticity_token" type_="hidden" />
      <div className="flex items-center justify-center">
        <button
          className="btn btn-small md:btn-normal leading-tight md:leading-normal btn-default m-4 md:m-0 no-underline font-semibold text-black"
          type_="submit"
          value="Submit">
          {"Logout" |> str}
        </button>
      </div>
    </form>
  </div>;
/* <a className="no-underline text-black" href="#"> {"Logout" |> str} </a> */

let isMobile = () => Webapi.Dom.window |> Webapi.Dom.Window.innerWidth < 768;

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
    ->List.append([logoutLink()])
    |> Array.of_list
    |> ReasonReact.array
  };
};

[@react.component]
let make = (~schoolName, ~logoUrl, ~links) => {
  let (menuHidden, toggleMenuHidden) = React.useState(() => isMobile());

  React.useEffect(() => {
    let resizeCB = _ => toggleMenuHidden(_ => isMobile());
    Webapi.Dom.Window.asEventTarget(Webapi.Dom.window)
    |> Webapi.Dom.EventTarget.addEventListener("resize", resizeCB);
    None;
  });

  <div className="flex py-2 px-3 border-b">
    <nav
      className="flex flex-col md:flex-row w-full xl:max-w-5xl mx-auto justify-between items-center">
      <div className="flex w-full flex-row items-center justify-between">
        <a className="w-40 pr-6 pl-2 py-4" href="/">
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
          <div
            className={
              "student-navbar__toggle focus:outline-none rounded-full h-10 w-12 p-3 md:hidden "
              ++ (menuHidden ? "" : "opened")
            }>
            <span className="sr-only"> {"Toggle navigation" |> str} </span>
            <span className="icon-bar top-bar" />
            <span className="icon-bar middle-bar" />
            <span className="icon-bar bottom-bar" />
          </div>
        </div>
      </div>
      {
        menuHidden ?
          React.null :
          <div
            className="student-navbar__links-container flex flex-row md:items-center border-t border-l md:border-0 w-full md:w-1/2 flex-wrap md:flex-no-wrap shadow-lg md:shadow-none">
            {headerLinks(links)}
          </div>
      }
    </nav>
  </div>;
};