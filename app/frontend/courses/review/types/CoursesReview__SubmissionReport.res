exception InvalidSubmissionReportCompletionStatus

type status = Queued | InProgress | Success | Failure | Error

type t = {
  id: string,
  status: status,
  startedAt: option<Js.Date.t>,
  completedAt: option<Js.Date.t>,
  testReport: option<string>,
  queuedAt: Js.Date.t,
  contextName: string,
  contextTitle: option<string>,
  targetUrl: option<string>,
}

let decodeStatus = status => {
  switch status {
  | #queued => Queued
  | #in_progress => InProgress
  | #success => Success
  | #failure => Failure
  | #error => Error
  }
}

let makeFromJS = object => {
  {
    id: object["id"],
    testReport: object["testReport"],
    queuedAt: object["queuedAt"]->DateFns.decodeISO,
    startedAt: object["startedAt"]->Belt.Option.map(DateFns.decodeISO),
    completedAt: object["completedAt"]->Belt.Option.map(DateFns.decodeISO),
    status: decodeStatus(object["status"]),
    contextName: object["contextName"],
    contextTitle: object["contextTitle"]->Js.Nullable.toOption,
    targetUrl: object["targetUrl"],
  }
}

let id = t => t.id

let status = t => t.status

let testReport = t => t.testReport

let startedAt = t => t.startedAt

let queuedAt = t => t.queuedAt

let completedAt = t => t.completedAt

let contextName = t => t.contextName

let contextTitle = t => t.contextTitle

let targetUrl = t => t.targetUrl
