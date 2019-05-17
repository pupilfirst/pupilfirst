[@bs.config {jsx: 3}];

open CourseShow__Types;

/*
 * Create a higher level state abstraction here. Let's pre-calculate the status for
 * all targets, since there are only two (infrequent) actions that can affect this
 * pre-calculation: a student submitting a target, or undoing a previous submission.
 *
 * The higher-level abstraction should pre-calculate and cache intermediary values for
 * the sake of performance - things like target and student's level number, the
 * submission state for each target.
 */
module StatusComputer = {
  type lockReason =
    | CourseLocked
    | LevelLocked
    | PreviousLevelMilestonesIncomplete
    | PrerequisitesIncomplete;

  type status =
    | Pending
    | Submitted
    | Passed
    | Failed
    | Locked(lockReason);

  type targetStatus = {
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
  };

  type cachedStudent = {levelNumber: int};

  let compute = (team, students, course, levels, targets, submissions) => {
    /* Step 0: Eliminate the two course ended and student access ended conditions. */
    /* Step 1: Cache level number of the student. */
    /* Step 2: Cache level number, milestone boolean, and submission status for all targets. */
    /* Do the stuff in the computeStatusOfTargets (below), but with the cached values. */
  };
};

/*
 let computeStatusOfTargets = (locked, students, levels, targets, submissions) =>
   if (locked) {
     targets
     |> List.map(target =>
          {targetId: target |> Target.id, status: Locked(CourseLocked)}
        );
   } else {
     targets
     |> List.map(target => {
          let targetId = target |> Target.id;

          let status =
            switch (
              submissions
              |> ListUtils.findOpt(s => s |> Submission.targetId == targetId)
            ) {
            | Some(submission) =>
              if (submission |> Submission.hasPassed) {
                Passed;
              } else if (submission |> Submission.hasBeenEvaluated) {
                Failed;
              } else {
                Submitted;
              }
            | None =>
              let targetLevel = target |> Target.levelNumber;
              let studentLevel = currentStudent |> Student.levelNumber;

              if (targetLevel > studentLevel) {
                Locked(LevelLocked);
              } else {


                if (target |> Target.isMilestone) {
                 let lastLevel = target |> Target.levelNumber -1;
                 let milestoneTargetsFromLastLevel = target |> List.filter(t => t |> Target.isMilestone && t.levelNumber == lastLevel);
                }

                if (target
                         |> Target.isMilestone
                         && targets
                         |> List.filter(t =>
                              t
                              |> Target.levelNumber
                              == (target |> Target.levelNumber - 1)
                            )
                         |> targetsNotPassed(submissions)) {
                Locked(PreviousLevelMilestonesIncomplete);
              } else if (target
                         |> Target.prerequisiteTargetIds
                         |> targetsNotPassed(submissions)) {
                Locked(PrerequisitesIncomplete);
              } else {
                Pending;
              };
            };

          {targetId, status};
        });
   };
 */

[@react.component]
let make =
    (
      ~authenticityToken,
      ~schoolName,
      ~course,
      ~levels,
      ~targetGroups,
      ~targets,
      ~submissions,
      ~team,
      ~students,
      ~coaches,
      ~userProfiles,
      ~currentUserId,
      ~locked,
    ) => {
  let statusOfTargets =
    computeStatusOfTargets(locked, students, levels, targets, submissions);
  Js.log2(authenticityToken, schoolName);
  <div> {"Boo!" |> React.string} </div>;
};