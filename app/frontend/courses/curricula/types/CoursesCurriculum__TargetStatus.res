module Course = CoursesCurriculum__Course
module Student = CoursesCurriculum__Student
module Target = CoursesCurriculum__Target
module Level = CoursesCurriculum__Level
module TargetGroup = CoursesCurriculum__TargetGroup
module LatestSubmission = CoursesCurriculum__LatestSubmission

/*
 * Create a higher level state abstraction here. Let's pre-calculate the status for
 * all targets, since there are only two (infrequent) actions that can affect this
 * pre-calculation: a student submitting a target, or undoing a previous submission.
 *
 * The higher-level abstraction should pre-calculate and cache intermediary values for
 * the sake of performance - things like target and student's level number, the
 * submission state for each target.
 */

type lockReason =
  | CourseLocked
  | AccessLocked
  | SubmissionLimitReached(string)
  | PrerequisitesIncomplete

type status =
  | Pending
  | PendingReview
  | Completed
  | Rejected
  | Locked(lockReason)

type t = {
  targetId: string,
  status: status,
}

let tc = I18n.t(~scope="components.CoursesCurriculum__TargetStatus", ...)

type submissionStatus =
  | SubmissionMissing
  | SubmissionPendingReview
  | SubmissionCompleted
  | SubmissionRejected

type cachedTarget = {
  targetId: string,
  targetReviewed: bool,
  levelNumber: int,
  milestone: bool,
  hasAssignment: bool,
  submissionStatus: submissionStatus,
  prerequisiteTargetIds: array<string>,
}

let isPast = date => date->Belt.Option.mapWithDefault(false, DateFns.isPast)

let makePending = targets => Js.Array.map(t => {targetId: Target.id(t), status: Pending}, targets)

let lockTargets = (targets, reason) =>
  Js.Array.map(t => {targetId: Target.id(t), status: Locked(reason)}, targets)

let allTargetsAttempted = (targetCache, targetIds) =>
  targetIds->Belt.Array.every(targetId => {
    Js.Array.find(ct => ct.targetId == targetId, targetCache)->Belt.Option.mapWithDefault(
      true,
      target => target.submissionStatus != SubmissionMissing,
    )
  })

let compute = (preview, student, course, levels, targetGroups, targets, targetsRead, submissions) =>
  /* Eliminate the two course ended and student access ended conditions. */
  if preview {
    makePending(targets)
  } else if Course.ended(course) {
    lockTargets(targets, CourseLocked)
  } else if isPast(Student.endsAt(student)) {
    lockTargets(targets, AccessLocked)
  } else {
    /* Cache level number, milestone boolean, and submission status for all targets. */
    let targetCache = Js.Array.map(target => {
      let targetId = Target.id(target)

      let targetGroup = ArrayUtils.unsafeFind(
        tg => TargetGroup.id(tg) == Target.targetGroupId(target),
        "Could not find target group with ID " ++
        (Target.targetGroupId(target) ++
        " to create target cache"),
        targetGroups,
      )

      let levelNumber = Level.number(
        ArrayUtils.unsafeFind(
          l => Level.id(l) == TargetGroup.levelId(targetGroup),
          "Could not find level with ID " ++
          (Student.levelId(student) ++
          " to create target cache"),
          levels,
        ),
      )

      let submission = Js.Array.find(s => LatestSubmission.targetId(s) == targetId, submissions)

      let submissionStatus = switch submission {
      | Some(s) =>
        if LatestSubmission.hasPassed(s) {
          SubmissionCompleted
        } else if LatestSubmission.hasBeenEvaluated(s) {
          SubmissionRejected
        } else {
          SubmissionPendingReview
        }
      | None => SubmissionMissing
      }

      {
        targetId,
        targetReviewed: target->Target.reviewed,
        levelNumber,
        milestone: target->Target.milestone,
        hasAssignment: target->Target.hasAssignment,
        submissionStatus,
        prerequisiteTargetIds: Target.prerequisiteTargetIds(target),
      }
    }, targets)

    let submissionsPendingReviewCount = Js.Array.length(
      Js.Array.filter(ct => ct.submissionStatus == SubmissionPendingReview, targetCache),
    )

    /* Scan the targets cache again to form final list of target statuses. */
    Js.Array.map(ct => {
      let status = switch ct.submissionStatus {
      | SubmissionPendingReview => PendingReview
      | SubmissionCompleted => Completed
      | SubmissionRejected => Rejected
      | SubmissionMissing =>
        if (
          ct.targetReviewed &&
          Course.progressionLimit(course) != 0 &&
          submissionsPendingReviewCount >= Course.progressionLimit(course)
        ) {
          Locked(SubmissionLimitReached(string_of_int(submissionsPendingReviewCount)))
        } else if !allTargetsAttempted(targetCache, ct.prerequisiteTargetIds) {
          Locked(PrerequisitesIncomplete)
        } else if !ct.hasAssignment && Js.Array.includes(ct.targetId, targetsRead) {
          Completed
        } else {
          Pending
        }
      }

      {targetId: ct.targetId, status}
    }, targetCache)
  }

let targetId = (t: t) => t.targetId
let status = t => t.status

let isPending = t => t.status == Pending
let isAccessEnded = t =>
  switch t.status {
  | Locked(reason) => reason == AccessLocked
  | _ => false
  }

let lockReasonToString = lockReason =>
  switch lockReason {
  | CourseLocked => tc("course_locked")
  | AccessLocked => tc("access_locked")
  | SubmissionLimitReached(pendingCount) =>
    tc(~variables=[("pending_count", pendingCount)], "submission_limit_reached")
  | PrerequisitesIncomplete => tc("prerequisites_incomplete")
  }

let statusToString = t =>
  switch t.status {
  | Pending => tc("status.pending")
  | PendingReview => tc("status.pending_review")
  | Completed => tc("status.completed")
  | Rejected => tc("status.rejected")
  | Locked(_) => tc("status.locked")
  }

let statusClassesSufix = t =>
  switch t.status {
  | Pending => "pending"
  | PendingReview => "pending-review"
  | Completed => "completed"
  | Rejected => "rejected"
  | Locked(_) => "locked"
  }

let canSubmit = (~resubmittable, t) =>
  switch (resubmittable, t.status) {
  | (true, Completed)
  | (_, Pending)
  | (_, Rejected) => true
  | (false, Completed)
  | (_, PendingReview)
  | (_, Locked(_)) => false
  }

let allAttempted = ts =>
  Belt.Array.every(ts, t => Js.Array.includes(t.status, [PendingReview, Completed, Rejected]))

let allComplete = ts => Belt.Array.every(ts, t => t.status == Completed)

let anyRejected = ts => Belt.Array.some(ts, t => t.status == Rejected)

let readable = t =>
  switch t.status {
  | Pending
  | PendingReview
  | Completed
  | Rejected => true
  | Locked(CourseLocked)
  | Locked(AccessLocked) => false
  | Locked(SubmissionLimitReached(_))
  | Locked(PrerequisitesIncomplete) => true
  }
