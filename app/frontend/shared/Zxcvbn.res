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

let color = t => {
  switch t.strength {
  | Weak => "red"
  | Fair => "orange"
  | Medium => "yellow"
  | Strong => "green"
  }
}

let suggestions = t => t.suggestions
let score = t => t.score

let make = (~userInputs=[], ~password) => {
  let zxcvbnResponse = zxcvbn(password, userInputs)
  let score = zxcvbnResponse.score
  let suggestions = zxcvbnResponse.feedback.suggestions
  let strength = switch score {
  | 0 | 1 => Weak
  | 2 => Fair
  | 3 => Medium
  | 4 => Strong
  | unexpectedScore => raise(UnexpectedZxcvbnScore(unexpectedScore))
  }
  {score: score, strength: strength, suggestions: suggestions}
}
