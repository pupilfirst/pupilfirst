exception DecodeError(string);

[%bs.raw {|require("./Quiz_Root.scss")|}];

type submitTargetFunction = unit => unit;

type props = {
  questions: list(Quiz_Question.t),
  submitTarget: submitTargetFunction,
};

type state = {
  currentQuestionId: int,
  selectedAnswer: option(Quiz_Answer.t),
};

type action =
  | NextQuestion
  | SelectAnswer(Quiz_Answer.t);

let component = ReasonReact.reducerComponent("Quiz");

let str = ReasonReact.string;

let questionDetails = (id, questions) =>
  questions |> List.find(question => question |> Quiz_Question.id == id);

let hintOfSelectedAnswer = selectedAnswer =>
  switch (selectedAnswer |> Quiz_Answer.hint) {
  | Some(hint) => str(hint)
  | None => str("")
  };

let key = (questionId, answerId) =>
  string_of_int(questionId) ++ string_of_int(answerId);

let descriptionOfSelectedQuestion = selectedAnswer =>
  switch (selectedAnswer |> Quiz_Question.description) {
  | Some(description) => str(description)
  | None => str("")
  };

let make = (~questions, ~submitTarget, _children) => {
  ...component,
  initialState: () => {currentQuestionId: 0, selectedAnswer: None},
  reducer: (action, state) =>
    switch (action) {
    | NextQuestion =>
      ReasonReact.Update({
        currentQuestionId: state.currentQuestionId + 1,
        selectedAnswer: None,
      })
    | SelectAnswer(answer) =>
      ReasonReact.Update({...state, selectedAnswer: Some(answer)})
    },
  render: ({state, send}) => {
    let totalNumberOfQuestions = questions |> List.length;
    let currentQuestion = questionDetails(state.currentQuestionId, questions);
    <div className="quiz-root">
      <div className="col-md-12 quiz-root__header-text">
        <h2> {str("Complete the QUIZ")} </h2>
      </div>
      <div className="quiz-root__body">
        <div className="col-md-7 quiz-root__question-questions">
          <div className="quiz-root__question-body">
            <div className="quiz-root__question-heading">
              <h3> {currentQuestion |> Quiz_Question.question |> str} </h3>
            </div>
            <div className=".quiz-root__question-description">
              <h5> {descriptionOfSelectedQuestion(currentQuestion)} </h5>
            </div>
            <div className="answer_options">
              {
                currentQuestion
                |> Quiz_Question.answer_options
                |> List.map(answers =>
                     <span
                       className="quiz-root__answer-option"
                       key={
                         key(
                           state.currentQuestionId,
                           answers |> Quiz_Answer.id,
                         )
                       }>
                       <label>
                         <input
                           type_="radio"
                           id={
                             key(
                               state.currentQuestionId,
                               answers |> Quiz_Answer.id,
                             )
                           }
                           name={
                             "Quiz_Root__answer-radio-"
                             ++ string_of_int(state.currentQuestionId)
                           }
                           onClick={_event => send(SelectAnswer(answers))}
                         />
                         {answers |> Quiz_Answer.value |> str}
                       </label>
                     </span>
                   )
                |> Array.of_list
                |> ReasonReact.array
              }
            </div>
          </div>
        </div>
        <div className="col-md-5 quiz-root__result-section">
          <div className="quiz-root__question-section">
            <div className="quiz-root__answer-result">
              {
                switch (state.selectedAnswer) {
                | Some(answer) when answer |> Quiz_Answer.correctAnswer =>
                  <span className="correct-answer">
                    {str("Correct Answer")}
                  </span>

                | Some(_other) =>
                  <span className="wrong-answer">
                    {str("Wrong Answer")}
                  </span>
                | None => str("")
                }
              }
            </div>
            <div className="quiz-root__answer-hint">
              {
                switch (state.selectedAnswer) {
                | Some(answer) => hintOfSelectedAnswer(answer)
                | None => str("")
                }
              }
            </div>
            <div className="quiz-root__question-next-button my-4">
              {
                switch (state.selectedAnswer, state.currentQuestionId) {
                | (Some(answer), questionId)
                    when
                      answer
                      |> Quiz_Answer.correctAnswer
                      && questionId >= totalNumberOfQuestions
                      - 1 =>
                  <button
                    className="btn btn-md btn-ghost-primary"
                    onClick=(_event => submitTarget())>
                    {str("Submit QUIZ")}
                  </button>
                | (Some(_otherAnswer), _)
                    when _otherAnswer |> Quiz_Answer.correctAnswer =>
                  <button
                    className="btn btn-md btn-ghost-primary"
                    onClick=(_event => send(NextQuestion))>
                    {str("NEXT")}
                  </button>
                | (Some(_other), _) => str("TRY AGAIN")
                | (None, _) => str("")
                }
              }
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
    questions: json |> field("quizQuestions", list(Quiz_Question.decode)),
    submitTarget: json |> field("submitTarget", asSubmitTargetFunction),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~questions=props.questions,
        ~submitTarget=props.submitTarget,
        [||],
      );
    },
  );