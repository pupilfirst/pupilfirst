open CurriculumEditor__Types;

let str = ReasonReact.string;

type answer = string;

type description = string;

type correctAnswer = bool;

type answerOptions = (answer, description, correctAnswer);

type question = string;

type quizQuestion = (question, answerOptions);

type state = list(quizQuestion);

let initalQuizQuestion = ("Question", ("Answer", "Description", true));

type action =
  | AddQuizQuestion(quizQuestion)
  | UpdateQuizQuestion(quizQuestion)
  | RemoveQuizQuestion(quizQuestion);

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetQuizCreator");

let make = _children => {
  ...component,
  initialState: () => initalQuizQuestion,
  reducer: (action, state) =>
    switch (action) {
    | AddQuizQuestion(quiz) => ReasonReact.Update(quiz)
    | UpdateQuizQuestion(quiz) => ReasonReact.Update(quiz)
    | RemoveQuizQuestion(quiz) => ReasonReact.Update(quiz)
    },
  render: ({state, send}) => {
    let targetsInTG = 1;
    <div>
      <label
        className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
        htmlFor="Quiz question 1">
        {"Prepare the quiz now." |> str}
      </label>
      <CurriculumEditor__TargetQuizQuestion />
    </div>;
  },
};