type id = string;

type t = {
  id,
  answer: string,
  hint: option(string),
  correctAnswer: bool,
};

let id = t => t.id;

let answer = t => t.answer;

let hint = t => t.hint;

let correctAnswer = t => t.correctAnswer;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    answer: json |> field("answer", string),
    hint: json |> field("hint", nullable(string)) |> Js.Null.toOption,
    correctAnswer: json |> field("correctAnswer", bool),
  };

let empty = (id, correctAnswer) => {
  id,
  answer: "",
  hint: None,
  correctAnswer,
};

let updateAnswer = (answer, t) => {...t, answer};

let updateHint = (hint, t) => {...t, hint};

let markAsCorrect = t => {...t, correctAnswer: true};

let markAsIncorrect = t => {...t, correctAnswer: false};

let isValidAnswerOption = t =>
  t.answer |> Js.String.trim |> Js.String.length >= 1;

let encoder = t =>
  Json.Encode.(
    object_([
      ("answer", t.answer |> string),
      (
        "hint",
        switch (t.hint) {
        | Some(hint) => hint |> string
        | None => null
        },
      ),
      ("correctAnswer", t.correctAnswer |> bool),
    ])
  );
