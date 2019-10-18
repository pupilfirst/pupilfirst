type t = {
  title: string,
  feedback: option(string),
};
let title = t => t.title;
let feedback = t => t.feedback;

let make = (~title, ~feedback) => {title, feedback};

let decodeJS = data => {
  data |> Js.Array.map(r => make(~title=r##title, ~feedback=r##feedback));
};

let emptyTemplate = () => {
  [|
    make(~title="Yes", ~feedback=Some("Sample text for yes")),
    make(~title="No", ~feedback=Some("Sample text for no")),
  |];
};

let empty = () => {
  make(~title="Sample title", ~feedback=Some("Sample description text"));
};

let replace = (t, index, checklist) => {
  checklist |> ArrayUtils.replace(t, index);
};

let updateTitle = (title, t, index, checklist) => {
  checklist |> replace(make(~title, ~feedback=t.feedback), index);
};

let updateFeedback = (feedback, t, index, checklist) => {
  checklist
  |> replace(make(~title=t.title, ~feedback=Some(feedback)), index);
};
