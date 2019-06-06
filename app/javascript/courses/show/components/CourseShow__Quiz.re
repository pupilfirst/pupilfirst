[@bs.config {jsx: 3}];

open CourseShow__Types;

let str = React.string;

/* [%bs.raw {|require("./Quiz__Root.scss")|}]; */
/* [%bs.raw {|require("./images/quiz-placeholder.svg")|}]; */
/* [%bs.raw {|require("./images/quiz-right-answer-icon.svg")|}]; */
/* [%bs.raw {|require("./images/quiz-wrong-answer-icon.svg")|}]; */

let resultsSection = (correctAnswer, currentAnswer) => {
  let (classes, text) =
    currentAnswer == correctAnswer ?
      (
        "quiz-root__result-box--correct-answer mb-1 font-semibold",
        "Correct Answer",
      ) :
      (
        "quiz-root__result-box--wrong-answer mb-1 font-semibold",
        "Wrong Answer",
      );
  <div className="quiz-root__result text-center pt-4">
    <h3 className=classes> {text |> str} </h3>
    {
      switch (currentAnswer |> QuizQuestion.hint) {
      | None => ReasonReact.null
      | Some(hint) =>
        <p className="quiz-root__answer-hint"> {hint |> str} </p>
      }
    }
  </div>;
};

let resultsSectionClasses = currentAnswer =>
  switch (currentAnswer) {
  | Some(_answer) => "col-md-5 quiz-root__result-panel p-4 text-center"
  | None => "col-md-5 quiz-root__result-panel p-4 text-center quiz-root__result-panel-placeholder"
  };

let answerOptionClasses = (answerOption, correctAnswer, currentAnswer) =>
  switch (currentAnswer) {
  | Some(answer) when answer == correctAnswer && answerOption == correctAnswer => "quiz-root__answer-option quiz-root__answer-option--correct-answer"
  | Some(incorrectAnswer) when incorrectAnswer == answerOption => "quiz-root__answer-option quiz-root__answer-option--wrong-answer"
  | Some(_otherAnswer) => "quiz-root__answer-option"
  | None => "quiz-root__answer-option"
  };

[@react.component]
let make = (~target, ~quizQuestions) => {
  let (selectedQuestion, setSelectedQuestion) =
    React.useState(() => quizQuestions |> List.hd);
  let (selectedAnswer, setSelectedAnswer) = React.useState(() => None);
  let currentQuestion = selectedQuestion;
  let currentAnswer = selectedAnswer;
  let correctAnswer = selectedQuestion |> QuizQuestion.correctAnswer;

  <div className="d-flex quiz-root__component flex-column flex-md-row">
    <div className="col-md-7 quiz-root__question-panel p-4">
      <h6 className="font-semibold text-uppercase quiz-root__header-text mb-1">
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
                 key={answerOption |> QuizQuestion.id}>
                 {answerOption |> QuizQuestion.value |> str}
               </div>
             )
          |> Array.of_list
          |> ReasonReact.array
        }
      </div>
    </div>
    /* onClick={_event => send(SelectAnswer(answerOption))} */
    <div className={resultsSectionClasses(currentAnswer)}>
      {
        switch (currentAnswer) {
        | None => ReasonReact.null
        | Some(answer) => answer |> resultsSection(correctAnswer)
        }
      }
      {
        switch (currentAnswer) {
        | None => ReasonReact.null
        | Some(answer) when answer == correctAnswer =>
          <div className="quiz-root__next-question-button py-4">
            {
              currentQuestion |> QuizQuestion.isLastQuestion(quizQuestions) ?
                <button className="btn btn-md btn-ghost-primary">
                  {str("Submit Quiz")}
                </button> :
                {
                  /* onClick=(_event => submitTargetCB()) */

                  let nextQuestion =
                    currentQuestion
                    |> QuizQuestion.nextQuestion(quizQuestions);
                  <button className="btn btn-md btn-ghost-secondary">
                    {str("Next Question")}
                  </button>;
                  /* onClick=(_event => send(SelectQuestion(nextQuestion))) */
                }
            }
          </div>
        | Some(_incorrectAnswer) => <p> {"Try Again" |> str} </p>
        }
      }
    </div>
  </div>;
};