open CoachesCourseIndex__Types;

let str = React.string;

let deleteIconClasses = deleting =>
  deleting ? "fas fa-spinner fa-pulse" : "far fa-trash-alt";

module DeleteCoachTeamEnrollmentQuery = [%graphql
  {|
  mutation($teamId: ID!, $coachId: ID!) {
    deleteCoachTeamEnrollment(teamId: $teamId, coachId: $coachId) {
      success
    }
  }
|}
];

let deleteTeamEnrollment =
    (team, coach, setDeleting, removeTeamEnrollmentCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  if (Webapi.Dom.(
        window
        |> Window.confirm(
             "Are you sure you want to remove "
             ++ (team |> CoachesCourseIndex__Team.name)
             ++ " from the list of assigned teams?",
           )
      )) {
    setDeleting(_ => true);
    DeleteCoachTeamEnrollmentQuery.make(
      ~teamId=CoachesCourseIndex__Team.id(team),
      ~coachId=Coach.id(coach),
      (),
    )
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(response => {
         if (response##deleteCoachTeamEnrollment##success) {
           setDeleting(_ => false);
           removeTeamEnrollmentCB(CoachesCourseIndex__Team.id(team));
         } else {
           setDeleting(_ => false);
         };
         response |> Js.Promise.resolve;
       })
    |> ignore;
  };
};

[@react.component]
let make = (~team, ~coach, ~removeTeamEnrollmentCB) => {
  let (deleting, setDeleting) = React.useState(() => false);
  <div
    className="flex items-center justify-between bg-gray-100 text-xs text-gray-900 border rounded pl-3 mt-2"
    key={team |> Team.id}>
    <span> {team |> Team.name |> str} </span>
    <button
      title={"Delete " ++ Team.name(team)}
      onClick={deleteTeamEnrollment(
        team,
        coach,
        setDeleting,
        removeTeamEnrollmentCB,
      )}
      className="p-3">
      <FaIcon classes={deleteIconClasses(deleting)} />
    </button>
  </div>;
};
