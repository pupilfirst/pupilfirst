type t = {
  id: string,
  title: string,
  lastActivityAt: option(Js.Date.t),
  liveRepliesCount: int,
  likesCount: int,
  topicCategoryId: option(string),
  creatorName: option(string),
  createdAt: Js.Date.t,
};

let id = t => t.id;

let title = t => t.title;

let lastActivityAt = t => t.lastActivityAt;

let liveRepliesCount = t => t.liveRepliesCount;

let likesCount = t => t.likesCount;

let topicCategoryId = t => t.topicCategoryId;

let creatorName = t => t.creatorName;

let createdAt = t => t.createdAt;

let make =
    (
      ~id,
      ~title,
      ~lastActivityAt,
      ~liveRepliesCount,
      ~likesCount,
      ~topicCategoryId,
      ~creatorName,
      ~createdAt,
    ) => {
  id,
  title,
  lastActivityAt,
  liveRepliesCount,
  likesCount,
  topicCategoryId,
  creatorName,
  createdAt,
};

let makeFromJS = topicData => {
  make(
    ~id=topicData##id,
    ~title=topicData##title,
    ~lastActivityAt=
      topicData##lastActivityAt->Belt.Option.map(DateFns.decodeISO),
    ~liveRepliesCount=topicData##liveRepliesCount,
    ~likesCount=topicData##likesCount,
    ~topicCategoryId=topicData##topicCategoryId,
    ~creatorName=topicData##creatorName,
    ~createdAt=topicData##createdAt->DateFns.decodeISO,
  );
};
