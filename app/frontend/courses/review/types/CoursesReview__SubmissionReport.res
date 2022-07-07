exception InvalidSubmissionReportCompletionStatus

type startedAt = Js.Date.t
type queuedAt = Js.Date.t

type conclusion = Success | Failure | Error

type completedTimestamps = {startedAt: Js.Date.t, completedAt: Js.Date.t}

type status = Queued(queuedAt) | InProgress(startedAt) | Completed(completedTimestamps, conclusion)

type t = {
  id: string,
  status: status,
  testReport: option<string>,
  queuedAt: Js.Date.t,
}

let decodeConclusion = conclusion => {
  switch conclusion {
  | #success => Success
  | #failure => Failure
  | #error => Error
  }
}

let decodeCompletedStatus = (startedAt, completedAt, conclusion) => {
  switch (startedAt, completedAt, conclusion) {
  | (None, _, _) =>
    Rollbar.critical(
      "Invalid completion status of submission report - start time missing for completed test",
    )
    raise(InvalidSubmissionReportCompletionStatus)
  | (_, None, _) =>
    Rollbar.critical(
      "Invalid completion status of submission report - end time missing for completed test",
    )
    raise(InvalidSubmissionReportCompletionStatus)
  | (_, _, None) =>
    Rollbar.critical(
      "Invalid completion status of submission report - conclusion missing for completed test",
    )
    raise(InvalidSubmissionReportCompletionStatus)
  | (Some(startedAt), Some(completedAt), Some(conclusion)) =>
    Completed(
      {startedAt: DateFns.decodeISO(startedAt), completedAt: DateFns.decodeISO(completedAt)},
      decodeConclusion(conclusion),
    )
  }
}

let decodeStatus = (status, conclusion, queuedAt, startedAt, completedAt) => {
  switch status {
  | #queued => Queued(DateFns.decodeISO(queuedAt))
  | #in_progress =>
    switch startedAt {
    | Some(startedAt) => InProgress(DateFns.decodeISO(startedAt))
    | None =>
      Rollbar.critical(
        "Invalid completion status of submission report - start time missing for test in progress",
      )
      raise(InvalidSubmissionReportCompletionStatus)
    }
  | #completed => decodeCompletedStatus(startedAt, completedAt, conclusion)
  }
}

let makeFromJS = object => {
  {
    id: object["id"],
    testReport: object["testReport"],
    queuedAt: object["queuedAt"]->DateFns.decodeISO,
    status: decodeStatus(
      object["status"],
      object["conclusion"],
      object["queuedAt"],
      object["startedAt"],
      object["completedAt"],
    ),
  }
}

let id = t => t.id

let status = t => t.status

let testReport = t => t.testReport

let startedAt = t => t.startedAt
