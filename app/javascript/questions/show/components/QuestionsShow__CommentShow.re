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
  let (showAll, setShowAll) =
    React.useState(() => comments |> List.length <= 3);

  let (commentsToShow, allCommentsShown) =
    switch (showAll, comments |> Comment.sort) {
    | (false, [e1, e2, e3, _e4, ..._rest]) => ([e1, e2, e3], false)
    | (_, comments) => (comments, true)
    };

  <ul
    className="list-reset max-w-3xl w-full flex flex-col mx-auto items-center justify-center px-3 md:px-8">
    {
      commentsToShow
      |> List.map(comment =>
           <li
             key={comment |> Comment.id}
             className="w-full text-left border border-gray-400 border-t-0">
             <div
               className="flex w-full leading-normal text-xs bg-white justify-between">
               <MarkdownBlock
                 markdown={
                   (comment |> Comment.value)
                   ++ " **- "
                   ++ (
                     userData
                     |> UserData.userName(comment |> Comment.creatorId)
                   )
                   ++ "**"
                 }
                 className="px-4 py-3"
                 profile=Markdown.Comment
               />
               {
                 isCoach || comment |> Comment.creatorId == currentUserId ?
                   <QuestionsShow__ArchiveManager
                     authenticityToken
                     id={comment |> Comment.id}
                     resourceType="Comment"
                     archiveCB
                   /> :
                   React.null
               }
             </div>
           </li>
         )
      |> Array.of_list
      |> ReasonReact.array
    }
    {
      allCommentsShown ?
        <QuestionsShow__AddComment
          authenticityToken
          commentableType
          commentableId
          addCommentCB
          currentUserId
        /> :
        React.null
    }
    {
      !allCommentsShown ?
        <a
          onClick={_ => setShowAll(_ => true)}
          className="bg-gray-200 rounded-full cursor-pointer border py-1 px-3 flex mx-auto appearance-none text-xs font-semibold hover:bg-primary-100 hover:text-primary-500 -mt-3">
          {"Show More" |> str}
        </a> :
        ReasonReact.null
    }
  </ul>;
};