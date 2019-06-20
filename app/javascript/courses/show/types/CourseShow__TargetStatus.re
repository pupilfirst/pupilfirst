module Course = CourseShow__Course;
module Team = CourseShow__Team;
module Target = CourseShow__Target;
module Level = CourseShow__Level;
module TargetGroup = CourseShow__TargetGroup;
module LatestSubmission = CourseShow__LatestSubmission;

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
  | LevelLocked
  | PreviousLevelMilestonesIncomplete
  | PrerequisitesIncomplete;

type status =
  | Pending
  | Submitted
  | Passed
  | Failed
  | Locked(lockReason);

type t = {
  targetId: string,
  status,
};

type submissionStatus =
  | SubmissionMissing
  | SubmissionPendingReview
  | SubmissionPassed
  | SubmissionFailed;

type cachedTarget = {
  targetId: string,
  levelNumber: int,
  milestone: bool,
  submissionStatus,
  prerequisiteTargetIds: list(string),
};

type cachedStudent = {levelNumber: int};

let isPast = dateString =>
  switch (dateString) {
  | Some(date) =>
    date |> DateFns.parseString |> DateFns.isBefore(Js.Date.make())
  | None => false
  };

let lockTargets = (targets, reason) =>
  targets
  |> List.map(t => {targetId: t |> Target.id, status: Locked(reason)});

let allTargetsComplete = (targetCache, targetIds) =>
  targetIds
  |> List.for_all(targetId => {
       let cachedTarget =
         targetCache |> List.find(ct => ct.targetId == targetId);
       cachedTarget.submissionStatus == SubmissionPassed;
     });

let compute =
    (team, students, course, levels, targetGroups, targets, submissions) =>
  /* Eliminate the two course ended and student access ended conditions. */
  if (course |> Course.endsAt |> isPast) {
    lockTargets(targets, CourseLocked);
  } else if (team |> Team.accessEndsAt |> isPast) {
    lockTargets(targets, AccessLocked);
  } else {
    /* Cache level number of the student. */
    let studentLevelNumber =
      levels
      |> List.find(l => l |> Level.id == (team |> Team.levelId))
      |> Level.number;

    /* Create a mutable cache of levels and their milestone completion status. */
    let levelCache =
      levels
      |> List.map(l => (l |> Level.number |> string_of_int, true))
      |> Js.Dict.fromList;

    /* Cache level number, milestone boolean, and submission status for all targets. */
    let targetsCache =
      targets
      |> List.map(target => {
           let targetId = target |> Target.id;

           let targetGroup =
             targetGroups
             |> List.find(tg =>
                  tg |> TargetGroup.id == (target |> Target.targetGroupId)
                );

           let milestone = targetGroup |> TargetGroup.milestone;

           let levelNumber =
             levels
             |> List.find(l =>
                  l |> Level.id == (targetGroup |> TargetGroup.levelId)
                )
             |> Level.number;

           let submission =
             submissions
             |> ListUtils.findOpt(s =>
                  s |> LatestSubmission.targetId == targetId
                );

           let submissionStatus =
             switch (submission) {
             | Some(s) =>
               if (s |> LatestSubmission.hasPassed) {
                 SubmissionPassed;
               } else if (s |> LatestSubmission.hasBeenEvaluated) {
                 SubmissionFailed;
               } else {
                 SubmissionPendingReview;
               }
             | None => SubmissionMissing
             };

           /* If any milestone target is incomplete, mark that level as having incomplete milestones. */
           if (milestone && submissionStatus != SubmissionPassed) {
             Js.Dict.set(levelCache, levelNumber |> string_of_int, false);
           };

           {
             targetId,
             levelNumber,
             milestone,
             submissionStatus,
             prerequisiteTargetIds: target |> Target.prerequisiteTargetIds,
           };
         });

    /* Scan the targets cache again to form final list of target statuses. */
    targetsCache
    |> List.map(ct => {
         let status =
           switch (ct.submissionStatus) {
           | SubmissionPendingReview => Submitted
           | SubmissionPassed => Passed
           | SubmissionFailed => Failed
           | SubmissionMissing =>
             if (ct.levelNumber > studentLevelNumber) {
               Locked(LevelLocked);
             } else if (ct.milestone
                        && ct.levelNumber > 1
                        && !(
                             ct.levelNumber
                             - 1
                             |> string_of_int
                             |> Js.Dict.unsafeGet(levelCache)
                           )) {
               Locked(PreviousLevelMilestonesIncomplete);
             } else if (!(
                          ct.prerequisiteTargetIds
                          |> allTargetsComplete(targetsCache)
                        )) {
               Locked(PrerequisitesIncomplete);
             } else {
               Pending;
             }
           };

         {targetId: ct.targetId, status};
       });
  };

let targetId = (t: t) => t.targetId;
let status = t => t.status;

let lockReasonToString = lr =>
  switch (lr) {
  | CourseLocked => "Course has ended"
  | AccessLocked => "Your access to course has ended"
  | LevelLocked => "You must level up to access this target"
  | PreviousLevelMilestonesIncomplete => "Previous level's milestone targets have not been reviewed yet"
  | PrerequisitesIncomplete => "This target has pre-requisites that are incomplete"
  };

let statusToString = t =>
  switch (t.status) {
  | Pending => "Pending"
  | Submitted => "Submitted"
  | Passed => "Passed"
  | Failed => "Failed"
  | Locked(_) => "Locked"
  };

let makeSubmitted = targetId => {targetId, status: Submitted};
let makePassed = targetId => {targetId, status: Passed};

let canSubmit = t =>
  switch (t.status) {
  | Pending
  | Passed
  | Failed => true
  | Submitted
  | Locked(_) => false
  };

let canLevelUp = targetStatus => {
  let validStatuses = [|Submitted, Passed|] |> Array.to_list;
  let attemptedTarget =
    targetStatus |> List.filter(t => t.status->List.mem(validStatuses));
  targetStatus == attemptedTarget;
};