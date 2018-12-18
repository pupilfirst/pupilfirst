exception DecodeError(string);

[%bs.raw {|require("./Quiz__Root.scss")|}];
[%bs.raw {|require("./images/quiz-placeholder.svg")|}];
[%bs.raw {|require("./images/quiz-right-answer-icon.svg")|}];
[%bs.raw {|require("./images/quiz-wrong-answer-icon.svg")|}];

type submitTargetFunction = unit => unit;

type props = {
  questions: list(Quiz__Question.t),
  submitTargetCB: submitTargetFunction,
};

type state = {
  selectedQuestion: Quiz__Question.t,
  selectedAnswer: option(Quiz__Answer.t),
};

type action =
  | SelectQuestion(Quiz__Question.t)
  | SelectAnswer(Quiz__Answer.t);

let component = ReasonReact.reducerComponent("Quiz");

let str = ReasonReact.string;

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
      switch (currentAnswer |> Quiz__Answer.hint) {
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

let make = (~questions, ~submitTargetCB, _children) => {
  ...component,
  initialState: () => {
    selectedQuestion: questions |> List.hd,
    selectedAnswer: None,
  },
  reducer: (action, state) =>
    switch (action) {
    | SelectQuestion(selectedQuestion) =>
      ReasonReact.Update({selectedQuestion, selectedAnswer: None})
    | SelectAnswer(selectedAnswer) =>
      ReasonReact.Update({...state, selectedAnswer: Some(selectedAnswer)})
    },
  render: ({state, send}) => {
    let currentQuestion = state.selectedQuestion;
    let currentAnswer = state.selectedAnswer;
    let correctAnswer = state.selectedQuestion |> Quiz__Question.correctAnswer;

    <div className="d-flex quiz-root__component flex-column flex-md-row">
      <div className="col-md-7 quiz-root__question-panel p-4">
        <h6
          className="font-semibold text-uppercase quiz-root__header-text mb-1">
          {"Question #" |> str}
          {
            string_of_int((currentQuestion |> Quiz__Question.index) + 1) |> str
          }
        </h6>
        <div className="quiz-root__question-text mb-1">
          <h4 className="font-semibold mb-0">
            {currentQuestion |> Quiz__Question.question |> str}
          </h4>
        </div>
        {
          switch (currentQuestion |> Quiz__Question.description) {
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
            |> Quiz__Question.answerOptions
            |> List.map(answerOption =>
                 <div
                   className={
                     answerOptionClasses(
                       answerOption,
                       correctAnswer,
                       currentAnswer,
                     )
                   }
                   key={answerOption |> Quiz__Answer.id |> string_of_int}
                   onClick={_event => send(SelectAnswer(answerOption))}>
                   {answerOption |> Quiz__Answer.value |> str}
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
          | Some(answer) => answer |> resultsSection(correctAnswer)
          }
        }
        {
          switch (currentAnswer) {
          | None => ReasonReact.null
          | Some(answer) when answer == correctAnswer =>
            <div className="quiz-root__next-question-button py-4">
              {
                currentQuestion |> Quiz__Question.isLastQuestion(questions) ?
                  <button
                    className="btn btn-md btn-ghost-primary"
                    onClick=(_event => submitTargetCB())>
                    {str("Submit Quiz")}
                  </button> :
                  {
                    let nextQuestion =
                      currentQuestion
                      |> Quiz__Question.nextQuestion(questions);
                    <button
                      className="btn btn-md btn-ghost-secondary"
                      onClick=(_event => send(SelectQuestion(nextQuestion)))>
                      {str("Next Question")}
                    </button>;
                  }
              }
            </div>
          | Some(_incorrectAnswer) => <p> {"Try Again" |> str} </p>
          }
        }
      </div>
    </div>;
  },
};

let asSubmitTargetFunction = json =>
  if (Js.typeof(json) == "function") {
    (Obj.magic(json: Js.Json.t): submitTargetFunction);
  } else {
    raise @@ DecodeError("Expected function, got something else!");
  };

let decode = json =>
  Json.Decode.{
    questions: json |> field("quizQuestions", list(Quiz__Question.decode)),
    submitTargetCB: json |> field("submitTargetCB", asSubmitTargetFunction),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~questions=props.questions,
        ~submitTargetCB=props.submitTargetCB,
        [||],
      );
    },
  );