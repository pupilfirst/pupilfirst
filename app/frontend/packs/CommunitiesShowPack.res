open CommunitiesShow__Types

let decodeProps = json => {
  open Json.Decode
  (
    field("communityId", string, json),
    option(field("target", Target.decode), json),
    field("topicCategories", array(TopicCategory.decode), json),
  )
}

Psj.match("communities#show", () => {
  let (communityId, target, topicCategories) = decodeProps(DomUtils.parseJSONTag())

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(<CommunitiesShow__Root communityId target topicCategories />, root)
  | None => ()
  }
})
