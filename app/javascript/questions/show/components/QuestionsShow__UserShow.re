[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

[@react.component]
let make = (~userProfile, ~createdAt) =>
  <div className="p-2 flex flex-row">
    <div className="w-16">
      <img src={userProfile |> UserData.avatarUrl} />
    </div>
    <div className="pl-2">
      <p className="text-xs"> {"answered on by" ++ createdAt |> str} </p>
      <p className="font-semibold"> {userProfile |> UserData.name |> str} </p>
      <p> {userProfile |> UserData.title |> str} </p>
    </div>
  </div>;