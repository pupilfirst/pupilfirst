open TopicsShow__Types

type props = {
  communityId: string,
  target: option<LinkedTarget.t>,
  topicCategories: array<TopicCategory.t>,
}

let decodeProps = json => {
  open Json.Decode
  {
    communityId: field("communityId", string, json),
    target: option(field("target", LinkedTarget.decode), json),
    topicCategories: field("topicCategories", array(TopicCategory.decode), json),
  }
}

Psj.match("communities#new_topic", () => {
  let props = decodeProps(DomUtils.parseJSONTag())

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
