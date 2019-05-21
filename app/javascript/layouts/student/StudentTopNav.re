[@bs.config {jsx: 3}];

let str = React.string;

open StudentTopNav__Types;

let headerLink = link =>
  <div className="ml-6 text-sm font-semibold cursor-default">
    <a className="no-underline text-black" href={link |> NavLink.url}>
      {link |> NavLink.title |> str}
    </a>
  </div>;

let headerLinks = links => {
  let (visibleLinks, dropdownLinks) =
    switch (links) {
    | [l1, l2, l3, l4, l5, ...rest] => ([l1, l2, l3], [l4, l5, ...rest])
    | fourOrLessLinks => (fourOrLessLinks, [])
    };

  switch (visibleLinks) {
  | [] =>
    <div
      className="border border-gray-400 rounded-lg italic text-gray-600 cursor-default text-sm py-2 px-4">
      {"You can customize links on the header." |> str}
    </div>
  | visibleLinks =>
    (visibleLinks |> List.map(l => headerLink(l)))
    ->List.append([
        <StudentTopNav__DropDown links=dropdownLinks key="more-links" />,
      ])
    |> Array.of_list
    |> ReasonReact.array
  };
};

[@react.component]
let make = (~schoolName, ~logoUrl, ~links) =>
  <div className="flex">
    <nav
      className="flex flex-row w-full xl:max-w-5xl mx-auto justify-between items-center">
      <a className="w-48 pr-6 pl-2 py-4" href="/">
        {
          switch (logoUrl) {
          | Some(url) =>
            <img className="" src=url alt={"Logo of" ++ schoolName} />
          | None =>
            <span className="text-2xl text-black"> {schoolName |> str} </span>
          }
        }
      </a>
      <div className="flex flex-row">
        /* {
             links
             |> List.map(link =>
                  <div className="px-4">
                    <a
                      className="no-underline text-black"
                      href={link |> NavLink.url}>
                      {link |> NavLink.title |> str}
                    </a>
                  </div>
                )
             |> Array.of_list
             |> React.array
           } */
         {headerLinks(links)} </div>
    </nav>
  </div>;