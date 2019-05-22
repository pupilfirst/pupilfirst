[@bs.config {jsx: 3}];

module TargetStatus = CourseShow__TargetStatus;

open CourseShow__Types;

let str = React.string;

let changeLevel = (levels, setSelectedLevel, event) => {
  let level =
    levels
    |> ListUtils.findOpt(l =>
         l |> Level.id == ReactEvent.Form.target(event)##value
       );

  switch (level) {
  | Some(level) => setSelectedLevel(_ => level)
  | None => ()
  };
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
  let (selectedLevel, setSelectedLevel) = React.useState(() => teamLevel);
  let (latestSubmissions, setLatestSubmissions) =
    React.useState(() => submissions);

  let statusOfTargets =
    TargetStatus.compute(
      team,
      students,
      course,
      levels,
      targetGroups,
      targets,
      latestSubmissions,
    );

  statusOfTargets
  |> List.iter(ts => {
       let target =
         targets
         |> List.find(t => t |> Target.id == (ts |> TargetStatus.targetId));
       Js.log2(target |> Target.title, ts |> TargetStatus.statusToString);
     });

  <div>
    <select
      className="p-2 border rounded-lg"
      onChange={changeLevel(levels, setSelectedLevel)}>
      {
        levels
        |> List.filter(l => l |> Level.number != 0)
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
      let levelZero = levels |> ListUtils.findOpt(l => l |> Level.number == 0);
      switch (levelZero) {
      | Some(level) =>
        <button
          className="p-2 border rounded-lg ml-2"
          onClick=(_e => setSelectedLevel(_ => level))>
          {level |> Level.name |> str}
        </button>
      | None => React.null
      };
    }
    {
      targetGroups
      |> List.filter(tg =>
           tg |> TargetGroup.levelId == (selectedLevel |> Level.id)
         )
      |> List.sort((tg1, tg2) =>
           (tg1 |> TargetGroup.sortIndex) - (tg2 |> TargetGroup.sortIndex)
         )
      |> List.map(targetGroup => {
           let targetGroupId = targetGroup |> TargetGroup.id;
           let targets =
             targets
             |> List.filter(t => t |> Target.targetGroupId == targetGroupId);

           <div key=targetGroupId className="border-red p-2">
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

                    <div className="border p-2">
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