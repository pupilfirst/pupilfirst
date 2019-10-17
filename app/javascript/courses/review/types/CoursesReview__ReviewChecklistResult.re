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
