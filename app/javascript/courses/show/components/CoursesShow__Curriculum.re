[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesShow__Curriculum.css")|}];

let levelLockedImage: string = [%raw "require('../images/level-lock.svg')"];

open CourseShow__Types;
module TargetStatus = CourseShow__TargetStatus;

let str = React.string;

let closeOverlay = (setSelectedTargetId, ()) => {
  setSelectedTargetId(_ => None);
  ();
};

let changeSelectedtarget = (setSelectedTargetId, target) => {
  setSelectedTargetId(_ => Some(target |> Target.id));
  ();
};

let targetStatusClasses = targetStatus => {
  let statusClasses =
    "curriculum__target-status--"
    ++ (targetStatus |> TargetStatus.statusToString |> Js.String.toLowerCase);
  "curriculum__target-status px-3 py-px ml-4 h-6 " ++ statusClasses;
};

let rendertarget = (target, setSelectedTargetId, statusOfTargets) => {
  let targetId = target |> Target.id;
  let targetStatus =
    statusOfTargets |> List.find(ts => ts |> TargetStatus.targetId == targetId);

  <div
    key={"target-" ++ targetId}
    className="bg-white border-t p-6 flex items-center justify-between hover:bg-gray-200 hover:text-primary-500 "
    onClick={_e => setSelectedTargetId(_ => Some(targetId))}>
    <span className="font-semibold text-left leading-snug">
      {target |> Target.title |> str}
    </span>
    <span className={targetStatusClasses(targetStatus)}>
      {targetStatus |> TargetStatus.statusToString |> str}
    </span>
  </div>;
};

let renderTargetGroup =
    (targetGroup, targets, statusOfTargets, setSelectedTargetId) => {
  let targetGroupId = targetGroup |> TargetGroup.id;
  let targets =
    targets |> List.filter(t => t |> Target.targetGroupId == targetGroupId);

  <div
    key={"target-group" ++ targetGroupId}
    className="curriculum__target-group-container relative mt-8 px-3">
    <div
      className="curriculum__target-group max-w-3xl mx-auto bg-white text-center rounded-lg shadow-md relative z-10 overflow-hidden ">
      <div className="p-6">
        <div className="text-2xl font-bold">
          {targetGroup |> TargetGroup.name |> str}
        </div>
        <div className="text-sm">
          {targetGroup |> TargetGroup.description |> str}
        </div>
      </div>
      {
        targets
        |> List.sort((t1, t2) =>
             (t1 |> Target.sortIndex) - (t2 |> Target.sortIndex)
           )
        |> List.map(target =>
             rendertarget(target, setSelectedTargetId, statusOfTargets)
           )
        |> Array.of_list
        |> React.array
      }
    </div>
  </div>;
};

let addSubmission = (setStatusOfTargets, targetStatus) =>
  setStatusOfTargets(statusOfTargets =>
    statusOfTargets
    |> List.map(ts =>
         ts |> TargetStatus.targetId == (targetStatus |> TargetStatus.targetId) ?
           targetStatus : ts
       )
  );

let handleLockedLevel = level =>
  <div className="max-w-xl mx-auto text-center mt-4">
    <div className="font-semibold text-2xl"> {"Level Locked" |> str} </div>
    <img src=levelLockedImage />
    {
      switch (level |> Level.unlockOn) {
      | Some(date) =>
        <div className="font-semibold text-md">
          {
            "The level is currently locked, You can access the content on "
            ++ (date |> DateTime.stingToFormatedTime(DateTime.OnlyDate))
            |> str
          }
        </div>
      | None => React.null
      }
    }
  </div>;

let handleLevelUp =
    (targetGroupsInLevel, targets, statusOfTargets, course, authenticityToken) => {
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
  statusOfMilestoneTargets |> TargetStatus.canLevelUp ?
    <CourseShow__LevelUp course authenticityToken /> : React.null;
};

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
      ~selectedTargetId,
      ~evaluationCriteria,
    ) => {
  let teamLevel =
    levels |> List.find(l => l |> Level.id == (team |> Team.levelId));

  let (selectedLevelId, setSelectedLevelId) =
    React.useState(() => teamLevel |> Level.id);
  let (statusOfTargets, setStatusOfTargets) =
    React.useState(() =>
      TargetStatus.compute(
        team,
        students,
        course,
        levels,
        targetGroups,
        targets,
        submissions,
      )
    );

  let (selectedTargetId, setSelectedTargetId) =
    React.useState(() => selectedTargetId);
  let (showLevelZero, setShowLevelZero) = React.useState(() => false);
  let levelZero = levels |> ListUtils.findOpt(l => l |> Level.number == 0);
  let currentLevelId =
    switch (levelZero, showLevelZero) {
    | (Some(levelZero), true) => levelZero |> Level.id
    | (Some(_), false)
    | (None, true | false) => selectedLevelId
    };
  let currentLevel =
    levels |> ListUtils.findOpt(l => l |> Level.id == currentLevelId);

  let targetGroupsInLevel =
    targetGroups
    |> List.filter(tg => tg |> TargetGroup.levelId == currentLevelId);

  <div className="bg-gray-100 pt-4 pb-8">
    {
      switch (selectedTargetId) {
      | Some(targetId) =>
        let selectedTarget =
          targets |> ListUtils.findOpt(t => t |> Target.id == targetId);
        switch (selectedTarget) {
        | Some(target) =>
          let targetStatus =
            statusOfTargets
            |> List.find(ts =>
                 ts |> TargetStatus.targetId == (target |> Target.id)
               );

          <CourseShow__Overlay
            target
            course
            targetStatus
            closeOverlayCB={closeOverlay(setSelectedTargetId)}
            authenticityToken
            addSubmissionCB={addSubmission(setStatusOfTargets)}
            targets
            statusOfTargets
            changeTargetCB={changeSelectedtarget(setSelectedTargetId)}
            userProfiles
            evaluationCriteria
          />;
        | None => React.null
        };

      | None => React.null
      }
    }
    {
      handleLevelUp(
        targetGroupsInLevel,
        targets,
        statusOfTargets,
        course,
        authenticityToken,
      )
    }
    <CourseShow__LevelSelector
      levels
      selectedLevelId
      setSelectedLevelId
      showLevelZero
      setShowLevelZero
      levelZero
    />
    {
      switch (currentLevel) {
      | Some(level) =>
        level |> Level.isLocked ?
          handleLockedLevel(level) :
          targetGroupsInLevel
          |> TargetGroup.sort
          |> List.map(targetGroup =>
               renderTargetGroup(
                 targetGroup,
                 targets,
                 statusOfTargets,
                 setSelectedTargetId,
               )
             )
          |> Array.of_list
          |> React.array
      | None => React.null
      }
    }
  </div>;
};