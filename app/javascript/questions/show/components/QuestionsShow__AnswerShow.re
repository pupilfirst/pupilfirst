[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

[@react.component]
let make =
    (
      ~authenticityToken,
      ~answer,
      ~question,
      ~addCommentCB,
      ~currentUserId,
      ~addLikeCB,
      ~removeLikeCB,
      ~userData,
      ~comments,
      ~likes,
      ~handleAnswerCB,
    ) => {
  let userProfile = userData |> UserData.user(answer |> Answer.creatorId);
  let commentsForAnswer =
    comments |> Comment.commentsForAnswer(answer |> Answer.id);
  let (showAnswerEdit, toggleShowAnswerEdit) = React.useState(() => false);

  let handleAnswerEditCB = (answer, bool) => {
    toggleShowAnswerEdit(_ => false);
    handleAnswerCB(answer, bool);
  };

  <div className="flex flex-col relative" key={answer |> Answer.id}>
    {
      showAnswerEdit ?
        <div>
          <QuestionsShow__AnswerEditor
            question
            authenticityToken
            currentUserId
            handleAnswerCB=handleAnswerEditCB
            answer
          />
        </div> :
        <div>
          <div
            className="max-w-3xl w-full flex mx-auto items-center justify-center relative border shadow bg-white rounded-lg mt-4">
            <div className="flex w-full">
              <div className="flex flex-1 flex-col">
                <div className="py-4 px-6 flex flex-col">
                  <div
                    className="leading-normal text-sm markdown-body"
                    dangerouslySetInnerHTML={
                      "__html": answer |> Answer.description,
                    }
                  />
                  {
                    question |> Question.creatorId == currentUserId ?
                      <div>
                        <a
                          onClick={_ => toggleShowAnswerEdit(_ => true)}
                          className="text-sm mr-2 font-semibold cursor-pointer">
                          {"Edit" |> str}
                        </a>
                        <a
                          className="text-sm mr-2 font-semibold cursor-pointer">
                          {"Hide" |> str}
                        </a>
                      </div> :
                      React.null
                  }
                </div>
                <div
                  className="flex flex-row justify-between items-center px-6 pb-4">
                  <div className="pt-4 text-center">
                    <div className="flex flex-row">
                      <QuestionsShow__LikeManager
                        authenticityToken
                        likes
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
        </div>
    }
  </div>;
};