type file = {
  id: string,
  name: string,
};

type answer =
  | Files(array(file))
  | Link(string)
  | ShortText(string)
  | LongText(string)
  | MultiChoice(option(int))
  | Statement;

type t = {
  question: TargetChecklistItem.t,
  answer,
};

let question = t => t.question;
let answer = t => t.answer;

let make = (~question, ~answer) => {question, answer};

let makeEmpty = targetChecklist => {
  targetChecklist
  |> Array.map(tc => {
       let answer =
         switch (tc |> TargetChecklistItem.kind) {
         | Files => Files([||])
         | Link => Link("")
         | ShortText => ShortText("")
         | LongText => LongText("")
         | MultiChoice(_choices) => MultiChoice(None)
         | Statement => Statement
         };
       make(~question=tc, ~answer);
     });
};

let updateResult = (index, answer, responses) => {
  responses |> Array.mapi((i, r) => {i == index ? {...r, answer} : r});
};

let makeFile = (id, name) => {id, name};

let filename = file => file.name;
let fileId = file => file.id;
