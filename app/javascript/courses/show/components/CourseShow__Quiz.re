[@bs.config {jsx: 3}];

open CourseShow__Types;

let str = React.string;

module CreateQuizSubmissionQuery = [%graphql
  {|
   mutation($targetId: ID!, $answerIds: [ID!]!) {
    createQuizSubmissions(targetId: $targetId, answerIds: $answerIds){
      submissionDetails{
        id
        description
        createdAt
      }
     }
   }
 |}
];

let createQuizSubmission =
    (authenticityToken, target, selectedAnswersIds, setSaving) => {
  setSaving(_ => true);
  CreateQuizSubmissionQuery.make(
    ~targetId=target |> Target.id,
    ~answerIds=selectedAnswersIds |> Array.of_list,
    (),
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       switch (response##createQuizSubmissions##submissionDetails) {
       | Some(details) =>
         Notification.success("Success", details##description)
       | None =>
         Notification.error(
           "Something went wrong",
           "Please refresh the page and try again",
         )
       };
       Js.Promise.resolve();
     })
  |> ignore;
};

let resultsSectionClasses = selectedAnswer => {
  let defaultClasses = "flex flex-col p-4 text-center bg-gray-200 justify-center";
  switch (selectedAnswer) {
  | Some(_answer) => defaultClasses
  | None => ""
  };
};

let answerOptionClasses = (answerOption, selectedAnswer) => {
  let defaultClasses = "border-1 shadow rounded-lg border-gray-200 p-1 mt-2 ";
  switch (selectedAnswer) {
  | Some(answer) when answer == answerOption =>
    defaultClasses ++ "bg-blue-500"
  | Some(_otherAnswer) => defaultClasses
  | None => defaultClasses
  };
};

let handleSubmit =
    (answer, authenticityToken, target, selectedAnswersIds, setSaving, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  let answerIds =
    selectedAnswersIds |> List.append([answer |> QuizQuestion.answerId]);

  createQuizSubmission(authenticityToken, target, answerIds, setSaving);
};

[@react.component]
let make = (~target, ~quizQuestions, ~authenticityToken) => {
  let (saving, setSaving) = React.useState(() => false);
  let (selectedQuestion, setSelectedQuestion) =
    React.useState(() => quizQuestions |> List.hd);
  let (selectedAnswer, setSelectedAnswer) = React.useState(() => None);
  let (selectedAnswersIds, setSelectedAnswersIds) = React.useState(() => []);
  let currentQuestion = selectedQuestion;
  <div className="flex justify-center">
    <div className="border-2 shadow rounded-lg mt-2">
      <div className="p-4">
        <h6
          className="font-semibold text-uppercase quiz-root__header-text mb-1">
          {"Question #" |> str}
          {string_of_int((currentQuestion |> QuizQuestion.index) + 1) |> str}
        </h6>
        <div className="quiz-root__question-text mb-1">
          <h4 className="font-semibold mb-0">
            {currentQuestion |> QuizQuestion.question |> str}
          </h4>
        </div>
        {
          switch (currentQuestion |> QuizQuestion.description) {
          | None => React.null
          | Some(description) =>
            <div className="quiz-root__question-description">
              <p> {description |> str} </p>
            </div>
          }
        }
        <div className="quiz-root__question-answers mt-4">
          {
            currentQuestion
            |> QuizQuestion.answerOptions
            |> List.map(answerOption =>
                 <div
                   className={
                     answerOptionClasses(answerOption, selectedAnswer)
                   }
                   key={answerOption |> QuizQuestion.answerId}
                   onClick={_ => setSelectedAnswer(_ => Some(answerOption))}>
                   {answerOption |> QuizQuestion.answerValue |> str}
                 </div>
               )
            |> Array.of_list
            |> React.array
          }
        </div>
      </div>
      <div className={resultsSectionClasses(selectedAnswer)}>
        {
          switch (selectedAnswer) {
          | None => React.null
          | Some(answer) =>
            <div className="quiz-root__next-question-button py-4">
              {
                currentQuestion |> QuizQuestion.isLastQuestion(quizQuestions) ?
                  <button
                    disabled=saving
                    className="btn btn-primary-ghost"
                    onClick={
                      handleSubmit(
                        answer,
                        authenticityToken,
                        target,
                        selectedAnswersIds,
                        setSaving,
                      )
                    }>
                    {str("Submit Quiz")}
                  </button> :
                  {
                    let nextQuestion =
                      currentQuestion
                      |> QuizQuestion.nextQuestion(quizQuestions);
                    <button
                      className="btn btn-primary-ghost"
                      onClick=(
                        _ => {
                          setSelectedQuestion(_ => nextQuestion);
                          setSelectedAnswersIds(_ =>
                            selectedAnswersIds
                            |> List.append([answer |> QuizQuestion.answerId])
                          );
                          setSelectedAnswer(_ => None);
                        }
                      )>
                      {str("Next Question")}
                    </button>;
                  }
              }
            </div>
          }
        }
      </div>
    </div>
  </div>;
};