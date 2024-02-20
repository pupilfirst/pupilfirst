exception UnexpectedZxcvbnScore(int)

type zxcvbnFeedback = {suggestions: array<string>}
type zxcvbnResponse = {
  score: int,
  feedback: zxcvbnFeedback,
}

@module("zxcvbn") external zxcvbn: (string, array<string>) => zxcvbnResponse = "default"
let ts = I18n.t(~scope="components.Zxcvbn")

type strength = Weak | Fair | Medium | Strong
type t = {
  score: int,
  strength: strength,
  suggestions: array<string>,
}

let label = t => {
  switch t.strength {
  | Weak => ts("weak")
  | Fair => ts("fair")
  | Medium => ts("medium")
  | Strong => ts("strong")
  }
}

let colorClass = (t, score) => {
  if t.score >= score {
    switch t.strength {
    | Weak => "bg-red-500"
    | Fair => "bg-orange-500"
    | Medium => "bg-yellow-500"
    | Strong => "bg-green-500"
    }
  } else {
    "bg-gray-500"
  }
}

let suggestions = t => t.suggestions
let score = t => t.score

let make = (~userInputs=[], ~password) => {
  if password->Js.String2.length > 0 {
    let formDictionary =
      userInputs->Js.Array2.map(val =>
        val->Js.String2.split(" ")->Js.Array2.concat(val->Js.String2.split("@"))
      )
    let zxcvbnResponse = zxcvbn(password, formDictionary->ArrayUtils.flattenV2)
    let score = zxcvbnResponse.score
    let suggestions = zxcvbnResponse.feedback.suggestions
    let strength = switch score {
    | 0 | 1 => Weak
    | 2 => Fair
    | 3 => Medium
    | 4 => Strong
    | unexpectedScore => raise(UnexpectedZxcvbnScore(unexpectedScore))
    }

    {score: score == 0 ? 1 : score, strength: strength, suggestions: suggestions}->Some
  } else {
    None
  }
}
