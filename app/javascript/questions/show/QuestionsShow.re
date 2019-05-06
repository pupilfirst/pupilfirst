[@bs.config {jsx: 3}];
[%bs.raw {|require("./QuestionsShow.css")|}];

open QuestionsShow__Types;

let str = React.string;

type action =
  | AddComment(Comment.t)
  | AddAnswer(Answer.t)
  | AddLike(Like.t)
  | RemoveLike(string);
type state = {
  answers: list(Answer.t),
  comments: list(Comment.t),
  likes: list(Like.t),
};

let reducer = (state, action) =>
  switch (action) {
  | AddComment(comment) => {
      ...state,
      comments: Comment.addComment(state.comments, comment),
    }
  | AddAnswer(answer) => {
      ...state,
      answers: Answer.addAnswer(state.answers, answer),
    }
  | AddLike(like) => {...state, likes: state.likes |> Like.addLike(like)}
  | RemoveLike(id) => {...state, likes: state.likes |> Like.removeLike(id)}
  };

[@react.component]
let make =
    (
      ~authenticityToken,
      ~question,
      ~answers,
      ~comments,
      ~userData,
      ~likes,
      ~currentUserId,
      ~communityPath,
    ) => {
  let (state, dispatch) =
    React.useReducer(reducer, {answers, comments, likes});
  let addCommentCB = comment => dispatch(AddComment(comment));
  let addAnswerCB = answer => dispatch(AddAnswer(answer));
  let addLikeCB = like => dispatch(AddLike(like));
  let removeLikeCB = id => dispatch(RemoveLike(id));
  <div className="flex flex-1 bg-grey-lightest">
    <div className="flex-1 flex flex-col">
      <div className="flex-col px-6 py-2 items-center justify-between">
        <div className="max-w-lg w-full mx-auto mb-4">
          <a href=communityPath> {React.string("Back")} </a>
        </div>
        <div
          className="max-w-lg w-full flex mx-auto items-center justify-center relative shadow bg-white border rounded-lg">
          <div className="flex w-full">
            <div className="flex flex-1 flex-col">
              <div className="pt-6 pb-2 mx-6">
                <h2 className="text-xl text-black font-semibold">
                  {question |> Question.title |> str}
                </h2>
              </div>
              <div className="pt-2 pb-4 px-6 leading-normal text-sm">
                {question |> Question.description |> str}
              </div>
              <div className="flex flex-row justify-between px-6 pb-6">
                <div className="pr-2 pt-6 text-center">
                  <i className="fal fa-comment-lines text-xl text-grey-dark" />
                  <p className="text-xs pt-1">
                    {
                      state.comments
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
        <QuestionsShow__CommentShow
          comments={state.comments |> Comment.commentsForQuestion}
          userData
          authenticityToken
          commentableType="Question"
          commentableId={question |> Question.id}
          addCommentCB
          currentUserId
        />
        <div
          className="max-w-lg w-full justify-center mx-auto mb-4 py-4 border-b-2">
          <div className="flex justify-between items-end">
            <span className="text-lg font-semibold">
              {
                (state.answers |> List.length |> string_of_int)
                ++ " Answers"
                |> str
              }
            </span>
            <a
              className="bg-indigo-dark hover:bg-blue-dark text-white font-bold py-2 px-4 shadow rounded focus:outline-none">
              {"Add-your-answer" |> str}
            </a>
          </div>
        </div>
        <div className="community-answer-container">
          {
            state.answers
            |> List.map(answer => {
                 let userProfile =
                   userData |> UserData.user(answer |> Answer.userId);
                 let commentsForAnswer =
                   state.comments
                   |> Comment.commentsForAnswer(answer |> Answer.id);
                 <div
                   className="flex flex-col relative"
                   key={answer |> Answer.id}>
                   <div
                     className="max-w-lg w-full flex mx-auto items-center justify-center relative border shadow bg-white rounded-lg mt-4">
                     <div className="flex w-full">
                       <div className="flex flex-1 flex-col">
                         <div
                           className="py-4 px-6 leading-normal text-sm"
                           dangerouslySetInnerHTML={
                             "__html":
                               answer |> Answer.description |> Markdown.parse,
                           }
                         />
                         <div
                           className="flex flex-row justify-between px-6 pb-4">
                           <div className="px-2 pt-6 text-center">
                             <div className="flex flex-row">
                               <QuestionsShow__LikeManager
                                 authenticityToken
                                 likes={state.likes}
                                 answerId={answer |> Answer.id}
                                 currentUserId
                                 addLikeCB
                                 removeLikeCB
                               />
                               <div className="ml-4">
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
                             </div>
                           </div>
                           <QuestionsShow__UserShow
                             userProfile
                             createdAt={answer |> Answer.createdAt}
                           />
                         </div>
                       </div>
                     </div>
                   </div>
                   <QuestionsShow__CommentShow
                     comments=commentsForAnswer
                     userData
                     authenticityToken
                     commentableType="Answer"
                     commentableId={answer |> Answer.id}
                     addCommentCB
                     currentUserId
                   />
                 </div>;
               })
            |> Array.of_list
            |> ReasonReact.array
          }
        </div>
        <QuestionsShow__AddAnswer
          question
          authenticityToken
          currentUserId
          addAnswerCB
        />
      </div>
    </div>
  </div>;
};