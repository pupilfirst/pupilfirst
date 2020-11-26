type t = {
  id: string,
  title: string,
  lastActivityAt: option<Js.Date.t>,
  liveRepliesCount: int,
  likesCount: int,
  views: int,
  topicCategoryId: option<string>,
  creatorName: option<string>,
  createdAt: Js.Date.t,
  solved: bool,
  participantsCount: int,
  participants: array<CommunitiesShow__TopicParticipant.t>,
}

let id = t => t.id

let title = t => t.title

let solved = t => t.solved

let views = t => t.views

let lastActivityAt = t => t.lastActivityAt

let liveRepliesCount = t => t.liveRepliesCount

let likesCount = t => t.likesCount

let topicCategoryId = t => t.topicCategoryId

let creatorName = t => t.creatorName

let createdAt = t => t.createdAt

let participants = t => t.participants

let participantsCount = t => t.participantsCount

let make = (
  ~id,
  ~title,
  ~lastActivityAt,
  ~liveRepliesCount,
  ~likesCount,
  ~views,
  ~topicCategoryId,
  ~creatorName,
  ~createdAt,
  ~solved,
  ~participantsCount,
  ~participants,
) => {
  id: id,
  title: title,
  lastActivityAt: lastActivityAt,
  liveRepliesCount: liveRepliesCount,
  likesCount: likesCount,
  views: views,
  topicCategoryId: topicCategoryId,
  creatorName: creatorName,
  createdAt: createdAt,
  solved: solved,
  participantsCount: participantsCount,
  participants: participants,
}

let makeFromJS = topicData =>
  make(
    ~id=topicData["id"],
    ~title=topicData["title"],
    ~lastActivityAt=topicData["lastActivityAt"]->Belt.Option.map(DateFns.decodeISO),
    ~liveRepliesCount=topicData["liveRepliesCount"],
    ~likesCount=topicData["likesCount"],
    ~views=topicData["views"],
    ~topicCategoryId=topicData["topicCategoryId"],
    ~creatorName=Belt.Option.map(topicData["creator"], creator => creator["name"]),
    ~createdAt=topicData["createdAt"]->DateFns.decodeISO,
    ~solved=topicData["solved"],
    ~participantsCount=topicData["participantsCount"],
    ~participants=topicData["participants"] |> Js.Array.map(participant =>
      CommunitiesShow__TopicParticipant.makeFromJs(participant)
    ),
  )
