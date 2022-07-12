type t = {
  user: UserProxy.t,
  assignedAt: Js.Date.t,
}

let user = t => t.user
let assignedAt = t => t.assignedAt

let makeFromJs = reviewerInfo => {
  user: UserProxy.makeFromJs(reviewerInfo["user"]),
  assignedAt: DateFns.decodeISO(reviewerInfo["assignedAt"]),
}

let setReviewer = reviewer => {
  user: reviewer,
  assignedAt: Js.Date.make(),
}
