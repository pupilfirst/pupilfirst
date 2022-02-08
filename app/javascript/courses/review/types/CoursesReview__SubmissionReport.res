exception InvalidSubmissionReportCompletionStatus

type completedAt = Js.Date.t

type conclusion = Success | Failure | Error

type status = Queued | InProgress | Completed(conclusion, completedAt)

type t = {
  id: string,
  status: status,
  testReport: string,
  startedAt: option<Js.Date.t>,
}

let decodeConclusion = conclusion => {
  switch conclusion {
  | #success => Success
  | #failure => Failure
  | #error => Error
  }
}

let decodeCompletedStatus = (completedAt, conclusion) => {
  switch (completedAt, conclusion) {
  | (None, _) =>
    Rollbar.critical("Invalid completion status of submission report")
    raise(InvalidSubmissionReportCompletionStatus)
  | (_, None) =>
    Rollbar.critical("Invalid completion status of submission report")
    raise(InvalidSubmissionReportCompletionStatus)
  | (Some(completedAt), Some(conclusion)) =>
    Completed(decodeConclusion(conclusion), DateFns.decodeISO(completedAt))
  }
}

let decodeStatus = (status, conclusion, completedAt) => {
  switch status {
  | #queued => Queued
  | #in_progress => InProgress
  | #completed => decodeCompletedStatus(completedAt, conclusion)
  }
}

let makeFromJS = object => {
  {
    id: object["id"],
    testReport: object["testReport"],
    startedAt: object["startedAt"]->Belt.Option.map(DateFns.decodeISO),
    status: decodeStatus(object["status"], object["conclusion"], object["completedAt"]),
  }
}

let id = t => t.id

let status = t => t.status

let testReport = t => t.testReport

let startedAt = t => t.startedAt

let conclusionTimeString = t => {
  switch t.status {
  | Queued => ""
  | InProgress =>
    switch t.startedAt {
    | Some(startedAt) =>
      "Started " ++ DateFns.formatDistanceToNowStrict(startedAt, ~addSuffix=true, ())
    | None => ""
    }

  | Completed(_conclusion, completedAt) =>
    switch t.startedAt {
    | Some(startedAt) =>
      DateFns.formatDistanceToNowStrict(completedAt, ~addSuffix=true, ()) ++
      " in " ++
      DateFns.formatDistance(completedAt, startedAt, ~includeSeconds=true, ())
    | None => ""
    }
  }
}
