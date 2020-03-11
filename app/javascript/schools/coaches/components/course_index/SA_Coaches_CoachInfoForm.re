open CoachesCourseIndex__Types;

let str = React.string;

[@react.component]
let make = (~coach, ~removeTeamEnrollmentCB) => {
  <div className="mx-auto">
    <div className="py-6 border-b border-gray-400 bg-gray-100">
      <div className="max-w-2xl mx-auto">
        <div className="flex">
          {switch (coach |> Coach.avatarUrl) {
           | Some(avatarUrl) =>
             <img className="w-12 h-12 rounded-full mr-4" src=avatarUrl />
           | None =>
             <Avatar name={coach |> Coach.name} className="w-12 h-12 mr-4" />
           }}
          <div className="text-sm flex flex-col justify-center">
            <div className="text-black font-bold inline-block">
              {coach |> Coach.name |> str}
            </div>
            <div className="text-gray-600 inline-block">
              {coach |> Coach.email |> str}
            </div>
          </div>
        </div>
      </div>
    </div>
    <div className="max-w-2xl mx-auto">
      <span className="inline-block mr-1 mb-2 text-sm font-semibold pt-5">
        {"Teams assigned to coach:" |> str}
      </span>
      {switch (coach |> Coach.teams) {
       | [||] =>
         <div
           className="border border-gray-400 rounded italic text-gray-600 text-xs cursor-default mt-2 p-3">
           {"There are no teams assigned to this coach. Assign them from the students editor."
            |> str}
         </div>
       | teams =>
         teams
         |> Array.map(team =>
              <SA_Coaches_CoachInfoFormTeam
                key={CoachesCourseIndex__Team.id(team)}
                team
                coach
                removeTeamEnrollmentCB
              />
            )
         |> React.array
       }}
    </div>
  </div>;
};
