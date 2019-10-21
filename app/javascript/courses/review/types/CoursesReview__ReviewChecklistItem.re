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
      ~checklist=[|CoursesReview__ReviewChecklistResult.empty()|],
    ),
  |];
};

let emptyTemplate = () => {
  [|
    make(
      ~title="Default checklist",
      ~checklist=CoursesReview__ReviewChecklistResult.emptyTemplate(),
    ),
  |];
};

let updateTitle = (title, t) => {
  make(~title, ~checklist=t.checklist);
};

let updateChecklist = (checklist, t) => {
  make(~title=t.title, ~checklist);
};

let replace = (t, itemIndex, checklist) => {
  checklist |> Array.mapi((index, item) => index == itemIndex ? t : item);
};

let appendEmptyChecklistItem = t => {
  make(
    ~title=t.title,
    ~checklist={
      [|CoursesReview__ReviewChecklistResult.empty()|]
      |> Array.append(t.checklist);
    },
  );
};
