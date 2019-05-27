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
      ~archiveCB,
      ~isCoach,
    ) => {
  let (showMore, setShowMore) = React.useState(() => false);
  let filteredComments =
    comments |> List.filter(comment => !(comment |> Comment.archived));
  <ul
    className="list-reset max-w-3xl w-full flex flex-col mx-auto items-center justify-center px-5 md:px-8">
    {
      filteredComments
      |> List.mapi((index, comment) =>
           index < (showMore ? filteredComments |> List.length : 3) ?
             <li
               key={comment |> Comment.id}
               className="w-full text-left border border-t-0">
               <div
                 className="flex w-full px-4 py-3 leading-normal text-xs bg-white">
                 <span
                   dangerouslySetInnerHTML={
                     "__html": comment |> Comment.value |> Markdown.parse,
                   }
                 />
                 <span className="font-semibold">
                   {
                     " - "
                     ++ (
                       userData
                       |> UserData.userName(comment |> Comment.creatorId)
                     )
                     |> str
                   }
                 </span>
                 {
                   isCoach || comment.creatorId == currentUserId ?
                     <QuestionsShow__ArchiveManager
                       authenticityToken
                       id={comment |> Comment.id}
                       resourceType="Comment"
                       archiveCB
                     /> :
                     React.null
                 }
               </div>
             </li> :
             ReasonReact.null
         )
      |> Array.of_list
      |> ReasonReact.array
    }
    {
      filteredComments
      |> List.length > 3
      && showMore
      || filteredComments
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
      filteredComments |> List.length > 3 && !showMore ?
        <a
          onClick={_ => setShowMore(_ => !showMore)}
          className="bg-gray-200 rounded-full cursor-pointer border py-1 px-3 flex mx-auto appearance-none text-xs font-semibold hover:bg-primary-100 hover:text-primary-500 -mt-3">
          {(showMore ? "Show Less" : "Show More") |> str}
        </a> :
        ReasonReact.null
    }
  </ul>;
};