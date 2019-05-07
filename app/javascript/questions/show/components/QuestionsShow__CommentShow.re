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
  <ul
    className="list-reset max-w-lg w-full flex flex-col mx-auto items-center justify-center px-5 md:px-8">
    {
      comments
      |> List.mapi((index, comment) =>
           index < (showMore ? comments |> List.length : 3) ?
             <li
               key={comment |> Comment.id}
               className="w-full text-left border border-t-0">
               <div
                 className="w-full px-4 py-3 leading-normal text-xs bg-white">
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
             </li> :
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
      |> List.length <= 3
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
          className="bg-grey-lighter rounded-full cursor-pointer border py-1 px-3 flex mx-auto appearance-none text-xs font-semibold hover:bg-primary-lightest hover:text-primary -mt-3">
          {(showMore ? "Show Less" : "Show More") |> str}
        </a> :
        ReasonReact.null
    }
  </ul>;
};