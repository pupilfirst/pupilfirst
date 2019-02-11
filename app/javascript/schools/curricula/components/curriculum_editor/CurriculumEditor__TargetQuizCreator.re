open CurriculumEditor__Types;

let str = ReasonReact.string;

type state = {quiz: list(QuizQuestion.t)};

type action =
  | AddQuizQuestion
  | UpdateQuizQuestion(int, QuizQuestion.t)
  | RemoveQuizQuestion(int);

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetQuizCreator");

let make = _children => {
  ...component,
  initialState: () => {quiz: [QuizQuestion.empty(0)]},
  reducer: (action, state) =>
    switch (action) {
    | AddQuizQuestion =>
      let lastQuestionId =
        state.quiz |> List.rev |> List.hd |> QuizQuestion.id;
      ReasonReact.Update({
        quiz:
          state.quiz
          |> List.rev
          |> List.append([QuizQuestion.empty(lastQuestionId + 1)])
          |> List.rev,
      });
    | UpdateQuizQuestion(id, quizQuestion) =>
      let newQuiz =
        state.quiz
        |> List.map(a => a |> QuizQuestion.id == id ? quizQuestion : a);
      ReasonReact.Update({quiz: newQuiz});

    | RemoveQuizQuestion(id) =>
      ReasonReact.Update({
        quiz: state.quiz |> List.filter(a => a |> QuizQuestion.id !== id),
      })
    },
  render: ({state, send}) => {
    let removeQuizQuestionCB = id => send(RemoveQuizQuestion(id));
    let updateQuizQuestionCB = (id, quizQuestion) =>
      send(UpdateQuizQuestion(id, quizQuestion));
    let questionCanBeRemoved = state.quiz |> List.length > 1;
    let isValidQuiz =
      state.quiz
      |> List.filter(quizQuestion =>
           quizQuestion |> QuizQuestion.isValidQuizQuestion != true
         )
      |> List.length == 0;
    <div>
      <label
        className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
        htmlFor="Quiz question 1">
        {"Prepare the quiz now." |> str}
      </label>
      {
        state.quiz
        |> List.map(quizQuestion =>
             <CurriculumEditor__TargetQuizQuestion
               key={quizQuestion |> QuizQuestion.id |> string_of_int}
               quizQuestion
               updateQuizQuestionCB
               removeQuizQuestionCB
               questionCanBeRemoved
             />
           )
        |> Array.of_list
        |> ReasonReact.array
      }
      <div
        onClick={
          _event => {
            ReactEvent.Mouse.preventDefault(_event);
            send(AddQuizQuestion);
          }
        }
        className="flex items-center py-3 cursor-pointer">
        <svg className="svg-icon w-8 h-8" viewBox="0 0 20 20">
          <path
            fill="#A8B7C7"
            d="M13.388,9.624h-3.011v-3.01c0-0.208-0.168-0.377-0.376-0.377S9.624,6.405,9.624,6.613v3.01H6.613c-0.208,0-0.376,0.168-0.376,0.376s0.168,0.376,0.376,0.376h3.011v3.01c0,0.208,0.168,0.378,0.376,0.378s0.376-0.17,0.376-0.378v-3.01h3.011c0.207,0,0.377-0.168,0.377-0.376S13.595,9.624,13.388,9.624z M10,1.344c-4.781,0-8.656,3.875-8.656,8.656c0,4.781,3.875,8.656,8.656,8.656c4.781,0,8.656-3.875,8.656-8.656C18.656,5.219,14.781,1.344,10,1.344z M10,17.903c-4.365,0-7.904-3.538-7.904-7.903S5.635,2.096,10,2.096S17.903,5.635,17.903,10S14.365,17.903,10,17.903z"
          />
        </svg>
        <h5 className="font-semibold ml-2">
          {"Add another Question" |> str}
        </h5>
      </div>
    </div>;
  },
};