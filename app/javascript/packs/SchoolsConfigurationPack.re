type props = {fromAddress: option(string)};

let decodeProps = json =>
  Json.Decode.{fromAddress: json |> optional(field("fromAddress", string))};

let props =
  DomUtils.parseJSONTag(~id="schools-configuration-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolsConfiguration__Root fromAddress={props.fromAddress} />,
  "schools-configuration-root",
);
