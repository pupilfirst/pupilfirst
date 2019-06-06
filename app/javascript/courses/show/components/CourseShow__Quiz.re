[@bs.config {jsx: 3}];

open CourseShow__Types;

let str = React.string;

/* [%bs.raw {|require("./Quiz__Root.scss")|}]; */
/* [%bs.raw {|require("./images/quiz-placeholder.svg")|}]; */
/* [%bs.raw {|require("./images/quiz-right-answer-icon.svg")|}]; */
/* [%bs.raw {|require("./images/quiz-wrong-answer-icon.svg")|}]; */

let resultsSectionClasses = currentAnswer => {
  let defaultClasses = "flex flex-col p-4 text-center bg-gray-200 justify-center";
  switch (currentAnswer) {
  | Some(_answer) => defaultClasses
  | None => defaultClasses
  };
};

let answerOptionClasses = (answerOption, correctAnswer, currentAnswer) => {
  let defaultClasses = "border-1 shadow rounded-lg border-gray-200 p-1 mt-2 ";
  switch (currentAnswer) {
  | Some(answer) when answer == answerOption =>
    defaultClasses ++ "bg-blue-500"
  | Some(_otherAnswer) => defaultClasses
  | None => defaultClasses
  };
};

[@react.component]
let make = (~target, ~quizQuestions) => {
  let (selectedQuestion, setSelectedQuestion) =
    React.useState(() => quizQuestions |> List.hd);
  let (selectedAnswer, setSelectedAnswer) = React.useState(() => None);
  let (selectedAnswers, setSelectedAnswers) = React.useState(() => []);
  let currentQuestion = selectedQuestion;
  let currentAnswer = selectedAnswer;
  let correctAnswer = selectedQuestion |> QuizQuestion.correctAnswer;
  Js.log(selectedAnswers);
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
          | None => ReasonReact.null
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
                     answerOptionClasses(
                       answerOption,
                       correctAnswer,
                       currentAnswer,
                     )
                   }
                   key={answerOption |> QuizQuestion.id}
                   onClick={_ => setSelectedAnswer(_ => Some(answerOption))}>
                   {answerOption |> QuizQuestion.value |> str}
                 </div>
               )
            |> Array.of_list
            |> ReasonReact.array
          }
        </div>
      </div>
      <div className={resultsSectionClasses(currentAnswer)}>
        {
          switch (currentAnswer) {
          | None => ReasonReact.null
          | Some(answer) =>
            <div className="quiz-root__next-question-button py-4">
              {
                currentQuestion |> QuizQuestion.isLastQuestion(quizQuestions) ?
                  <button className="btn btn-primary-ghost">
                    {str("Submit Quiz")}
                  </button> :
                  {
                    /* onClick=(_event => submitTargetCB()) */

                    let nextQuestion =
                      currentQuestion
                      |> QuizQuestion.nextQuestion(quizQuestions);
                    <button
                      className="btn btn-primary-ghost"
                      onClick=(
                        _ => {
                          setSelectedQuestion(_ => nextQuestion);
                          setSelectedAnswers(_ =>
                            selectedAnswers
                            |> List.append([answer |> QuizQuestion.id])
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