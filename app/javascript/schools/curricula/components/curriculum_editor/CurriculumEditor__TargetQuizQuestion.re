open CurriculumEditor__Types;

let str = ReasonReact.string;

type state = {quizQuestion: QuizQuestion.t};

type action =
  | UpdateQuestion(string)
  | UpdateAnswerOption(AnswerOption.t, AnswerOption.t);
/* | AddCorrectAnswer(answerOption)
   | AddinCorrectAnswers(answerOption); */

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetQuizQuestionCreator");

let make = _children => {
  ...component,
  initialState: () => {quizQuestion: QuizQuestion.empty()},
  reducer: (action, state) =>
    switch (action) {
    | UpdateQuestion(question) =>
      ReasonReact.Update({
        quizQuestion: quizQuestion |> AnswerOption.updateQuestion(question),
      })
    | UpdateAnswerOption(answerA, answerB) =>
      let newQuestion =
        state.quizQuestion |> QuizQuestion.replace(answerA, answerB);
      ReasonReact.Update({quizQuestion: newQuestion});
    /* | AddCorrectAnswer(correctAnswer) =>
         let inCorrectAnswers =
           state.inCorrectAnswers
           |> List.filter(inCorrectAnswer => inCorrectAnswer !== correctAnswer);
         ReasonReact.Update({...state, correctAnswer, inCorrectAnswers});
       | AddinCorrectAnswers(answerOption) =>
         ReasonReact.Update({
           ...state,
           inCorrectAnswers: [answerOption, ...state.inCorrectAnswers],
         }) */
    },
  render: ({state, send}) => {
    let answerOptions = state.quizQuestion |> QuizQuestion.answerOptions;
    let updateAnswerOptionCB = (answerA, answerB) =>
      send(UpdateAnswerOption(answerA, answerB));
    <div>
      <div
        className="flex bg-transparent items-center border-b border-b-1 border-grey-light py-2 mb-4 rounded">
        <input
          className="appearance-none bg-transparent text-lg border-none w-full text-grey-darker mr-3 py-1 px-2 pl-0 leading-tight focus:outline-none"
          type_="text"
          placeholder="Type the question here"
        />
      </div>
      /* <CurriculumEditor__TargetQuizAnswer
           answer={state.correctAnswer |> (answer, description) |> answer}
           description={state.correctAnswer.description}
           addCorrectAnswerCB
           addinCorrectAnswersCB
         /> */
      {
        answerOptions
        |> List.map(answerOption =>
             <CurriculumEditor__TargetQuizAnswer
               answerOption
               updateAnswerOptionCB
             />
           )
        |> Array.of_list
        |> ReasonReact.array
      }
    </div>;
  },
};