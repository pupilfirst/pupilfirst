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

  <div>
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
          />;
        | None => React.null
        };

      | None => React.null
      }
    }
    <div className="flex justify-center">
      <select
        className="p-2 border rounded-lg"
        onChange={updateSelectedLevel(levels, setSelectedLevelId)}
        value=selectedLevelId>
        {
          levels
          |> List.filter(l => l |> Level.number != 0)
          |> List.sort((l1, l2) =>
               (l1 |> Level.number) - (l2 |> Level.number)
             )
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
      </select>
      {
        let levelZero =
          levels |> ListUtils.findOpt(l => l |> Level.number == 0);
        switch (levelZero) {
        | Some(level) =>
          <button
            className="p-2 border rounded-lg ml-2"
            onClick=(_e => setSelectedLevelId(_ => level |> Level.id))>
            {level |> Level.name |> str}
          </button>
        | None => React.null
        };
      }
    </div>
    {
      targetGroups
      |> List.filter(tg => tg |> TargetGroup.levelId == selectedLevelId)
      |> List.sort((tg1, tg2) =>
           (tg1 |> TargetGroup.sortIndex) - (tg2 |> TargetGroup.sortIndex)
         )
      |> List.map(targetGroup => {
           let targetGroupId = targetGroup |> TargetGroup.id;
           let targets =
             targets
             |> List.filter(t => t |> Target.targetGroupId == targetGroupId);

           <div key=targetGroupId className="border-red p-2 w-1/2 mx-auto">
             <div> {targetGroup |> TargetGroup.name |> str} </div>
             {
               targets
               |> List.sort((t1, t2) =>
                    (t1 |> Target.sortIndex) - (t2 |> Target.sortIndex)
                  )
               |> List.map(target => {
                    let targetStatus =
                      statusOfTargets
                      |> List.find(ts =>
                           ts |> TargetStatus.targetId == (target |> Target.id)
                         );

                    <div
                      key={target |> Target.id}
                      className="border p-2 cursor-pointer"
                      onClick={
                        _e =>
                          setSelectedTargetId(_ => Some(target |> Target.id))
                      }>
                      <span> {target |> Target.title |> str} </span>
                      <span className="ml-4 font-bold">
                        {targetStatus |> TargetStatus.statusToString |> str}
                      </span>
                    </div>;
                  })
               |> Array.of_list
               |> React.array
             }
           </div>;
         })
      |> Array.of_list
      |> React.array
    }
  </div>;
};