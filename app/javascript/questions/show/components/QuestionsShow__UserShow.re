[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

[@react.component]
let make = (~userProfile, ~createdAt) =>
  <div>
    <p className="text-xs"> {"answered on by" ++ createdAt |> str} </p>
    <div className="py-2 flex flex-row">
      <div
        className="w-10 h-10 rounded-full bg-grey text-white flex items-center justify-center overflow-hidden">
        <img src={userProfile |> UserData.avatarUrl} />
      </div>
      <div className="pl-2">
        <p className="font-semibold">
          {userProfile |> UserData.name |> str}
        </p>
        <p className="text-xs"> {userProfile |> UserData.title |> str} </p>
      </div>
    </div>
  </div>;