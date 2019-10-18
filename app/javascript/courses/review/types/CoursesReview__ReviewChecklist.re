type t = {
  title: string,
  checklist: array(CoursesReview__ReviewChecklistResult.t),
};
let title = t => t.title;
let checklist = t => t.checklist;

let make = (~title, ~checklist) => {title, checklist};

let decodeJS = data => {
  data
  |> Js.Array.map(rc =>
       make(
         ~title=rc##title,
         ~checklist=
           rc##checklist |> CoursesReview__ReviewChecklistResult.decodeJS,
       )
     );
};

let empty = () => {
  [|
    make(
      ~title="Default checklist",
      ~checklist=CoursesReview__ReviewChecklistResult.empty(),
    ),
  |];
};

let updateTitle = (title, t) => {
  make(~title, ~checklist=t.checklist);
};

let updateChecklist = (checklist, t) => {
  make(~title=t.title, ~checklist);
};

let replace = (t, index, checklist) => {
  checklist |> ArrayUtils.replace(t, index);
};
