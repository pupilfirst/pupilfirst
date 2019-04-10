let component = ReasonReact.statelessComponent("SchoolCustomize__SocialLink");

let make = (~link, _children) => {
  ...component,
  render: _self =>
    <div
      className="h-12 w-12 border-0 rounded-full bg-grey-lightest mr-3 mt-3 flex items-center"
    />,
};