exception InvalidSubmissionReportCompletionStatus

type status = Queued | InProgress | Success | Failure | Error

type t = {
  id: string,
  status: status,
  startedAt: option<Js.Date.t>,
  completedAt: option<Js.Date.t>,
  report: option<string>,
  queuedAt: Js.Date.t,
  reporter: string,
  heading: option<string>,
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
    report: object["report"]->Js.Nullable.toOption,
    queuedAt: object["queuedAt"]->DateFns.decodeISO,
    startedAt: object["startedAt"]->Belt.Option.map(DateFns.decodeISO),
    completedAt: object["completedAt"]->Belt.Option.map(DateFns.decodeISO),
    status: decodeStatus(object["status"]),
    reporter: object["reporter"],
    heading: object["heading"]->Js.Nullable.toOption,
    targetUrl: object["targetUrl"],
  }
}

let id = t => t.id

let status = t => t.status

let report = t => t.report

let startedAt = t => t.startedAt

let queuedAt = t => t.queuedAt

let completedAt = t => t.completedAt

let reporter = t => t.reporter

let heading = t => t.heading

let targetUrl = t => t.targetUrl
