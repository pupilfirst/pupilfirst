open SchoolsConfiguration__Types;

type props = {fromAddress: option(FromAddress.t)};

let decodeProps = json =>
  Json.Decode.{
    fromAddress: json |> optional(field("fromAddress", FromAddress.decode)),
  };

let props =
  DomUtils.parseJSONTag(~id="schools-configuration-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolsConfiguration__Root fromAddress={props.fromAddress} />,
  "schools-configuration-root",
);
