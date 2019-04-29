[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

[@react.component]
let make = (~comment, ~userData) =>
  <div
    className="md:w-1/3 w-full flex mx-auto items-center justify-center text-left border border-t-0">
    <div className="w-full px-6 py-1 leading-normal text-xs">
      <span> {comment |> Comment.value |> str} </span>
      <span className="font-semibold">
        {
          " - "
          ++ (userData |> UserData.userName(comment |> Comment.userId))
          |> str
        }
      </span>
    </div>
  </div>;