[@bs.config {jsx: 3}];
[%bs.raw {|require("./CourseShow__Quiz.css")|}];

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
  let defaultClasses = "quiz-root__answer bg-white flex items-center font-semibold shadow border border-transparent rounded p-3 mt-3 ";
  switch (selectedAnswer) {
  | Some(answer) when answer == answerOption =>
    defaultClasses ++ "bg-primary-100 border-primary-500 text-primary-500 shadow-md quiz-root__answer-selected "
  | Some(_otherAnswer) => defaultClasses
  | None => defaultClasses
  };
};

let iconClasses = (answerOption, selectedAnswer) => {
  let defaultClasses = "quiz-root__answer-option-icon far fa-check-circle text-lg ";
  switch (selectedAnswer) {
  | Some(answer) when answer == answerOption =>
    defaultClasses ++ "text-green-500"
  | Some(_otherAnswer) => defaultClasses ++ "text-gray-400"
  | None => defaultClasses ++ "text-gray-400"
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
  <div className="bg-gray-100 rounded overflow-hidden">
    <div className="p-5">
      <span
        className="font-semibold text-xs block uppercase text-gray-600">
        {"Question #" |> str}
        {string_of_int((currentQuestion |> QuizQuestion.index) + 1) |> str}
      </span>
      <h4 className="font-bold">
        {currentQuestion |> QuizQuestion.question |> str}
      </h4>
      {
        switch (currentQuestion |> QuizQuestion.description) {
        | None => React.null
        | Some(description) =>
          <p className="text-sm"> {description |> str} </p>
        }
      }
      <div className="pt-2">
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
                  <FaIcon classes={iconClasses(answerOption, selectedAnswer)} />
                  <span className="ml-2">
                    {answerOption |> QuizQuestion.answerValue |> str}
                  </span>
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
          <div className="py-4">
            {
              currentQuestion |> QuizQuestion.isLastQuestion(quizQuestions) ?
                <button
                  disabled=saving
                  className="btn btn-primary"
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
                    className="btn btn-primary"
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
  </div>;
};