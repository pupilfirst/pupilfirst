open TopicsShow__Types

type props = {
  communityId: string,
  target: option<LinkedTarget.t>,
  topicCategories: array<TopicCategory.t>,
}

let decodeProps = json => {
  open Json.Decode
  {
    communityId: json |> field("communityId", string),
    target: json |> optional(field("target", LinkedTarget.decode)),
    topicCategories: json |> field("topicCategories", array(TopicCategory.decode)),
  }
}

Psj.match("communities#new_topic", () => {
  let props = DomUtils.parseJSONTag() |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(
      <CommunitiesNewTopic__Root
        communityId=props.communityId target=props.target topicCategories=props.topicCategories
      />,
      root,
    )
  | None => ()
  }
})
