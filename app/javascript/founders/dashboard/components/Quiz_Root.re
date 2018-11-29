[%bs.raw {|require("./Quiz_Root.scss")|}];

let component = ReasonReact.statelessComponent("Quiz");

type props = {quizDetails: list(Quiz_Question.t)};

let str = ReasonReact.string;

let make = (~quizDetails, _children) => {
  ...component,
  render: _self => {
    let lengthOfList = quizDetails |> List.length;
    let question = quizDetails |> List.rev |> List.hd;
    <div className="quiz-root__quiz-header">
      <div className="quiz-root__question-heading">
        <h3> {str("QUIZ QUESTIONS")} </h3>
        <h3> {str("1 /" ++ string_of_int(lengthOfList))} </h3>
        <div> {str("1 /" ++ string_of_int(lengthOfList))} </div>
        <div className="quiz-root-answer">
        {str("h")}
        </div>
      </div>
      <div className="quiz-root__question-body">
        <div className="quiz-root__question-text">
          <h3> {question |> Quiz_Question.question |> str} </h3>
        </div>
        <div className=".quiz-root__question-description">
        <h4> {question |> Quiz_Question.description |> str} </h4>
        </div>
        <div className="answer_options">
        {
          question
          |> Quiz_Question.answer_options
          |> List.map(answers => {    <span className="quiz-root__answer-option">
          <label>
            <input type_="radio" name="review-form__status-radio" />
            {answers |> Quiz_Answer.value |> str}
          </label>
        </span>})
          |> Array.of_list
          |> ReasonReact.array
        }
        </div>
      </div>
    </div>;
  },
};

let decode = json =>
  Json.Decode.{
    quizDetails: json |> field("quizDetails", list(Quiz_Question.decode)),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(~quizDetails=props.quizDetails, [||]);
    },
  );