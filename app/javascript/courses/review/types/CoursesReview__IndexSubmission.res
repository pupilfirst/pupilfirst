type status = {
  passedAt: option<Js.Date.t>,
  feedbackSent: bool,
}

type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  levelId: string,
  userNames: string,
  status: option<status>,
  coachIds: array<string>,
  teamName: option<string>,
}

let id = t => t.id
let title = t => t.title
let levelId = t => t.levelId

let userNames = t => t.userNames

let coachIds = t => t.coachIds

let teamName = t => t.teamName

let failed = t =>
  switch t.status {
  | None => false
  | Some(status) => status.passedAt |> OptionUtils.mapWithDefault(_ => false, true)
  }

let pendingReview = t => t.status |> OptionUtils.mapWithDefault(_ => false, true)

let feedbackSent = t => t.status |> OptionUtils.mapWithDefault(status => status.feedbackSent, false)

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let timeDistance = t => t.createdAt->DateFns.formatDistanceToNowStrict(~addSuffix=true, ())

let make = (~id, ~title, ~createdAt, ~levelId, ~userNames, ~status, ~coachIds, ~teamName) => {
  id: id,
  title: title,
  createdAt: createdAt,
  levelId: levelId,
  userNames: userNames,
  status: status,
  coachIds: coachIds,
  teamName: teamName,
}

let makeStatus = (~passedAt, ~feedbackSent) => {passedAt: passedAt, feedbackSent: feedbackSent}

let decodeJs = submission => {
  let status =
    submission["evaluatedAt"]->Belt.Option.map(_ =>
      makeStatus(
        ~passedAt=submission["passedAt"]->Belt.Option.map(DateFns.decodeISO),
        ~feedbackSent=submission["feedbackSent"],
      )
    )

  make(
    ~id=submission["id"],
    ~title=submission["title"],
    ~createdAt=DateFns.decodeISO(submission["createdAt"]),
    ~levelId=submission["levelId"],
    ~userNames=submission["userNames"],
    ~status,
    ~coachIds=submission["coachIds"],
    ~teamName=submission["teamName"],
  )
}

let replace = (e, l) => l |> Array.map(s => s.id == e.id ? e : s)

let statusEq = (overlaySubmission, t) =>
  switch (t.status, CoursesReview__OverlaySubmission.evaluatedAt(overlaySubmission)) {
  | (None, None) => true
  | (Some({passedAt}), Some(_)) =>
    passedAt == CoursesReview__OverlaySubmission.passedAt(overlaySubmission)
  | (Some(_), None)
  | (None, Some(_)) => false
  }
