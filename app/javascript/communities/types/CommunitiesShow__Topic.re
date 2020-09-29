type t = {
  id: string,
  title: string,
  lastActivityAt: option(Js.Date.t),
  liveRepliesCount: int,
  likesCount: int,
  views: int,
  topicCategoryId: option(string),
  creator: option(CommunitiesShow__TopicParticipant.t),
  createdAt: Js.Date.t,
  participantsCount: int,
  participants: array(CommunitiesShow__TopicParticipant.t),
};

let id = t => t.id;

let title = t => t.title;

let views = t => t.views;

let lastActivityAt = t => t.lastActivityAt;

let liveRepliesCount = t => t.liveRepliesCount;

let likesCount = t => t.likesCount;

let topicCategoryId = t => t.topicCategoryId;

let creator = t => t.creator;

let createdAt = t => t.createdAt;

let participants = t => t.participants;

let participantsCount = t => t.participantsCount;

let make =
    (
      ~id,
      ~title,
      ~lastActivityAt,
      ~liveRepliesCount,
      ~likesCount,
      ~views,
      ~topicCategoryId,
      ~creator,
      ~createdAt,
      ~participantsCount,
      ~participants,
    ) => {
  id,
  title,
  lastActivityAt,
  liveRepliesCount,
  likesCount,
  views,
  topicCategoryId,
  creator,
  createdAt,
  participantsCount,
  participants,
};

let makeFromJS = topicData => {
  make(
    ~id=topicData##id,
    ~title=topicData##title,
    ~lastActivityAt=
      topicData##lastActivityAt->Belt.Option.map(DateFns.decodeISO),
    ~liveRepliesCount=topicData##liveRepliesCount,
    ~likesCount=topicData##likesCount,
    ~views=topicData##views,
    ~topicCategoryId=topicData##topicCategoryId,
    ~creator=
      topicData##creator
      ->Belt.Option.map(CommunitiesShow__TopicParticipant.makeFromJs),
    ~createdAt=topicData##createdAt->DateFns.decodeISO,
    ~participantsCount=topicData##participantsCount,
    ~participants=
      topicData##participants
      |> Js.Array.map(participant =>
           CommunitiesShow__TopicParticipant.makeFromJs(participant)
         ),
  );
};
