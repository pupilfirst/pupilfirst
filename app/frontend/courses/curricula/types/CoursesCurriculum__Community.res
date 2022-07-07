type topic = {
  topicId: string,
  topicTitle: string,
}

type t = {
  id: string,
  name: string,
  topics: array<topic>,
}

let decodeQuestion = json => {
  open Json.Decode
  {
    topicId: json |> field("id", string),
    topicTitle: json |> field("title", string),
  }
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    topics: json |> field("topics", array(decodeQuestion)),
  }
}

let id = t => t.id

let name = t => t.name

let topics = t => t.topics

let topicId = topic => topic.topicId

let topicTitle = question => question.topicTitle
