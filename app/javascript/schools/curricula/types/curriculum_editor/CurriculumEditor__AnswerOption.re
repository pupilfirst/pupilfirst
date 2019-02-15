type t = {
  id: int,
  answer: string,
  description: option(string),
  correctAnswer: bool,
};

let id = t => t.id;

let answer = t => t.answer;

let description = t => t.description;

let correctAnswer = t => t.correctAnswer;

let empty = (id, correctAnswer) => {
  id,
  answer: "",
  description: None,
  correctAnswer,
};

let updateAnswer = (answer, t) => {...t, answer};

let updateDescription = (description, t) => {...t, description};

let markAsCorrect = t => {...t, correctAnswer: true};

let markAsIncorrect = t => {...t, correctAnswer: false};

let isValidAnswerOption = t =>
  t.answer |> Js.String.trim |> Js.String.length >= 1;

let encoder = t =>
  Json.Encode.(
    object_([
      ("answer", t.answer |> string),
      (
        "description",
        switch (t.description) {
        | Some(description) => description |> string
        | None => null
        },
      ),
      ("correctAnswer", t.correctAnswer |> bool),
    ])
  );