open CourseCoaches__Types;

let str = React.string;

type state = {
  teams: array(Team.t),
  loading: bool,
};

type action =
  | SaveTeamsData(array(Team.t))
  | RemoveTeam(string);

let reducer = (state, action) => {
  switch (action) {
  | SaveTeamsData(teams) => {teams, loading: false}
  | RemoveTeam(id) => {
      ...state,
      teams: state.teams |> Js.Array.filter(team => Team.id(team) != id),
    }
  };
};

module CoachTeamsQuery = [%graphql
  {|
    query($courseId: ID!, $coachId: ID) {
      teams(courseId: $courseId, coachId: $coachId, first: 100) {
        nodes {
          id,
          name,
          students {
            name
          }
        }
      }
    }
  |}
];

let loadCoachTeams = (courseId, coachId, send) => {
  CoachTeamsQuery.make(~courseId, ~coachId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
       let coachTeams =
         switch (result##teams##nodes) {
         | None => [||]
         | Some(teams) => teams |> Team.makeArrayFromJs
         };
       send(SaveTeamsData(coachTeams));
       Js.Promise.resolve();
     })
  |> ignore;
};

let removeTeamEnrollment = (send, teamId) => {
  send(RemoveTeam(teamId));
};

[@react.component]
let make = (~courseId, ~coach) => {
  let (state, send) =
    React.useReducer(reducer, {teams: [||], loading: true});

  React.useEffect1(
    () => {
      loadCoachTeams(courseId, coach |> CourseCoach.id, send);
      None;
    },
    [|courseId|],
  );
  <div className="mx-auto">
    <div className="py-6 border-b border-gray-400 bg-gray-100">
      <div className="max-w-2xl mx-auto">
        <div className="flex">
          {switch (coach |> CourseCoach.avatarUrl) {
           | Some(avatarUrl) =>
             <img className="w-12 h-12 rounded-full mr-4" src=avatarUrl />
           | None =>
             <Avatar
               name={coach |> CourseCoach.name}
               className="w-12 h-12 mr-4"
             />
           }}
          <div className="text-sm flex flex-col justify-center">
            <div className="text-black font-bold inline-block">
              {coach |> CourseCoach.name |> str}
            </div>
            <div className="text-gray-600 inline-block">
              {coach |> CourseCoach.email |> str}
            </div>
          </div>
        </div>
      </div>
    </div>
    <div className="max-w-2xl mx-auto">
      <span className="inline-block mr-1 mb-2 text-sm font-semibold pt-5">
        {"Students assigned to coach:" |> str}
      </span>
      {state.loading
         ? <div className="max-w-2xl mx-auto p-3">
             {SkeletonLoading.multiple(
                ~count=2,
                ~element=SkeletonLoading.paragraph(),
              )}
           </div>
         : {
           state.teams |> ArrayUtils.isEmpty
             ? <div
                 className="border border-gray-400 rounded italic text-gray-600 text-xs cursor-default mt-2 p-3">
                 {"There are no students assigned to this coach. You can assign coaches directly while editing the student details."
                  |> str}
               </div>
             : state.teams
               |> Array.map(team =>
                    <CourseCoaches__InfoFormTeam
                      key={Team.id(team)}
                      team
                      coach
                      removeTeamEnrollmentCB={removeTeamEnrollment(send)}
                    />
                  )
               |> React.array;
         }}
    </div>
  </div>;
};
