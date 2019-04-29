[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

[@react.component]
let make = (~authenticityToken, ~question, ~answers, ~comments, ~userData) =>
  <div className="flex flex-1 bg-grey-lighter">
    <div className="flex-1 flex flex-col">
      <div className="flex-col px-6 py-2 items-center justify-between">
        <div className="max-w-md w-full flex justify-center mb-4">
          <a href="#"> {React.string("back")} </a>
        </div>
        <div
          className="max-w-md w-full flex mx-auto items-center justify-center relative shadow bg-white rounded-lg">
          <div className="flex w-full">
            <div className="flex flex-1 flex-col">
              <div className="text-lg border-b-2 py-4 px-6">
                <span className="text-black font-semibold">
                  {question |> Question.title |> str}
                </span>
              </div>
              <div className="py-4 px-6 leading-normal text-sm">
                {question |> Question.description |> str}
              </div>
              <div className="flex flex-row justify-between px-6">
                <div className="px-2 pt-6 text-center">
                  <i className="fal fa-comment-lines text-xl text-grey-dark" />
                  <p className="text-xs pt-1">
                    {
                      comments
                      |> Comment.commentsForQuestion
                      |> List.length
                      |> string_of_int
                      |> str
                    }
                  </p>
                </div>
                <QuestionsShow__UserShow
                  userProfile={
                    userData |> UserData.user(question |> Question.userId)
                  }
                  createdAt={question |> Question.createdAt}
                />
              </div>
            </div>
          </div>
        </div>
        {
          comments
          |> Comment.commentsForQuestion
          |> List.map(comment =>
               <QuestionsShow__CommentShow comment userData />
             )
          |> Array.of_list
          |> ReasonReact.array
        }
        <div
          className="max-w-md w-full justify-center mx-auto mb-4 py-4 border-b-2">
          <span className="text-lg font-semibold">
            {(answers |> List.length |> string_of_int) ++ " Answers" |> str}
          </span>
        </div>
        {
          answers
          |> List.map(answer => {
               let userProfile =
                 userData |> UserData.user(answer |> Answer.userId);
               let commentsForAnswer =
                 comments |> Comment.commentsForAnswer(answer |> Answer.id);
               <div className="flex flex-col">
                 <div
                   className="max-w-md w-full flex mx-auto items-center justify-center relative shadow bg-white rounded-lg mt-4">
                   <div className="flex w-full">
                     <div className="flex flex-1 flex-col">
                       <div className="py-4 px-6 leading-normal text-sm">
                         {answer |> Answer.description |> str}
                       </div>
                       <div className="flex flex-row justify-between px-6">
                         <div className="px-2 pt-6 text-center">
                           <i
                             className="fal fa-comment-lines text-xl text-grey-dark"
                           />
                           <p className="text-xs pt-1">
                             {
                               commentsForAnswer
                               |> List.length
                               |> string_of_int
                               |> str
                             }
                           </p>
                         </div>
                         <QuestionsShow__UserShow
                           userProfile
                           createdAt={answer |> Answer.createdAt}
                         />
                       </div>
                     </div>
                   </div>
                 </div>
                 {
                   commentsForAnswer
                   |> List.map(comment =>
                        <QuestionsShow__CommentShow comment userData />
                      )
                   |> Array.of_list
                   |> ReasonReact.array
                 }
               </div>;
             })
          |> Array.of_list
          |> ReasonReact.array
        }
      </div>
    </div>
  </div>;
/* <div> <p> {React.string(authenticityToken ++ " clicked ")} </p> </div> */