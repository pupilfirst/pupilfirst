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
  <div className="ml-8 cursor-default" key=title>
    <span> {title |> str} </span>
  </div>;

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

let sitemap = links =>
  <div className="flex flex-wrap">
    {
      links
      |> List.map(((title, _)) =>
           <div className="w-1/3 pr-4 mt-3 text-sm" key=title>
             {title |> str}
           </div>
         )
      |> Array.of_list
      |> ReasonReact.array
    }
  </div>;

let socialLinks = links =>
  <div className="flex flex-wrap">
    {
      links
      |> List.map(link => <SchoolCustomize__SocialLink link />)
      |> Array.of_list
      |> ReasonReact.array
    }
  </div>;

let address = a =>
  switch (a) {
  | Some(a) =>
    <div
      className="text-sm mt-3 leading-normal"
      dangerouslySetInnerHTML={"__html": a}
    />
  | None => ReasonReact.null
  };

let emailAddress = email =>
  switch (email) {
  | Some(email) =>
    <div className="text-sm mt-4">
      {"React us at " |> str}
      <a
        className="text-white no-underline font-bold"
        href={"mailto:" ++ email}>
        {email |> str}
      </a>
    </div>
  | None => ReasonReact.null
  };

let footerLogo = (schoolName, logoOnDarkBg) =>
  <div className="h-8">
    {
      switch (logoOnDarkBg) {
      | Some(logo) => <img className="h-full" src=logo />
      | None => <span> {schoolName |> str} </span>
      }
    }
  </div>;

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
      <div className="mt-2 w-2/3">
        <div className="bg-grey-darkest rounded-t-lg text-white p-4 flex">
          <div className="w-1/2">
            <span className="uppercase font-bold text-sm">
              {"Sitemap" |> str}
            </span>
            {sitemap(customizations |> Customizations.footerLinks)}
          </div>
          <div className="w-1/2">
            <div className="flex">
              <div className="w-1/2">
                <span className="uppercase font-bold text-sm">
                  {"Social" |> str}
                </span>
                {socialLinks(customizations |> Customizations.socialLinks)}
              </div>
              <div className="w-1/2">
                <span className="uppercase font-bold text-sm">
                  {"Contact" |> str}
                </span>
                {address(customizations |> Customizations.address)}
                {emailAddress(customizations |> Customizations.emailAddress)}
              </div>
            </div>
          </div>
        </div>
        <div
          className="bg-black rounded-b-lg text-white p-4 flex justify-between">
          {
            footerLogo(
              schoolName,
              customizations |> Customizations.logoOnDarkBg,
            )
          }
          <div className="flex items-center text-sm">
            <div> {"Privacy Policy" |> str} </div>
            <div className="ml-8"> {"Privacy Policy" |> str} </div>
            <div className="ml-8 flex items-center">
              <i className="material-icons mr-1"> {"copyright" |> str} </i>
              {
                (
                  Js.Date.make()
                  |> Js.Date.getFullYear
                  |> int_of_float
                  |> string_of_int
                )
                ++ " "
                ++ schoolName
                |> str
              }
            </div>
          </div>
        </div>
      </div>
    </div>,
};