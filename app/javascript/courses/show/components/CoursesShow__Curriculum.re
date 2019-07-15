[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesShow__Curriculum.css")|}];

let levelLockedImage: string = [%raw "require('../images/level-lock.svg')"];

open CourseShow__Types;

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
    className="curriculum__target-group-container relative mt-8 px-3">
    <div
      className="curriculum__target-group max-w-3xl mx-auto bg-white text-center rounded-lg shadow-md relative z-10 overflow-hidden ">
      {
        targetGroup |> TargetGroup.milestone ?
          <div
            className="inline-block px-3 py-2 bg-orange-400 font-bold text-sm rounded-b-lg leading-tight text-white uppercase">
            {"Milestone targets" |> str}
          </div> :
          React.null
      }
      <div className="p-6 pt-5">
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
        |> List.map(target => rendertarget(target, statusOfTargets))
        |> Array.of_list
        |> React.array
      }
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
    {
      switch (level |> Level.unlockOn) {
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
      }
    }
  </div>;

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
    ) => {
  let teamLevel =
    levels
    |> ListUtils.unsafeFind(
         l => l |> Level.id == (team |> Team.levelId),
         "Could not find teamLevel with ID " ++ (team |> Team.levelId),
       );

  let (selectedLevelId, setSelectedLevelId) =
    React.useState(() => teamLevel |> Level.id);

  let (latestSubmissions, setLatestSubmissions) =
    React.useState(() => submissions);

  /* Curried function so that this can be re-used when a new submission is created. */
  let computeTargetStatus =
    TargetStatus.compute(team, course, levels, targetGroups, targets);

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

  let (showLevelZero, setShowLevelZero) = React.useState(() => false);
  let levelZero = levels |> ListUtils.findOpt(l => l |> Level.number == 0);
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

  let targetGroupsInLevel =
    targetGroups
    |> List.filter(tg => tg |> TargetGroup.levelId == currentLevelId);

  let url = ReasonReactRouter.useUrl();

  <div className="bg-gray-100 pt-4 pb-8">
    {
      switch (url.path) {
      | ["targets", targetId, ..._] =>
        let selectedTarget =
          targets
          |> ListUtils.unsafeFind(
               t => t |> Target.id == targetId,
               "Could not find selectedTarget with ID " ++ targetId,
             );

        let targetStatus =
          statusOfTargets
          |> ListUtils.unsafeFind(
               ts =>
                 ts |> TargetStatus.targetId == (selectedTarget |> Target.id),
               "Could not find targetStatus for selectedTarget with ID "
               ++ (selectedTarget |> Target.id),
             );

        <CourseShow__Overlay
          target=selectedTarget
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
        />;

      | _ => React.null
      }
    }
    <CourseShow__NoticeManager
      levels
      teamLevel
      targetGroups
      targets
      statusOfTargets
      course
      team
      authenticityToken
    />
    <div className="px-3">
      <CourseShow__LevelSelector
        levels
        selectedLevelId
        setSelectedLevelId
        showLevelZero
        setShowLevelZero
        levelZero
      />
    </div>
    {
      currentLevel |> Level.isLocked ?
        handleLockedLevel(currentLevel) :
        targetGroupsInLevel
        |> TargetGroup.sort
        |> List.map(targetGroup =>
             renderTargetGroup(targetGroup, targets, statusOfTargets)
           )
        |> Array.of_list
        |> React.array
    }
  </div>;
};
