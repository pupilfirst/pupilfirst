type file = {
  id: string,
  name: string,
};

type answer =
  | Files(array(file))
  | Link(string)
  | ShortText(string)
  | LongText(string)
  | MultiChoice(option(string))
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

let fileIds = checklist => {
  checklist
  |> Array.map(c =>
       switch (c.answer) {
       | Files(files) => files |> Array.map(a => a.id) |> Array.to_list
       | _ => []
       }
     )
  |> Array.to_list
  |> List.flatten
  |> Array.of_list;
};

let encodeKind = t => {
  switch (t.answer) {
  | Files(_) => "files"
  | Link(_) => "link"
  | ShortText(_) => "short_text"
  | LongText(_) => "long_text"
  | MultiChoice(_) => "multi_choice"
  | Statement => "statement"
  };
};

let encodeResult = t => {
  switch (t.answer) {
  | Files(_) => "files"
  | Link(t)
  | ShortText(t)
  | LongText(t) => t
  | MultiChoice(t) => t |> OptionUtils.default("")
  | Statement => ""
  };
};

let validResponse = response => {
  switch (response.answer) {
  | Files(files) => files != [||]
  | Link(t)
  | ShortText(t)
  | LongText(t) => t |> String.length > 2
  | MultiChoice(t) =>
    t |> OptionUtils.mapWithDefault(a => a |> String.length > 2, false)
  | Statement => true
  };
};

let validResonses = responses => {
  responses |> Js.Array.filter(c => {validResponse(c)});
};

let encode = t =>
  Json.Encode.(
    object_([
      ("title", t.question |> TargetChecklistItem.title |> string),
      ("kind", encodeKind(t) |> string),
      ("status", "pending" |> string),
      ("result", encodeResult(t) |> string),
    ])
  );

let encodeArray = checklist =>
  validResonses(checklist) |> Json.Encode.(array(encode));

// let toSubmissionChecklist => {

//   let make = (~title, ~result, ~status) => {title, result, status};
// }
