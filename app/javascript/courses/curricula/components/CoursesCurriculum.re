[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesCurriculum.css")|}];

let levelLockedImage: string = [%raw "require('../images/level-lock.svg')"];

open CoursesCurriculum__Types;

let str = React.string;

let selectTarget = target =>
  ReasonReactRouter.push("/targets/" ++ (target |> Target.id));

let targetStatusClasses = targetStatus => {
  let statusClasses =
    "curriculum__target-status--"
    ++ (targetStatus |> TargetStatus.statusToString |> Js.String.toLowerCase);
  "curriculum__target-status px-3 py-px ml-4 h-6 " ++ statusClasses;
};

let rendertarget = (target, statusOfTargets) => {
  let targetId = target |> Target.id;
  let targetStatus =
    statusOfTargets
    |> ListUtils.unsafeFind(
         ts => ts |> TargetStatus.targetId == targetId,
         "Could not find targetStatus for listed target with ID " ++ targetId,
       );

  <div
    key={"target-" ++ targetId}
    className="bg-white border-t p-6 flex items-center justify-between hover:bg-gray-200 hover:text-primary-500 cursor-pointer"
    ariaLabel={"Select Target " ++ targetId}
    onClick={_e => selectTarget(target)}>
    <span className="font-semibold text-left leading-snug">
      {target |> Target.title |> str}
    </span>
    <span className={targetStatusClasses(targetStatus)}>
      {targetStatus |> TargetStatus.statusToString |> str}
    </span>
  </div>;
};

let renderTargetGroup = (targetGroup, targets, statusOfTargets) => {
  let targetGroupId = targetGroup |> TargetGroup.id;
  let targets =
    targets |> List.filter(t => t |> Target.targetGroupId == targetGroupId);

  <div
    key={"target-group-" ++ targetGroupId}
    className="curriculum__target-group-container relative mt-5 px-3">
    <div
      className="curriculum__target-group max-w-3xl mx-auto bg-white text-center rounded-lg shadow-md relative z-10 overflow-hidden ">
      {targetGroup |> TargetGroup.milestone
         ? <div
             className="inline-block px-3 py-2 bg-orange-400 font-bold text-xs rounded-b-lg leading-tight text-white uppercase">
             {"Milestone targets" |> str}
           </div>
         : React.null}
      <div className="p-6 pt-5">
        <div className="text-2xl font-bold leading-snug">
          {targetGroup |> TargetGroup.name |> str}
        </div>
        <div className="text-sm max-w-md mx-auto leading-snug mt-1">
          {targetGroup |> TargetGroup.description |> str}
        </div>
      </div>
      {targets
       |> List.sort((t1, t2) =>
            (t1 |> Target.sortIndex) - (t2 |> Target.sortIndex)
          )
       |> List.map(target => rendertarget(target, statusOfTargets))
       |> Array.of_list
       |> React.array}
    </div>
  </div>;
};

let addSubmission = (setLatestSubmissions, latestSubmission) =>
  setLatestSubmissions(submissions => {
    let withoutSubmissionForThisTarget =
      submissions
      |> List.filter(s =>
           s
           |> LatestSubmission.targetId
           != (latestSubmission |> LatestSubmission.targetId)
         );
    [latestSubmission, ...withoutSubmissionForThisTarget];
  });

let handleLockedLevel = level =>
  <div className="max-w-xl mx-auto text-center mt-4">
    <div className="font-semibold text-2xl font-bold px-3">
      {"Level Locked" |> str}
    </div>
    <img className="max-w-sm mx-auto" src=levelLockedImage />
    {switch (level |> Level.unlockOn) {
     | Some(date) =>
       let dateString =
         date |> DateFns.parseString |> DateFns.format("MMMM D, YYYY");
       <div className="font-semibold text-md px-3">
         <p> {"The level is currently locked!" |> str} </p>
         <p>
           {"You can access the content on " ++ dateString ++ "." |> str}
         </p>
       </div>;
     | None => React.null
     }}
  </div>;

let computeLevelUp =
    (levels, teamLevel, targetGroups, targets, statusOfTargets) => {
  let targetGroupsInLevel =
    targetGroups
    |> List.filter(tg => tg |> TargetGroup.levelId == (teamLevel |> Level.id));
  let milestoneTargetGroupIds =
    targetGroupsInLevel
    |> List.filter(tg => tg |> TargetGroup.milestone)
    |> List.map(tg => tg |> TargetGroup.id);

  let milestoneTargetIds =
    targets
    |> List.filter(t =>
         (t |> Target.targetGroupId)->List.mem(milestoneTargetGroupIds)
       )
    |> List.map(t => t |> Target.id);

  let statusOfMilestoneTargets =
    statusOfTargets
    |> List.filter(ts =>
         (ts |> TargetStatus.targetId)->List.mem(milestoneTargetIds)
       );

  let nextLevelNumber = (teamLevel |> Level.number) + 1;

  let nextLevel =
    levels |> ListUtils.findOpt(l => l |> Level.number == nextLevelNumber);

  let canLevelUp =
    statusOfMilestoneTargets
    |> ListUtils.isNotEmpty
    && statusOfMilestoneTargets
    |> TargetStatus.canLevelUp;

  switch (nextLevel, canLevelUp) {
  | (Some(level), true) => level |> Level.isLocked ? Notice.Nothing : LevelUp
  | (None, true) => CourseComplete
  | (Some(_) | None, false) => Nothing
  };
};

let computeNotice =
    (
      levels,
      teamLevel,
      targetGroups,
      targets,
      statusOfTargets,
      course,
      team,
      preview,
    ) =>
  switch (preview, course |> Course.hasEnded, team |> Team.accessEnded) {
  | (true, _, _) => Notice.Preview
  | (false, true, true | false) => CourseEnded
  | (false, false, true) => AccessEnded
  | (false, false, false) =>
    computeLevelUp(levels, teamLevel, targetGroups, targets, statusOfTargets)
  };

[@react.component]
let make =
    (
      ~authenticityToken,
      ~course,
      ~levels,
      ~targetGroups,
      ~targets,
      ~submissions,
      ~team,
      ~coaches,
      ~users,
      ~evaluationCriteria,
      ~preview,
    ) => {
  let url = ReasonReactRouter.useUrl();

  let selectedTarget =
    switch (url.path) {
    | ["targets", targetId, ..._] =>
      Some(
        targets
        |> ListUtils.unsafeFind(
             t => t |> Target.id == targetId,
             "Could not find selectedTarget with ID " ++ targetId,
           ),
      )
    | _ => None
    };

  /* Level selection is a bit complicated because of how the selector for L0 is
   * separate from the other levels. selectedLevelId is the numbered level
   * selected by the user, whereas showLevelZero is the toggle on the title of
   * L0 determining whether the user has picked it or not - it'll show up only
   * if L0 is available, and will override the selectedLevelId. This rule is
   * used to determine currentLevelId, which is the actual level whose contents
   * are shown on the page. */

  let levelZero = levels |> ListUtils.findOpt(l => l |> Level.number == 0);
  let teamLevelId = team |> Team.levelId;

  let teamLevel =
    levels
    |> ListUtils.unsafeFind(
         l => l |> Level.id == teamLevelId,
         "Could not find teamLevel with ID " ++ teamLevelId,
       );

  let targetLevelId =
    switch (selectedTarget) {
    | Some(target) =>
      let targetGroupId = target |> Target.targetGroupId;

      let targetGroup =
        targetGroups
        |> ListUtils.unsafeFind(
             t => t |> TargetGroup.id == targetGroupId,
             "Could not find targetGroup with ID " ++ targetGroupId,
           );

      Some(targetGroup |> TargetGroup.levelId);
    | None => None
    };

  let (selectedLevelId, setSelectedLevelId) =
    React.useState(() =>
      switch (targetLevelId, levelZero) {
      | (Some(targetLevelId), Some(levelZero)) =>
        levelZero |> Level.id == targetLevelId ? teamLevelId : targetLevelId
      | (Some(targetLevelId), None) => targetLevelId
      | (None, _) => teamLevelId
      }
    );

  let (showLevelZero, setShowLevelZero) =
    React.useState(() =>
      switch (levelZero, targetLevelId) {
      | (Some(levelZero), Some(targetLevelId)) =>
        levelZero |> Level.id == targetLevelId
      | (Some(_), None)
      | (None, Some(_))
      | (None, None) => false
      }
    );

  let currentLevelId =
    switch (levelZero, showLevelZero) {
    | (Some(levelZero), true) => levelZero |> Level.id
    | (Some(_), false)
    | (None, true | false) => selectedLevelId
    };

  let currentLevel =
    levels
    |> ListUtils.unsafeFind(
         l => l |> Level.id == currentLevelId,
         "Could not find currentLevel with id " ++ currentLevelId,
       );

  let (latestSubmissions, setLatestSubmissions) =
    React.useState(() => submissions);

  /* Curried function so that this can be re-used when a new submission is created. */
  let computeTargetStatus =
    TargetStatus.compute(
      preview,
      team,
      course,
      levels,
      targetGroups,
      targets,
    );

  let initialRender = React.useRef(true);

  let (statusOfTargets, setStatusOfTargets) =
    React.useState(() => computeTargetStatus(latestSubmissions));

  React.useEffect1(
    () => {
      if (initialRender |> React.Ref.current) {
        initialRender->React.Ref.setCurrent(false);
      } else {
        setStatusOfTargets(_ => computeTargetStatus(latestSubmissions));
      };
      None;
    },
    [|latestSubmissions|],
  );

  let targetGroupsInLevel =
    targetGroups
    |> List.filter(tg => tg |> TargetGroup.levelId == currentLevelId);

  let notice =
    computeNotice(
      levels,
      teamLevel,
      targetGroups,
      targets,
      statusOfTargets,
      course,
      team,
      preview,
    );

  <div className="bg-gray-100 pt-11 pb-8 -mt-7">
    {switch (selectedTarget) {
     | Some(target) =>
       let targetStatus =
         statusOfTargets
         |> ListUtils.unsafeFind(
              ts => ts |> TargetStatus.targetId == (target |> Target.id),
              "Could not find targetStatus for selectedTarget with ID "
              ++ (target |> Target.id),
            );

       <CoursesCurriculum__Overlay
         target
         course
         targetStatus
         authenticityToken
         addSubmissionCB={addSubmission(setLatestSubmissions)}
         targets
         statusOfTargets
         changeTargetCB=selectTarget
         users
         evaluationCriteria
         coaches
         preview
       />;

     | None => React.null
     }}
    <CoursesCurriculum__NoticeManager notice course authenticityToken />
    {switch (notice) {
     | LevelUp => React.null
     | _anyOtherNotice =>
       <div>
         <div className="px-3">
           <CoursesCurriculum__LevelSelector
             levels
             selectedLevelId
             setSelectedLevelId
             showLevelZero
             setShowLevelZero
             levelZero
           />
         </div>
         {currentLevel |> Level.isLocked
            ? handleLockedLevel(currentLevel)
            : targetGroupsInLevel
              |> TargetGroup.sort
              |> List.map(targetGroup =>
                   renderTargetGroup(targetGroup, targets, statusOfTargets)
                 )
              |> Array.of_list
              |> React.array}
       </div>
     }}
  </div>;
};
