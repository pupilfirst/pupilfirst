let str = ReasonReact.string;
let component = ReasonReact.statelessComponent("SchoolInputGroupError");

let make = (~message, ~active, _children) => {
  ...component,
  render: _self =>
    if (active) {
      <div className="mt-2 text-red inline-flex items-center">
        <span className="ml-4 mr-2">
          <Icon.Jsx2 kind=Icon.Alert size="3" />
        </span>
        <span> {message |> str} </span>
      </div>;
    } else {
      ReasonReact.null;
    },
};