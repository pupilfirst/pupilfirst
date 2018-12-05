exception DecodeError(string);

[%bs.raw {|require("./Quiz_Root.scss")|}];

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

let hintOfSelectedAnswer = selectedAnswer =>
  switch (selectedAnswer |> Quiz__Answer.hint) {
  | Some(hint) => hint |> str
  | None => ReasonReact.null
  };

let key = (questionId, answerId) =>
  string_of_int(questionId) ++ string_of_int(answerId);

let descriptionOfSelectedQuestion = selectedAnswer =>
  switch (selectedAnswer |> Quiz__Question.description) {
  | Some(description) => str(description)
  | None => str("")
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
    let totalNumberOfQuestions = questions |> List.length;
    let currentQuestion = state.selectedQuestion;
    let correctAnswer = currentQuestion |> Quiz__Question.correctAnswer;
    <div className="quiz-root">
      <div className="col-md-12 quiz-root__header-text">
        <h2> (str("Complete the QUIZ")) </h2>
      </div>
      <div className="quiz-root__body">
        <div className="col-md-7 quiz-root__question-questions">
          <div className="quiz-root__question-body">
            <div className="quiz-root__question-heading">
              <h3> (currentQuestion |> Quiz__Question.question |> str) </h3>
            </div>
            <div className=".quiz-root__question-description">
              <h5> (descriptionOfSelectedQuestion(currentQuestion)) </h5>
            </div>
            <div className="answer_options">
              (
                currentQuestion
                |> Quiz__Question.answerOptions
                |> List.map(answerOption =>
                     <span
                       className="quiz-root__answer-option"
                       key=(answerOption |> Quiz__Answer.id |> string_of_int)>
                       <label>
                         <input
                           type_="radio"
                           id=(
                             answerOption |> Quiz__Answer.id |> string_of_int
                           )
                           onClick=(
                             _event => send(SelectAnswer(answerOption))
                           )
                         />
                         (answerOption |> Quiz__Answer.value |> str)
                       </label>
                     </span>
                   )
                |> Array.of_list
                |> ReasonReact.array
              )
            </div>
          </div>
        </div>
        <div className="col-md-5 quiz-root__result-section">
          <div className="quiz-root__question-section">
            <div className="quiz-root__answer-result">
              (
                switch (state.selectedAnswer) {
                | Some(answer) when answer == correctAnswer =>
                  <span className="correct-answer">
                    (str("Correct Answer"))
                  </span>
                | Some(_other) =>
                  <span className="wrong-answer">
                    (str("Wrong Answer"))
                  </span>
                | None => str("")
                }
              )
            </div>
            <div className="quiz-root__answer-hint">
              (
                switch (state.selectedAnswer) {
                | Some(answer) => hintOfSelectedAnswer(answer)
                | None => str("")
                }
              )
            </div>
            <div className="quiz-root__question-next-button my-4">
              (
                switch (state.selectedAnswer, state.selectedQuestion) {
                | (Some(answer), question)
                    when
                      answer == correctAnswer
                      && question == (questions |> Quiz__Question.lastQuestion) =>
                  <button
                    className="btn btn-md btn-ghost-primary"
                    onClick=(_event => submitTargetCB())>
                    (str("Submit Quiz"))
                  </button>
                | (Some(_otherAnswer), _) when _otherAnswer == correctAnswer =>
                  <button
                    className="btn btn-md btn-ghost-primary"
                    onClick=(
                      _event =>
                        send(
                          SelectQuestion(
                            questions
                            |> Quiz__Question.nextQuestion(
                                 state.selectedQuestion,
                               ),
                          ),
                        )
                    )>
                    (str("Next"))
                  </button>
                | (Some(_other), _) => str("Try Again")
                | (None, _) => str("")
                }
              )
            </div>
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