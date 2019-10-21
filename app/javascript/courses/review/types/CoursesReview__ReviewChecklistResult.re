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
    make(~title="Yes", ~feedback=Some("Sample feedback for yes")),
    make(~title="No", ~feedback=Some("Sample feedback for no")),
  |];
};

let empty = () => {
  make(~title="Sample title", ~feedback=Some("Sample feedback text"));
};

let replace = (t, index, checklist) => {
  checklist
  |> Array.mapi((resultIndex, result) => resultIndex == index ? t : result);
};

let updateTitle = (title, t, index, checklist) => {
  checklist |> replace(make(~title, ~feedback=t.feedback), index);
};

let updateFeedback = (feedback, t, index, checklist) => {
  checklist
  |> replace(make(~title=t.title, ~feedback=Some(feedback)), index);
};
