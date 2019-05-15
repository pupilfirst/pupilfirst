[@bs.config {jsx: 3}];
[@react.component]
let make =
    (
      ~authenticityToken,
      ~schoolName,
      ~courses,
      ~levels,
      ~targetGroups,
      ~targets,
      ~submissions,
      ~team,
      ~students,
      ~coaches,
      ~userProfiles,
    ) => {
  Js.log2(authenticityToken, schoolName);
  <div> {"Boo!" |> React.string} </div>;
};