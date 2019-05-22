[@bs.config {jsx: 3}];
[%bs.raw {|require("./QuestionsShow.css")|}];

open QuestionsShow__Types;

let str = React.string;

type action =
  | AddComment(Comment.t)
  | AddAnswer(Answer.t)
  | AddLike(Like.t)
  | RemoveLike(string)
  | UpdateShowAnswerCreate(bool);

type state = {
  answers: list(Answer.t),
  comments: list(Comment.t),
  markdownVersions: list(MarkdownVersion.t),
  likes: list(Like.t),
  showAnswerCreate: bool,
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
  | UpdateShowAnswerCreate(bool) => {...state, showAnswerCreate: bool}
  };

let showAnswersCreateComponent = (answers, showAnswerCreate, currentUserId) =>
  if (showAnswerCreate) {
    true;
  } else {
    answers |> Answer.answerFromUser(currentUserId) |> ListUtils.isEmpty;
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
      ~markdownVersions,
      ~currentUserId,
      ~communityPath,
    ) => {
  let (state, dispatch) =
    React.useReducer(
      reducer,
      {answers, comments, likes, showAnswerCreate: false, markdownVersions},
    );
  let addCommentCB = comment => dispatch(AddComment(comment));
  let addAnswerCB = answer => {
    dispatch(AddAnswer(answer));
    dispatch(UpdateShowAnswerCreate(false));
  };
  let addLikeCB = like => dispatch(AddLike(like));
  let removeLikeCB = id => dispatch(RemoveLike(id));
  <div className="flex flex-1 bg-gray-100">
    <div className="flex-1 flex flex-col">
      <div className="flex-col px-3 md:px-6 py-2 items-center justify-between">
        <div className="max-w-3xl w-full mx-auto mt-5 pb-2">
          <a className="btn btn-default no-underline" href=communityPath>
            <i className="far fa-arrow-left" />
            <span className="ml-2"> {React.string("Back")} </span>
          </a>
        </div>
        <div
          className="max-w-3xl w-full flex mx-auto items-center justify-center relative shadow bg-white border rounded-lg">
          <div className="flex w-full">
            <div className="flex flex-1 flex-col">
              <div className="pt-6 pb-2 mx-6">
                <h2 className="text-xl text-black font-semibold">
                  {question |> Question.title |> str}
                </h2>
              </div>
              <div
                className="py-4 px-6 leading-normal text-sm markdown-body"
                dangerouslySetInnerHTML={
                  "__html":
                    state.markdownVersions
                    |> MarkdownVersion.latestValue(
                         question |> Question.id,
                         "Question",
                       ),
                }
              />
              <div className="flex flex-row justify-between px-6 pb-6">
                <div className="pr-2 pt-6 text-center">
                  <i className="fal fa-comment-lines text-xl text-gray-600" />
                  <p className="text-xs py-1">
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
                  textForTimeStamp="Asked"
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
          className="max-w-3xl w-full justify-center mx-auto mb-4 pt-5 pb-2 border-b">
          <div className="flex justify-between items-end">
            <span className="text-lg font-semibold">
              {
                (state.answers |> List.length |> string_of_int)
                ++ " Answers"
                |> str
              }
            </span>
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
                     className="max-w-3xl w-full flex mx-auto items-center justify-center relative border shadow bg-white rounded-lg mt-4">
                     <div className="flex w-full">
                       <div className="flex flex-1 flex-col">
                         <div
                           className="py-4 px-6 leading-normal text-sm markdown-body"
                           dangerouslySetInnerHTML={
                             "__html":
                               state.markdownVersions
                               |> MarkdownVersion.latestValue(
                                    answer |> Answer.id,
                                    "Answer",
                                  ),
                           }
                         />
                         <div
                           className="flex flex-row justify-between items-center px-6 pb-4">
                           <div className="pt-4 text-center">
                             <div className="flex flex-row">
                               <QuestionsShow__LikeManager
                                 authenticityToken
                                 likes={state.likes}
                                 answerId={answer |> Answer.id}
                                 currentUserId
                                 addLikeCB
                                 removeLikeCB
                               />
                               <div className="mr-2 pt-2 px-2">
                                 <i
                                   className="fal fa-comment-lines text-xl text-gray-600"
                                 />
                                 <p className="text-xs py-1">
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
                             textForTimeStamp="Answered"
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
        {
          showAnswersCreateComponent(
            state.answers,
            state.showAnswerCreate,
            currentUserId,
          ) ?
            <QuestionsShow__AddAnswer
              question
              authenticityToken
              currentUserId
              addAnswerCB
            /> :
            <div
              className="community-ask-button-container mt-4 my-8 max-w-3xl w-full flex mx-auto justify-center">
              <div className="bg-gray-100 px-1 z-10">
                <button
                  className="btn btn-primary btn-large"
                  onClick={_ => dispatch(UpdateShowAnswerCreate(true))}>
                  {"Add another answer" |> str}
                </button>
              </div>
            </div>
        }
      </div>
    </div>
  </div>;
};