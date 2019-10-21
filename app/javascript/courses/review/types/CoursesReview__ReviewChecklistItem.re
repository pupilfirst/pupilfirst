type t = {
  title: string,
  result: array(CoursesReview__ReviewChecklistResult.t),
};
let title = t => t.title;
let result = t => t.result;

let make = (~title, ~result) => {title, result};

let decodeJS = data => {
  data
  |> Js.Array.map(rc =>
       make(
         ~title=rc##title,
         ~result=rc##result |> CoursesReview__ReviewChecklistResult.decodeJS,
       )
     );
};

let empty = () => {
  [|
    make(
      ~title="Default checklist",
      ~result=[|CoursesReview__ReviewChecklistResult.empty()|],
    ),
  |];
};

let emptyTemplate = () => {
  [|
    make(
      ~title="Default checklist",
      ~result=CoursesReview__ReviewChecklistResult.emptyTemplate(),
    ),
  |];
};

let updateTitle = (title, t) => {
  make(~title, ~result=t.result);
};

let updateChecklist = (result, t) => {
  make(~title=t.title, ~result);
};

let replace = (t, itemIndex, result) => {
  result |> Array.mapi((index, item) => index == itemIndex ? t : item);
};

let appendEmptyChecklistItem = t => {
  make(
    ~title=t.title,
    ~result={
      [|CoursesReview__ReviewChecklistResult.empty()|]
      |> Array.append(t.result);
    },
  );
};

let deleteResultItem = (index, t) => {
  make(
    ~title=t.title,
    ~result=t.result |> Js.Array.filteri((_el, i) => i != index),
  );
};
