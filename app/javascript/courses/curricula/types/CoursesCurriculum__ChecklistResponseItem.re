type t = {
  question: TargetChecklistItem.t,
  result: string,
};

let question = t => t.question;
let result = t => t.result;

let make = (~question, ~result) => {question, result};

let makeEmpty = targetChecklist => {
  targetChecklist |> Array.map(tc => make(~question=tc, ~result=""));
};

let updateResult = (index, result, responses) => {
  responses |> Array.mapi((i, r) => {i == index ? {...r, result} : r});
};
