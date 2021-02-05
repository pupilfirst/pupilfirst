type event =
  | TopicCreated
  | PostCreated

type t = {
  actor: option<User.t>,
  createdAt: Js.Date.t,
  event: event,
  id: string,
  message: string,
  notifiableId: option<string>,
  notifiableType: option<string>,
  readAt: option<Js.Date.t>,
}

let make = (~actor, ~createdAt, ~event, ~id, ~message, ~notifiableId, ~notifiableType, ~readAt) => {
  actor: actor,
  createdAt: createdAt,
  event: event,
  id: id,
  message: message,
  notifiableId: notifiableId,
  notifiableType: notifiableType,
  readAt: readAt,
}

let actor = t => t.actor
let createdAt = t => t.createdAt
let event = t => t.event
let id = t => t.id
let message = t => t.message
let notifiableId = t => t.notifiableId
let notifiableType = t => t.notifiableType
let readAt = t => t.readAt

let decodeEvent = event =>
  switch event {
  | #TopicCreated => TopicCreated
  | #PostCreated => PostCreated
  }

let makeFromJS = entry =>
  make(
    ~id=entry["id"],
    ~actor=entry["actor"]->Belt.Option.map(User.makeFromJs),
    ~readAt=entry["readAt"]->Belt.Option.map(DateFns.decodeISO),
    ~createdAt=entry["createdAt"]->DateFns.decodeISO,
    ~event=entry["event"]->decodeEvent,
    ~notifiableId=entry["notifiableId"],
    ~notifiableType=entry["notifiableType"],
    ~message=entry["message"],
  )

let markAsRead = entry => {
  ...entry,
  readAt: Some(Js.Float.toString(Js.Date.now())->DateFns.parseISO),
}
