[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

[@react.component]
let make = (~comments, ~userData) => {
  let (showMore, setShowMore) = React.useState(() => false);
  let (newComment, setNewComment) = React.useState(() => "");
  <div
    className="md:w-1/3 w-full flex flex-col mx-auto items-center justify-center">
    {
      comments
      |> List.mapi((index, comment) =>
           index < (showMore ? comments |> List.length : 3) ?
             <div className="w-full text-left border border-t-0">
               <div className="w-full px-6 py-1 leading-normal text-xs">
                 <span> {comment |> Comment.value |> str} </span>
                 <span className="font-semibold">
                   {
                     " - "
                     ++ (
                       userData
                       |> UserData.userName(comment |> Comment.userId)
                     )
                     |> str
                   }
                 </span>
               </div>
             </div> :
             ReasonReact.null
         )
      |> Array.of_list
      |> ReasonReact.array
    }
    {
      comments |> List.length > 3 ?
        <a
          onClick={_ => setShowMore(_ => !showMore)}
          className="bg-primary-lighter rounded-lg py-1 px-1flex mx-auto appearance-none text-xs">
          {(showMore ? "Show Less" : "Show More") |> str}
        </a> :
        ReasonReact.null
    }
    <div className="w-full">
      <div className="flex flex-row">
        <input
          placeholder="Add your comment"
          onChange={
            event => setNewComment(ReactEvent.Form.target(event)##value)
          }
          className="w-3/5 text-left border appearance-none block w-full leading-tight focus:outline-none focus:bg-white focus:border-grey"
        />
        {
          newComment |> Js.String.length > 20 ?
            <button
              className="w-2/5 border-2 border-primary-lighter py-1 px-3 flex mx-auto appearance-none text-center">
              {"Comment" |> str}
            </button> :
            ReasonReact.null
        }
      </div>
    </div>
  </div>;
};