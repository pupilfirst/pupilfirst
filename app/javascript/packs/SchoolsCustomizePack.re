type props = {
  authenticityToken: string,
  customizations: SchoolCustomize__Customizations.t,
  schoolName: string,
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    customizations:
      json |> field("customizations", SchoolCustomize__Customizations.decode),
    schoolName: json |> field("schoolName", string),
  };

let props = DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolCustomize__Root
    authenticityToken={props.authenticityToken}
    customizations={props.customizations}
    schoolName={props.schoolName}
  />,
  "react-root",
);
