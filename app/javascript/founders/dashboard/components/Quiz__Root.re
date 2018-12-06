exception DecodeError(string);

[%bs.raw {|require("./Quiz__Root.scss")|}];

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
      ("correct-answer", "Correct Answer") : ("wrong-answer", "Wrong Answer");
  <div className="quiz-root__answer-result">
    <span className=classes> (text |> str) </span>
    (
      switch (currentAnswer |> Quiz__Answer.hint) {
      | None => ReasonReact.null
      | Some(hint) =>
        <div className="quiz-root__answer-hint"> (hint |> str) </div>
      }
    )
  </div>;
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
    let correctAnswer = currentQuestion |> Quiz__Question.correctAnswer;
    <div className="quiz-root">
      <div className="col-md-12 quiz-root__header-text">
        <h2> ("Complete the QUIZ" |> str) </h2>
      </div>
      <div className="quiz-root__body">
        <div className="col-md-7 quiz-root__question-questions">
          <div className="quiz-root__question-body">
            <div className="quiz-root__question-heading">
              <h3> (currentQuestion |> Quiz__Question.question |> str) </h3>
            </div>
            (
              switch (currentQuestion |> Quiz__Question.description) {
              | None => ReasonReact.null
              | Some(description) =>
                <div className="quiz-root__question-description">
                  <h5> (description |> str) </h5>
                </div>
              }
            )
            <div className="answer_options">
              (
                currentQuestion
                |> Quiz__Question.answerOptions
                |> List.map(answerOption =>
                     <div
                       className="quiz-root__answer_options"
                       key=(answerOption |> Quiz__Answer.id |> string_of_int)
                       onClick=(_event => send(SelectAnswer(answerOption)))>
                       (answerOption |> Quiz__Answer.value |> str)
                     </div>
                   )
                |> Array.of_list
                |> ReasonReact.array
              )
            </div>
          </div>
        </div>
        <div className="col-md-5 quiz-root__result-section">
          <div className="quiz-root__question-section">
            (
              switch (currentAnswer) {
              | None => ReasonReact.null
              | Some(answer) => answer |> resultsSection(correctAnswer)
              }
            )
            (
              switch (currentAnswer) {
              | None => ReasonReact.null
              | Some(answer) when answer == correctAnswer =>
                <div className="quiz-root__question-next-button my-4">
                  (
                    currentQuestion |> Quiz__Question.isLastQuestion(questions) ?
                      <button
                        className="btn btn-md btn-ghost-primary"
                        onClick=(_event => submitTargetCB())>
                        (str("Submit Quiz"))
                      </button> :
                      {
                        let nextQuestion =
                          currentQuestion
                          |> Quiz__Question.nextQuestion(questions);
                        <button
                          className="btn btn-md btn-ghost-primary"
                          onClick=(
                            _event => send(SelectQuestion(nextQuestion))
                          )>
                          (str("Next"))
                        </button>;
                      }
                  )
                </div>
              | Some(_incorrectAnswer) => "Try Again" |> str
              }
            )
          </div>
        </div>
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