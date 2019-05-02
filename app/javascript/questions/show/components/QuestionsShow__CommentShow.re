[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

[@react.component]
let make =
    (
      ~comments,
      ~userData,
      ~authenticityToken,
      ~commentableType,
      ~commentableId,
      ~addCommentCB,
      ~currentUserId,
    ) => {
  let (showMore, setShowMore) = React.useState(() => false);
  <div
    className="md:w-1/3 w-full flex flex-col mx-auto items-center justify-center">
    {
      comments
      |> List.mapi((index, comment) =>
           index < (showMore ? comments |> List.length : 3) ?
             <div
               key={comment |> Comment.id}
               className="w-full text-left border border-t-0">
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
      comments
      |> List.length > 3
      && showMore
      || comments
      |> List.length < 3
      && !showMore ?
        <QuestionsShow__AddComment
          authenticityToken
          commentableType
          commentableId
          addCommentCB
          currentUserId
        /> :
        ReasonReact.null
    }
    {
      comments |> List.length > 3 && !showMore ?
        <a
          onClick={_ => setShowMore(_ => !showMore)}
          className="bg-primary-lighter rounded-lg py-1 px-1flex mx-auto appearance-none text-xs">
          {(showMore ? "Show Less" : "Show More") |> str}
        </a> :
        ReasonReact.null
    }
  </div>;
};