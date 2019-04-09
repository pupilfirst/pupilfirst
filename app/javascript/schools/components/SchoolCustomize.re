open SchoolCustomize__Types;

[%bs.raw {|require("./SchoolCustomize.css")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("SchoolCustomize");

let headerLogo = (schoolName, logoOnLightBg) =>
  <div className="h-12">
    {
      switch (logoOnLightBg) {
      | Some(logo) => <img className="h-full" src=logo />
      | None => <span> {schoolName |> str} </span>
      }
    }
  </div>;

let headerLink = ((title, _)) =>
  <div className="ml-8" key=title> <span> {title |> str} </span> </div>;

let headerLinks = links => {
  let (visibleLinks, dropdownLinks) =
    switch (links) {
    | [l1, l2, l3, l4, l5, ...rest] => ([l1, l2, l3], [l4, l5, ...rest])
    | fourOrLessLinks => (fourOrLessLinks, [])
    };

  visibleLinks
  |> List.map(l => headerLink(l))
  |> List.rev_append([
       <SchoolCustomize__MoreLinks links=dropdownLinks key="more-links" />,
     ])
  |> Array.of_list
  |> ReasonReact.array;
};

let footerLinks = links => <div> {"Links go here" |> str} </div>;

let make = (~authenticityToken, ~customizations, ~schoolName, _children) => {
  ...component,
  render: _self =>
    <div className="px-6 pt-6">
      <div> {"Header" |> str} </div>
      <div className="border rounded-lg p-4 flex justify-between mt-2 w-2/3">
        <div>
          {
            headerLogo(
              schoolName,
              customizations |> Customizations.logoOnLightBg,
            )
          }
        </div>
        <div className="flex items-center">
          {headerLinks(customizations |> Customizations.headerLinks)}
          <div className="ml-8 w-12 h-12 border rounded-full bg-grey" />
        </div>
      </div>
      <div className="mt-4"> {"Footer" |> str} </div>
      <div
        className="mt-2 bg-grey-darkest border rounded-lg w-2/3 text-white p-4 flex">
        <div className="w-2/3">
          <span className="uppercase font-bold text-sm">
            {"Sitemap" |> str}
          </span>
          {footerLinks(customizations |> Customizations.footerLinks)}
        </div>
        <div className="w-1/3">
          <span className="uppercase font-bold text-sm">
            {"Address" |> str}
          </span>
        </div>
      </div>
    </div>,
};