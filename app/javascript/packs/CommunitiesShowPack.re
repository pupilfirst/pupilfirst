open CommunitiesShow__Types;

type props = {
  communityId: string,
  target: option(Target.t),
};

let decodeProps = json =>
  Json.Decode.{
    communityId: json |> field("communityId", string),
    target: json |> optional(field("target", Target.decode)),
  };

let props = DomUtils.parseJSONTag() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CommunitiesShow__Root
    communityId={props.communityId}
    target={props.target}
    showPrevPage=true
    showNextPage=true
  />,
  "react-root",
);
