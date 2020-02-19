type file = {
  id: string,
  name: string,
};

type result =
  | Files(array(file))
  | Link(string)
  | ShortText(string)
  | LongText(string)
  | MultiChoice(choices, option(int))
  | Statement
and choices = array(string);

type t = {
  title: string,
  optional: bool,
  result,
};

let title = t => t.title;
let result = t => t.result;
let optional = t => t.optional;
let make = (~result, ~title, ~optional) => {result, title, optional};

let makeEmpty = targetChecklist => {
  targetChecklist
  |> Array.map(tc => {
       let title = tc |> TargetChecklistItem.title;
       let optional = tc |> TargetChecklistItem.optional;
       let result =
         switch (tc |> TargetChecklistItem.kind) {
         | Files => Files([||])
         | Link => Link("")
         | ShortText => ShortText("")
         | LongText => LongText("")
         | MultiChoice(choices) => MultiChoice(choices, None)
         | Statement => Statement
         };
       make(~title, ~optional, ~result);
     });
};

let updateResult = (index, result, checklist) => {
  checklist |> Array.mapi((i, c) => {i == index ? {...c, result} : c});
};

let makeFile = (id, name) => {id, name};

let filename = file => file.name;
let fileId = file => file.id;

let fileIds = checklist => {
  checklist
  |> Array.map(c =>
       switch (c.result) {
       | Files(files) => files |> Array.map(a => a.id) |> Array.to_list
       | _anyOtherResult => []
       }
     )
  |> ArrayUtils.flatten;
};

let encodeKind = t => {
  switch (t.result) {
  | Files(_) => "files"
  | Link(_) => "link"
  | ShortText(_) => "short_text"
  | LongText(_) => "long_text"
  | MultiChoice(_, _) => "multi_choice"
  | Statement => "statement"
  };
};

let encodeMultiChoice = (choices, index) => {
  switch (index) {
  | Some(i) => choices[i]
  | None => ""
  };
};

let encodeResult = t => {
  switch (t.result) {
  | Files(_) => "files"
  | Link(t)
  | ShortText(t)
  | LongText(t) => t
  | MultiChoice(choices, index) =>
    index
    |> OptionUtils.flatMap(i => choices |> ArrayUtils.getOpt(i))
    |> OptionUtils.default("")
  | Statement => ""
  };
};

let validString = (s, maxLength) => {
  let length = s |> String.trim |> String.length;
  length > 1 && length <= maxLength;
};

let validShortText = s => {
  validString(s, 250);
};

let validLongText = s => {
  validString(s, 1000);
};

let validResponse = response => {
  switch (response.result) {
  | Files(files) => files != [||] && files |> Array.length <= 3
  | Link(link) => link |> UrlUtils.isValid(response.optional)
  | ShortText(t) => validShortText(t)
  | LongText(t) => validLongText(t)
  | MultiChoice(choices, index) =>
    index
    |> OptionUtils.mapWithDefault(i => choices |> Array.length > i, false)
  | Statement => true
  };
};

let validResonses = responses => {
  responses |> Js.Array.filter(c => {validResponse(c)});
};

let encode = t =>
  Json.Encode.(
    object_([
      ("title", t.title |> string),
      ("kind", encodeKind(t) |> string),
      ("status", "pending" |> string),
      ("result", encodeResult(t) |> string),
    ])
  );

let encodeArray = checklist =>
  validResonses(checklist) |> Json.Encode.(array(encode));

let makeAttachments = checklist => {
  checklist
  |> Array.map(c =>
       switch (c.result) {
       | Files(files) => files |> Array.to_list
       | _ => []
       }
     )
  |> ArrayUtils.flatten
  |> Array.map(f =>
       SubmissionChecklistItem.makeAttachment(~name=f.name, ~id=f.id, ~url="")
     );
};
