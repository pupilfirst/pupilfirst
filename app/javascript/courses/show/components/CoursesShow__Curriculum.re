[@bs.config {jsx: 3}];

module TargetStatus = CourseShow__TargetStatus;

open CourseShow__Types;

let str = React.string;

let updateSelectedLevel = (levels, setSelectedLevelId, event) => {
  let selectedLevelId = ReactEvent.Form.target(event)##value;
  let level =
    levels |> ListUtils.findOpt(l => l |> Level.id == selectedLevelId);

  switch (level) {
  | Some(level) =>
    level |> Level.isLocked ? () : setSelectedLevelId(_ => selectedLevelId)
  | None => ()
  };
};

let closeOverlay = (setSelectedTargetId, ()) =>
  setSelectedTargetId(_ => None);

let rendertarget = (target, setSelectedTargetId, statusOfTargets) => {
  let targetStatus =
    statusOfTargets
    |> List.find(ts => ts |> TargetStatus.targetId == (target |> Target.id));

  <div
    key={target |> Target.id}
    className="hover:bg-gray-200 bg-white border border-b-0 px-5 py-4 flex justify-between"
    onClick={_e => setSelectedTargetId(_ => Some(target |> Target.id))}>
    <span className="font-semibold text-sm">
      {target |> Target.title |> str}
    </span>
    <span className="ml-4 font-bold">
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
    key=targetGroupId
    className="mt-4 w-1/2 mx-auto bg-white text-center rounded-lg border shadow-lg overflow-hidden">
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
  </div>;
};

let levelSelectorClasses = isSelected => {
  let defaultClasses = "w-1/2 p-2 border rounded-lg outline-none bg-white ";
  defaultClasses ++ (isSelected ? "bg-gray-500" : "");
};

let levelSelector = (levels, setSelectedLevelId, selectedLevelId) => {
  let levelZero = levels |> ListUtils.findOpt(l => l |> Level.number == 0);
  let isLevelZero =
    switch (levelZero) {
    | Some(level) => selectedLevelId == (level |> Level.id)
    | None => false
    };

  <div className="flex justify-center max-w-fc mx-auto">
    {
      let orderedLevels =
        levels |> List.filter(l => l |> Level.number != 0) |> Level.sort;
      <select
        className={levelSelectorClasses(!isLevelZero)}
        onChange={updateSelectedLevel(levels, setSelectedLevelId)}
        value=selectedLevelId>
        {
          orderedLevels
          |> List.map(l => {
               let levelTitle =
                 "L"
                 ++ (l |> Level.number |> string_of_int)
                 ++ ": "
                 ++ (l |> Level.name);
               <option value={l |> Level.id} key={l |> Level.id}>
                 {levelTitle |> str}
               </option>;
             })
          |> Array.of_list
          |> React.array
        }
      </select>;
    }
    {
      switch (levelZero) {
      | Some(level) =>
        <button
          className={"btn ml-2 " ++ levelSelectorClasses(isLevelZero)}
          onClick=(_e => setSelectedLevelId(_ => level |> Level.id))>
          {level |> Level.name |> str}
        </button>
      | None => React.null
      }
    }
  </div>;
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
    ) => {
  let teamLevel =
    levels |> List.find(l => l |> Level.id == (team |> Team.levelId));

  let computeStatusOfTargets =
    TargetStatus.compute(
      team,
      students,
      course,
      levels,
      targetGroups,
      targets,
    );

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
  let (selectedTargetId, setSelectedTargetId) = React.useState(() => None);

  <div className="py-4 bg-gray-300">
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
            targetStatus
            closeOverlayCB={closeOverlay(setSelectedTargetId)}
            authenticityToken
          />;
        | None => React.null
        };

      | None => React.null
      }
    }
    {levelSelector(levels, setSelectedLevelId, selectedLevelId)}
    {
      targetGroups
      |> List.filter(tg => tg |> TargetGroup.levelId == selectedLevelId)
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
    }
  </div>;
};